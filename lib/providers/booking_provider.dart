import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/booking_db.dart';
import '../models/booking_model.dart';

final bookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final data = await getUserBookings();
  return data.map((e) => BookingModel.fromJson(e)).toList();
});
