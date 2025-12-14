import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

Future<void> updateBooking(BookingModel booking, String status) async {
  final supabase = Supabase.instance.client;
  await supabase
      .from('appointments')
      .update({'status': status})
      .eq('id', booking.id);
}
