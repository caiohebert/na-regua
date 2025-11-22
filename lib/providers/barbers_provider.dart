import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/barber_model.dart';

final barbersProvider = Provider.family<List<BarberModel>, DateTime>((ref, date) {
  // In a real app, we would filter by availability on this date
  return dummyBarberAvailability[DateUtils.dateOnly(date)] ?? [];
});
