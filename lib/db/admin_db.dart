import 'package:na_regua/db/db_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/date.dart';

/// Get all appointments for the current barber
Future<List<Map<String, dynamic>>> getBarberAppointments() async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  // First, get the barber record for the current user
  final barberData = await supabase
      .from('barbers')
      .select('id')
      .eq('user_id', userId)
      .maybeSingle();

  if (barberData == null) {
    return [];
  }

  final barberId = barberData['id'] as String;

  // Get all appointments for this barber
  final appointments = await supabase
      .from('appointments')
      .select(
        '*, users!appointments_user_id_fkey(name, email, avatar_url), services(*)',
      )
      .eq('barber_id', barberId)
      .order('date', ascending: true)
      .order('time', ascending: true);

  return appointments;
}

/// Confirm an appointment
Future<void> confirmAppointment(String appointmentId) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('appointments')
      .update({'status': AppointmentStatus.confirmed.dbName})
      .eq('id', appointmentId);
}

/// Cancel an appointment as barber
Future<void> cancelAppointmentAsBarber(
  String appointmentId,
  String timeSlotId,
) async {
  final supabase = Supabase.instance.client;

  // Update appointment status
  await supabase
      .from('appointments')
      .update({'status': AppointmentStatus.cancelled.dbName})
      .eq('id', appointmentId);

  // Free up the time slot
  await supabase
      .from('time_slots')
      .update({'status': TimeSlotStatus.available.dbName})
      .eq('id', timeSlotId);
}

/// Create a new service
Future<void> createService({
  required String name,
  required double price,
  required int durationMinutes,
  String? description,
}) async {
  final supabase = Supabase.instance.client;

  final res = await supabase.from('services').insert({
    'name': name,
    'price': price,
    'duration': durationMinutes,
    'description': description,
  }).select();
  final rows = res as List;
  if (rows.isEmpty) {
    throw Exception('Failed to create service. Check DB policies/permissions.');
  }
}

/// Update an existing service
Future<void> updateService({
  required String serviceId,
  required String name,
  required double price,
  required int durationMinutes,
  String? description,
}) async {
  final supabase = Supabase.instance.client;

  final res = await supabase
      .from('services')
      .update({
        'name': name,
        'price': price,
        'duration': durationMinutes,
        'description': description,
      })
      .eq('id', serviceId)
      .select();
  final rows = res as List;
  if (rows.isEmpty) {
    throw Exception(
      'Failed to update service (id=$serviceId). Check DB policies/permissions.',
    );
  }
}

/// Delete a service
Future<void> deleteService(String serviceId) async {
  final supabase = Supabase.instance.client;

  final res = await supabase
      .from('services')
      .delete()
      .eq('id', serviceId)
      .select();
  final rows = res as List;
  if (rows.isEmpty) {
    throw Exception(
      'Failed to delete service (id=$serviceId). Check DB policies/permissions.',
    );
  }
}

/// Helper to get current barber id for authenticated user
Future<String?> _getCurrentBarberId() async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final barberData = await supabase
      .from('barbers')
      .select('id')
      .eq('user_id', userId)
      .maybeSingle();

  if (barberData == null) return null;
  return barberData['id'] as String;
}

/// Get service ids associated with current barber
Future<List<String>> getCurrentBarberServiceIds() async {
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) return [];

  final rows = await supabase
      .from('barber_services')
      .select('service_id')
      .eq('barber_id', barberId);

  final list = (rows as List<dynamic>)
      .map((e) => (e as Map<String, dynamic>)['service_id'] as String)
      .toList();
  return list;
}

/// Add a service to current barber
Future<void> addServiceToCurrentBarber(String serviceId) async {
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) {
    throw Exception('Barber record not found for current user');
  }

  await supabase.from('barber_services').insert({
    'barber_id': barberId,
    'service_id': serviceId,
  });
}

/// Remove a service from current barber
Future<void> removeServiceFromCurrentBarber(String serviceId) async {
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) {
    throw Exception('Barber record not found for current user');
  }

  await supabase
      .from('barber_services')
      .delete()
      .eq('barber_id', barberId)
      .eq('service_id', serviceId);
}

