import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/booking_db.dart';
import '../models/service_model.dart';

/// Provider for all services with auto-dispose to allow refresh
final servicesProvider = FutureProvider.autoDispose<List<ServiceModel>>((ref) async {
  final data = await getAllServices();
  return data.map((e) => ServiceModel.fromJson(e)).toList();
});
