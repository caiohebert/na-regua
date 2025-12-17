import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/booking_db.dart';
import '../models/barber_model.dart';

class BarbersParams {
  final DateTime date;
  final String? serviceId;

  const BarbersParams({required this.date, this.serviceId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BarbersParams && other.date == date && other.serviceId == serviceId;
  }

  @override
  int get hashCode => date.hashCode ^ (serviceId?.hashCode ?? 0);
}

final barbersProvider = FutureProvider.family<List<BarberModel>, BarbersParams>((ref, params) async {
  final data = await getAllAvailableBarbers(params.date, serviceId: params.serviceId);
  return data.map((e) => BarberModel.fromJson(e)).toList();
});
