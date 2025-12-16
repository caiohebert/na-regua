import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/user_db.dart';

/// Barber profile for the current user (null if not created yet)
final barberProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  return getBarberProfile();
});

