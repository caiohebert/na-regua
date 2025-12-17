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
    return barbers;
  }

  // serviceId provided -> ensure barber provides that service via barber_services
  final barbers = await supabase
      .from('barbers')
      .select('*, time_slots!inner(*), users!inner(*), barber_services!inner(*)')
      .eq('time_slots.date', bookingDate)
      .eq('time_slots.status', 'AVAILABLE')
      .eq('barber_services.service_id', serviceId);

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

  final timeslot = await supabase
      .from('time_slots')
      .select()
      .eq('barber_id', barber.id)
      .eq('date', bookedDate)
      // convert HH:MM to HH:MM:SS for matching
      .eq('time', '$bookedTime:00')
      .eq('status', TimeSlotStatus.available.dbName)
      .single();

  await supabase
      .from('appointments')
      .insert({
        'barber_id': barber.id,
        'service_id': service.id,
        'user_id': userId,
        'time_slot_id': timeslot['id'],
        'date': bookedDate,
        'time': "$bookedTime:00",
        'status': AppointmentStatus.confirmed.dbName,
      });

  // update timeslot for that barber
  await supabase
      .from('time_slots')
      .update({'status': TimeSlotStatus.booked.dbName})
      .eq('id', timeslot['id']);
}

Future<void> cancelBooking(BookingModel booking) async {
  final supabase = Supabase.instance.client;

  // update appointment status
  await supabase
      .from('appointments')
      .update({'status': AppointmentStatus.cancelled.dbName})
      .eq('id', booking.id);

  await supabase
      .from('time_slots')
      .update({'status': TimeSlotStatus.available.dbName})
      .eq('barber_id', booking.barber!.id)
      .eq('date', getDate(booking.date))
      .eq('time', "${getFormattedTime(booking.date)}:00");
}
