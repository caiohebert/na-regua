import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/barber_model.dart';
import '../utils/date.dart';

class TimetableParams {
  final BarberModel? barber;
  final DateTime date;

  const TimetableParams({
    required this.barber,
    required this.date,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TimetableParams &&
      other.barber == barber &&
      other.date == date;
  }

  @override
  int get hashCode => barber.hashCode ^ date.hashCode;
}

final timetableProvider = FutureProvider.family<List<String>, TimetableParams>((ref, params) async {
  if (params.barber == null) {
    return [];
  }

  final supabase = Supabase.instance.client;

  final bookingDate = getDate(params.date);
  final response = await supabase
      .from('time_slots')
      .select()
      .eq('barber_id', params.barber!.id)
      .eq('date', bookingDate)
      .eq('status', 'AVAILABLE');
  final data = response as List<dynamic>;

  return data
      .map((e) => getFormattedTime(buildDateTime(bookingDate, (e as Map<String, dynamic>)['time'] as String)))
      .toList();
});
