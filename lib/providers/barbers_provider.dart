import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/booking_db.dart';
import '../models/barber_model.dart';

final barbersProvider = FutureProvider.family<List<BarberModel>, DateTime>((ref, date) async {
  final data = await getAllAvailableBarbers(date);
  return data.map((e) => BarberModel.fromJson(e)).toList();
});
