import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/booking_db.dart';
import '../models/service_model.dart';

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final data = await getAllServices();
  return data.map((e) => ServiceModel.fromJson(e)).toList();
});
