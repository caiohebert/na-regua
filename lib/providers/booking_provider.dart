import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../data/dummy_data.dart';

final bookingsProvider = Provider<List<BookingModel>>((ref) {
  return dummyBookings;
});
