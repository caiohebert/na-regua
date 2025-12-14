import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

final bookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final supabase = Supabase.instance.client;

  // TODO get user when auth is ready
  // final user = supabase.auth.currentUser;
  // if (user == null) {
  //   return [];
  // }

  final response = await supabase
      .from('appointments')
      .select('*, barbers(*), services(*)')
      // .eq('user_id', user.id)
      // TODO put user id when auth is ready
      .order('date', ascending: true);
  
  final data = response as List<dynamic>;
  return data.map((e) => BookingModel.fromJson(e)).toList();
});
