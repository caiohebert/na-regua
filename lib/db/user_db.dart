import 'package:na_regua/db/db_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

(String, String) getUserNameEmailFromSession() {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }
  final userData = currentUser.userMetadata ?? {};

  // TODO what if full_name is not set? can this happen?
  final name = userData['full_name'] ?? 'User';
  final email = currentUser.email!;
  return (name, email);
}

/// Upsert (update or insert) user from Supabase Auth current user
/// NOTE: role defaults to customer. Other user role
/// can only be created from admin panel (not implemented yet).
/// TODO: implement admin panel to create barber/admin users
Future<void> insertUserFromSession([UserRole role = UserRole.customer]) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }

  final (name, email) = getUserNameEmailFromSession();

  await supabase.from('users').insert({
    'id': currentUser.id,
    'name': name,
    'email': email,
    'type': role.dbName,
    'updated_at': DateTime.now().toIso8601String(),
  });
}

/// Create user from Supabase Auth current user
Future<Map<String, dynamic>?> getUserFromSession() async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }

  final userData = await supabase
      .from('users')
      .select()
      .eq('id', currentUser.id);
  return userData.isEmpty ? null : userData.first;
}

Future<void> updateUserRole(UserRole role) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }

  final (name, email) = getUserNameEmailFromSession();

  // Upsert to avoid failures if the row does not exist yet
  await supabase.from('users').upsert({
    'id': currentUser.id,
    'name': name,
    'email': email,
    'type': role.dbName,
    'updated_at': DateTime.now().toIso8601String(),
  }).select();
}

/// Ensure a barber profile exists for the current user (id from auth)
Future<void> ensureBarberProfile() async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }

  await supabase.from('barbers').upsert(
    {'user_id': currentUser.id},
    onConflict: 'user_id', // prevent duplicate barber rows per user
  );
}

Future<Map<String, dynamic>?> getBarberProfile() async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }

  final data = await supabase
      .from('barbers')
      .select()
      .eq('user_id', currentUser.id)
      .maybeSingle();

  return data;
}

Future<void> updateBarberProfile({
  String? description,
  String? location,
  String? avatarUrl,
  String? coverUrl,
}) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) {
    throw Exception('No authenticated user found.');
  }

  // Ensure row exists so update works
  await ensureBarberProfile();

  await supabase
      .from('barbers')
      .update({
        'description': description,
        'location': location,
        'avatar_url': avatarUrl,
        'cover_url': coverUrl,
      })
      .eq('user_id', currentUser.id);
}

/// Promote current user to admin (barber dashboard) and ensure barber profile
Future<void> promoteUserToAdminBarber() async {
  await updateUserRole(UserRole.admin);
  await ensureBarberProfile();
}
