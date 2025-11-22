import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber_model.dart';
import '../data/dummy_data.dart';

final barbersProvider = Provider<List<BarberModel>>((ref) {
  return dummyBarbers;
});
