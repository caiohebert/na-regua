import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/barber_model.dart';

final barbersProvider = FutureProvider.family<List<BarberModel>, DateTime>((ref, date) async {
  final supabase = Supabase.instance.client;
  
  /*
  SELECT DISTINCT(b.*)
  FROM barbers as b
  INNER JOIN time_slots as t ON b.id = t.barber_id
  WHERE t.date = <date> AND t.status = 'AVAILABLE'
  */
  final dateStr = date.toIso8601String().split('T').first;
  
  final response = await supabase
      .from('barbers')
      .select('*, time_slots!inner(*)') // !inner enforces INNER JOIN behavior
      .eq('time_slots.date', dateStr)
      .eq('time_slots.status', 'AVAILABLE');
  
  final data = response as List<dynamic>;
  return data.map((e) => BarberModel.fromJson(e)).toList();
});
