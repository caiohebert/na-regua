import 'package:na_regua/models/barber_model.dart';
import 'package:na_regua/models/service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../utils/date.dart';
import './db_types.dart';

Future<List<Map<String, dynamic>>> getBooking(
  ServiceModel service,
  BarberModel barber,
  String bookedDate,
  String bookedTime,
  AppointmentStatus status
) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final bookings = await supabase
      .from('appointments')
      .select()
      .eq('barber_id', barber.id)
      .eq('service_id', service.id)
      .eq('user_id', userId)
      .eq('date', bookedDate)
      // convert HH:MM to HH:MM:SS for matching
      .eq('time', '$bookedTime:00')
      .eq('status', status.dbName);
  return bookings;
}

Future<List<Map<String, dynamic>>> getUserBookings() async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final bookings = await supabase
      .from('appointments')
      .select('*, barbers(*, users(*)), services(*)')
      .eq('user_id', userId)
      .order('date', ascending: true);
  return bookings;
}

Future<List<Map<String, dynamic>>> getAllServices() async {
  final supabase = Supabase.instance.client;
  final services = await supabase.from('services').select();
  return services;
}

Future<List<Map<String, dynamic>>> getAllAvailableBarbers(DateTime date, {String? serviceId}) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;
  
  /*
  Base query:
  SELECT DISTINCT(b.*)
  FROM barbers as b
  INNER JOIN time_slots as t ON b.id = t.barber_id
  WHERE t.date = <date> AND t.status = 'AVAILABLE'

  If serviceId is provided, also INNER JOIN barber_services as bs
  ON b.id = bs.barber_id AND bs.service_id = <serviceId>
  */
  final bookingDate = getDate(date);

  if (serviceId == null) {
    final barbers = await supabase
        .from('barbers')
        .select('*, time_slots!inner(*), users!inner(*)') // !inner enforces INNER JOIN behavior
        .eq('time_slots.date', bookingDate)
        .eq('time_slots.status', 'AVAILABLE');
    // exclude current user (barber cannot book themselves)
    barbers.removeWhere((b) => (b)['user_id'] == userId);
    return barbers;
  }

  // serviceId provided -> ensure barber provides that service via barber_services
  final barbers = await supabase
      .from('barbers')
      .select('*, time_slots!inner(*), users!inner(*), barber_services!inner(*)')
      .eq('time_slots.date', bookingDate)
      .eq('time_slots.status', 'AVAILABLE')
      .eq('barber_services.service_id', serviceId);

  // exclude current user (barber cannot book themselves)
  barbers.removeWhere((b) => (b)['user_id'] == userId);

  return barbers;
}


