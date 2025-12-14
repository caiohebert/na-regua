import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('services').select();
  
  final data = response as List<dynamic>;
  return data.map((e) => ServiceModel.fromJson(e)).toList();
});
