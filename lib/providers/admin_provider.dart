import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/admin_db.dart';
import 'package:na_regua/db/user_db.dart';
import 'package:na_regua/db/db_types.dart';
import 'package:na_regua/models/booking_model.dart';

/// Provider for barber's appointments
final barberAppointmentsProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final data = await getBarberAppointments();
  return data.map((e) => BookingModel.fromJson(e)).toList();
});

/// Provider exposing list of service ids the current barber offers
final barberServicesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  return getCurrentBarberServiceIds();
});

/// Provider exposing all users for admin management
final allUsersProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>((ref, query) async {
  if (query == null || query.trim().isEmpty) {
    // default empty list when no query provided to avoid listing everyone
    return [];
  }
  return await searchUsers(query);
});

final adminsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return await getUsersByRole(UserRole.admin);
});

final barbersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return await getUsersByRole(UserRole.barber);
});

