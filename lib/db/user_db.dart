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

// Promotion functions for current user have been removed.
// Use admin actions (promoteUserToBarberById / demoteBarberById) instead.

/// Get all users (for admin management)
Future<List<Map<String, dynamic>>> getAllUsers() async {
  final supabase = Supabase.instance.client;
  final users = await supabase
      .from('users')
      .select('id, name, email, type')
      .order('updated_at', ascending: false);
  return (users as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

/// Update role for any user by id (admin action)
Future<void> updateUserRoleForUser(String userId, UserRole role) async {
  final supabase = Supabase.instance.client;
  try {
    final res = await supabase
        .from('users')
        .update({
          'type': role.dbName,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select();

    // If no rows returned, likely permission/RLS prevented the update
    final rows = res as List<dynamic>;
    if (rows.isEmpty) {
      throw Exception(
        'Falha ao atualizar role: nenhuma linha atualizada. Resultado: $res',
      );
    }
  } catch (e) {
    throw Exception('Erro Supabase ao atualizar role: $e');
  }
}

/// Get users by role (e.g., admins or barbers)
Future<List<Map<String, dynamic>>> getUsersByRole(UserRole role) async {
  final supabase = Supabase.instance.client;
  final users = await supabase
      .from('users')
      .select('id, name, email, type')
      .eq('type', role.dbName)
      .order('updated_at', ascending: false);
  return (users as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

/// Search users by name or email (case-insensitive, partial match)
Future<List<Map<String, dynamic>>> searchUsers(String query) async {
  final supabase = Supabase.instance.client;
  final q = query.trim();
  if (q.isEmpty) return [];

  // Use PostgREST OR filter via `or` operator
  final users = await supabase
      .from('users')
      .select('id, name, email, type')
      .or('name.ilike.%$q%,email.ilike.%$q%')
      .order('updated_at', ascending: false);

  return (users as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

/// Ensure a barber profile exists for any user id
Future<void> ensureBarberProfileForUser(String userId) async {
  final supabase = Supabase.instance.client;
  await supabase.from('barbers').upsert({
    'user_id': userId,
  }, onConflict: 'user_id');
}

/// Remove barber profile for a given user id (used when demoting a barber)
Future<void> removeBarberProfileForUser(String userId) async {
  final supabase = Supabase.instance.client;
  await supabase.from('barbers').delete().eq('user_id', userId);
}

/// Promote any user (by id) to barber: update role and ensure barber profile
Future<void> promoteUserToBarberById(String userId) async {
  final supabase = Supabase.instance.client;
  try {
    final res = await supabase
        .from('users')
        .update({
          'type': UserRole.barber.dbName,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select();
    final rows = res as List<dynamic>;
    if (rows.isEmpty) {
      throw Exception(
        'Falha ao promover para barbeiro: nenhuma linha atualizada. Resultado: $res',
      );
    }
    await ensureBarberProfileForUser(userId);
  } catch (e) {
    throw Exception('Erro Supabase ao promover para barbeiro: $e');
  }
}

/// Demote a user from barber to another role: update role and remove barber profile
Future<void> demoteBarberById(String userId, UserRole newRole) async {
  final supabase = Supabase.instance.client;
  try {
    final res = await supabase
        .from('users')
        .update({
          'type': newRole.dbName,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select();
    final rows = res as List<dynamic>;
    if (rows.isEmpty) {
      throw Exception(
        'Falha ao demover barbeiro: nenhuma linha atualizada. Resultado: $res',
      );
    }
    // Remove barber row if exists
    await removeBarberProfileForUser(userId);
  } catch (e) {
    throw Exception('Erro Supabase ao demover barbeiro: $e');
  }
}
