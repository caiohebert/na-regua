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

  final bookings = await supabase
      .from('appointments')
      .select()
      .eq('barber_id', barber.id)
      .eq('service_id', service.id)
      .eq('date', bookedDate)
      // convert HH:MM to HH:MM:SS for matching
      .eq('time', '$bookedTime:00')
      .eq('status', status.name);
  return bookings;
}

Future<void> createBooking(
  ServiceModel service,
  BarberModel barber,
  String bookedDate,
  String bookedTime
) async {
  final supabase = Supabase.instance.client;

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

  final timeslot = await supabase
      .from('time_slots')
      .select()
      .eq('barber_id', barber.id)
      .eq('date', bookedDate)
      // convert HH:MM to HH:MM:SS for matching
      .eq('time', '$bookedTime:00')
      .eq('status', TimeSlotStatus.available.name)
      .single();

  await supabase
      .from('appointments')
      .insert({
        'barber_id': barber.id,
        'service_id': service.id,
        'user_id': "851b46fc-76fb-4cc6-b073-add942602b06", // TODO add real user_id when auth is ready
        'time_slot_id': timeslot['id'],
        'date': bookedDate,
        'time': "$bookedTime:00",
        'status': AppointmentStatus.confirmed.name,
      });

  // update timeslot for that barber
  await supabase
      .from('time_slots')
      .update({'status': TimeSlotStatus.booked.name})
      .eq('id', timeslot['id']);
}

Future<void> cancelBooking(BookingModel booking) async {
  final supabase = Supabase.instance.client;

  // update appointment status
  await supabase
      .from('appointments')
      .update({'status': AppointmentStatus.cancelled.name})
      .eq('id', booking.id);

  await supabase
      .from('time_slots')
      .update({'status': TimeSlotStatus.available.name})
      .eq('barber_id', booking.barber!.id)
      .eq('date', getDate(booking.date))
      .eq('time', "${getFormattedTime(booking.date)}:00");
}