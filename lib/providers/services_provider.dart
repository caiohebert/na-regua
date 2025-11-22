import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_services.dart';
import '../models/service_model.dart';

final servicesProvider = Provider<List<ServiceModel>>((ref) {
  return mockServices;
});
