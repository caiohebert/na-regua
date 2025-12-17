import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/db_types.dart';
import 'package:na_regua/db/user_db.dart';

/// Provider to get current user's role
final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final userData = await getUserFromSession();
  if (userData == null) {
    return UserRole.customer; // Default to customer
  }
  
  final roleString = userData['type'] as String?;
  if (roleString == null) {
    return UserRole.customer;
  }
  
  // Convert string to enum
  return UserRole.values.firstWhere(
    (role) => role.dbName == roleString.toUpperCase(),
    orElse: () => UserRole.customer,
  );
});

/// Provider to check if current user is a barber
final isBarberProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return role == UserRole.barber;
});

