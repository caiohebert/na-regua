import 'package:na_regua/db/db_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      .select('*, users!appointments_user_id_fkey(name, email), services(*)')
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
Future<void> cancelAppointmentAsBarber(String appointmentId, String timeSlotId) async {
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

  await supabase.from('services').insert({
    'name': name,
    'price': price,
    'duration': durationMinutes,
    'description': description,
  });
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

  await supabase.from('services').update({
    'name': name,
    'price': price,
    'duration': durationMinutes,
    'description': description,
  }).eq('id', serviceId);
}

/// Delete a service
Future<void> deleteService(String serviceId) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('services')
      .delete()
      .eq('id', serviceId);
}

