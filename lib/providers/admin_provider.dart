import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/admin_db.dart';
import 'package:na_regua/models/booking_model.dart';

/// Provider for barber's appointments
final barberAppointmentsProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final data = await getBarberAppointments();
  return data.map((e) => BookingModel.fromJson(e)).toList();
});

