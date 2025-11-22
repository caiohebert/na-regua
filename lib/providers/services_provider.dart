import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/data/dummy_data.dart';
import '../models/service_model.dart';

final servicesProvider = Provider<List<ServiceModel>>((ref) {
  return mockServices;
});