/// Create time slots for the current barber between two dates (inclusive).
/// Times are strings in 'HH:MM' format (seconds will be set to ':00').
/// Returns number of slots created.
Future<int> createTimeSlotsForDateRange({
  required DateTime dateStart,
  required DateTime dateEnd,
  required String startTime,
  required String endTime,
  int stepMinutes = 30,
}) async {
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) throw Exception('Barber record not found for current user');

  final startParts = startTime.split(':');
  final endParts = endTime.split(':');
  final startHour = int.parse(startParts[0]);
  final startMinute = int.parse(startParts[1]);
  final endHour = int.parse(endParts[0]);
  final endMinute = int.parse(endParts[1]);

  int created = 0;

  for (var d = dateStart; !d.isAfter(dateEnd); d = d.add(const Duration(days: 1))) {
    final dateStr = getDate(d);

    // Build times for this day
    var current = DateTime(d.year, d.month, d.day, startHour, startMinute);
    final endDt = DateTime(d.year, d.month, d.day, endHour, endMinute);

    // Fetch existing times for this date to avoid duplicates
    final existingRes = await supabase
        .from('time_slots')
        .select('time')
        .eq('barber_id', barberId)
        .eq('date', dateStr);
    final existing = (existingRes as List<dynamic>).map((e) => (e as Map<String, dynamic>)['time'] as String).toSet();

    final toInsert = <Map<String, dynamic>>[];

    while (!current.isAfter(endDt)) {
      final timeStr = '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}:00';
      if (!existing.contains(timeStr)) {
        toInsert.add({
          'barber_id': barberId,
          'date': dateStr,
          'time': timeStr,
          'status': TimeSlotStatus.available.dbName,
        });
      }
      current = current.add(Duration(minutes: stepMinutes));
    }

    if (toInsert.isNotEmpty) {
      final res = await supabase.from('time_slots').insert(toInsert).select();
      final rows = res as List<dynamic>;
      created += rows.length;
    }
  }

  return created;
}

/// Delete a single time slot for the current barber. Returns number of deleted rows.
Future<int> deleteTimeSlot({required String date, required String time}) async {
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) throw Exception('Barber record not found for current user');

  final res = await supabase
      .from('time_slots')
      .delete()
      .eq('barber_id', barberId)
      .eq('date', date)
      .eq('time', time)
      .select();
  final rows = res as List<dynamic>;
  return rows.length;
}

/// Delete time slots for the current barber between two dates (inclusive).
/// Optionally provide time range to only delete specific times each day.
Future<int> deleteTimeSlotsForDateRange({
  required DateTime dateStart,
  required DateTime dateEnd,
  String? startTime, // 'HH:MM' optional
  String? endTime, // 'HH:MM' optional
}) async {
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) throw Exception('Barber record not found for current user');

  int deleted = 0;
  for (var d = dateStart; !d.isAfter(dateEnd); d = d.add(const Duration(days: 1))) {
    final dateStr = getDate(d);

    var query = supabase.from('time_slots').delete().eq('barber_id', barberId).eq('date', dateStr);

    if (startTime != null && endTime != null) {
      final s = '$startTime:00';
      final e = '$endTime:00';
      query = query.gte('time', s).lte('time', e);
    }

    final res = await query.select();
    final rows = res as List<dynamic>;
    deleted += rows.length;
  }

  return deleted;
}

/// Insert multiple explicit time slots for current barber. Each entry in `slots`
/// must be a map with keys: 'date' (YYYY-MM-DD) and 'time' (HH:MM:SS).
/// Returns number of rows inserted.
Future<int> insertTimeSlotsBulk(List<Map<String, String>> slots) async {
  if (slots.isEmpty) return 0;
  final supabase = Supabase.instance.client;
  final barberId = await _getCurrentBarberId();
  if (barberId == null) throw Exception('Barber record not found for current user');

  final payload = slots.map((s) => {
        'barber_id': barberId,
        'date': s['date'],
        'time': s['time'],
        'status': TimeSlotStatus.available.dbName,
      }).toList();

  final res = await supabase.from('time_slots').insert(payload).select();
  final rows = res as List<dynamic>;
  return rows.length;
}