Future<void> createBooking(
  ServiceModel service,
  BarberModel barber,
  String bookedDate,
  String bookedTime,
) async {
  final supabase = Supabase.instance.client;
  final String userId = supabase.auth.currentUser!.id;

  final existingBooking = await getBooking(
    service,
    barber,
    bookedDate,
    bookedTime,
    AppointmentStatus.confirmed
  );
  if (existingBooking.isNotEmpty) {
    throw Exception('Booking already exists for the selected slot.');
  }
  // Fetch all timeslots for this barber/date ordered by time so we can
  // determine the slot interval and mark consecutive slots as booked
  final slotsRes = await supabase
      .from('time_slots')
      .select()
      .eq('barber_id', barber.id)
      .eq('date', bookedDate)
      .order('time', ascending: true);
  final slots = slotsRes as List<dynamic>;

  // Find the index of the requested starting slot and make sure it's available
  final targetTimeStr = '$bookedTime:00';
  final startIndex = slots.indexWhere((s) => (s as Map<String, dynamic>)['time'] == targetTimeStr);
  if (startIndex == -1) {
    throw Exception('Selected time slot not found.');
  }

  final startSlot = (slots[startIndex] as Map<String, dynamic>);
  if (startSlot['status'] != TimeSlotStatus.available.dbName) {
    throw Exception('Selected time slot is not available.');
  }

  // Determine minutes per slot by looking at the next slot (fallback to 30)
  int slotMinutes = 30;
  if (startIndex < slots.length - 1) {
    final nextSlot = (slots[startIndex + 1] as Map<String, dynamic>);
    try {
      final curDt = buildDateTime(bookedDate, startSlot['time'] as String);
      final nextDt = buildDateTime(bookedDate, nextSlot['time'] as String);
      final diff = nextDt.difference(curDt).inMinutes;
      if (diff > 0) slotMinutes = diff;
    } catch (_) {
      // ignore and keep default
    }
  }

  final slotsNeeded = (service.durationMinutes + slotMinutes - 1) ~/ slotMinutes;

  // Ensure there are enough consecutive available slots
  if (startIndex + slotsNeeded > slots.length) {
    throw Exception('Not enough consecutive slots available for this service.');
  }

  final idsToBook = <String>[];
  for (var i = 0; i < slotsNeeded; i++) {
    final slot = (slots[startIndex + i] as Map<String, dynamic>);
    if (slot['status'] != TimeSlotStatus.available.dbName) {
      throw Exception('Required slot at ${slot['time']} is not available.');
    }
    idsToBook.add(slot['id'] as String);
  }

  // Insert appointment referencing the first slot
  await supabase
      .from('appointments')
      .insert({
        'barber_id': barber.id,
        'service_id': service.id,
        'user_id': userId,
        'time_slot_id': startSlot['id'],
        'date': bookedDate,
        'time': targetTimeStr,
        'status': AppointmentStatus.confirmed.dbName,
      });

  // Mark all involved timeslots as booked
  if (idsToBook.isNotEmpty) {
    final inClause = '(${idsToBook.map((id) => '"$id"').join(',')})';
    await supabase
        .from('time_slots')
        .update({'status': TimeSlotStatus.booked.dbName})
        .filter('id', 'in', inClause);
  }
}

Future<void> cancelBooking(BookingModel booking) async {
  final supabase = Supabase.instance.client;

  // update appointment status
  await supabase
      .from('appointments')
      .update({'status': AppointmentStatus.cancelled.dbName})
      .eq('id', booking.id);

  // Also free up any consecutive booked slots that were occupied by this appointment
  final bookingDate = getDate(booking.date);
  final bookedTime = '${getFormattedTime(booking.date)}:00';

  // Fetch slots for the barber/date ordered by time
  final slotsRes = await supabase
      .from('time_slots')
      .select()
      .eq('barber_id', booking.barber!.id)
      .eq('date', bookingDate)
      .order('time', ascending: true);
  final slots = slotsRes as List<dynamic>;

  final startIndex = slots.indexWhere((s) => (s as Map<String, dynamic>)['time'] == bookedTime);
  if (startIndex == -1) {
    // fallback: attempt to free by exact time match (previous behavior)
    await supabase
        .from('time_slots')
        .update({'status': TimeSlotStatus.available.dbName})
        .eq('barber_id', booking.barber!.id)
        .eq('date', bookingDate)
        .eq('time', bookedTime);
    return;
  }

  // Determine slot interval minutes
  int slotMinutes = 30;
  if (startIndex < slots.length - 1) {
    final cur = (slots[startIndex] as Map<String, dynamic>);
    final next = (slots[startIndex + 1] as Map<String, dynamic>);
    try {
      final curDt = buildDateTime(bookingDate, cur['time'] as String);
      final nextDt = buildDateTime(bookingDate, next['time'] as String);
      final diff = nextDt.difference(curDt).inMinutes;
      if (diff > 0) slotMinutes = diff;
    } catch (_) {}
  }

  final serviceDuration = booking.service?.durationMinutes ?? 0;
  final slotsToFree = serviceDuration > 0 ? (serviceDuration + slotMinutes - 1) ~/ slotMinutes : 1;

  final idsToFree = <String>[];
  for (var i = 0; i < slotsToFree; i++) {
    final idx = startIndex + i;
    if (idx >= slots.length) break;
    final s = (slots[idx] as Map<String, dynamic>);
    if (s['status'] == TimeSlotStatus.booked.dbName) {
      idsToFree.add(s['id'] as String);
    }
  }

  if (idsToFree.isNotEmpty) {
    final inClause = '(${idsToFree.map((id) => '"$id"').join(',')})';
    await supabase
        .from('time_slots')
        .update({'status': TimeSlotStatus.available.dbName})
        .filter('id', 'in', inClause);
  }
}
