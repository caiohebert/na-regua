import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/barber_model.dart';

final barbersProvider = FutureProvider.family<List<BarberModel>, DateTime>((ref, date) async {
  final supabase = Supabase.instance.client;
  
  // TODO: Implement availability filtering based on 'date'
  // For now, return all barbers
  final response = await supabase.from('barbers').select();
  
  final data = response as List<dynamic>;
  return data.map((e) => BarberModel.fromJson(e)).toList();
});
