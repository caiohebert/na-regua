import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/barber_model.dart';
import '../utils/date.dart';

class TimetableParams {
  final BarberModel? barber;
  final DateTime date;
  final int? serviceDurationMinutes;

  const TimetableParams({
    required this.barber,
    required this.date,
    this.serviceDurationMinutes,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TimetableParams &&
      other.barber == barber &&
      other.date == date;
  }

  @override
  int get hashCode => barber.hashCode ^ date.hashCode ^ (serviceDurationMinutes ?? 0);
}

final timetableProvider = FutureProvider.family<List<String>, TimetableParams>((ref, params) async {
  if (params.barber == null) {
    return [];
  }

  final supabase = Supabase.instance.client;

  final bookingDate = getDate(params.date);
  // Fetch all slots for the barber/date (we need statuses to check consecutive availability)
  final response = await supabase
      .from('time_slots')
      .select()
      .eq('barber_id', params.barber!.id)
      .eq('date', bookingDate)
      .order('time', ascending: true);
  final data = response as List<dynamic>;

  if (data.isEmpty) return [];

  // determine slot minutes by comparing first two entries (fallback 30)
  int slotMinutes = 30;
  if (data.length >= 2) {
    try {
      final first = (data[0] as Map<String, dynamic>);
      final second = (data[1] as Map<String, dynamic>);
      final dt1 = buildDateTime(bookingDate, first['time'] as String);
      final dt2 = buildDateTime(bookingDate, second['time'] as String);
      final diff = dt2.difference(dt1).inMinutes;
      if (diff > 0) slotMinutes = diff;
    } catch (_) {}
  }

  final serviceDuration = params.serviceDurationMinutes ?? 0;
  final slotsNeeded = serviceDuration > 0 ? (serviceDuration + slotMinutes - 1) ~/ slotMinutes : 1;

  final times = <String>[];
  final slots = data.map((e) => e as Map<String, dynamic>).toList();
  
  // Get current date/time for filtering past slots on today's date
  final now = DateTime.now();
  final isToday = now.year == params.date.year &&
      now.month == params.date.month &&
      now.day == params.date.day;
  
  for (var i = 0; i < slots.length; i++) {
    final s = slots[i];
    if (s['status'] != 'AVAILABLE') continue;

    // If the selected date is today, filter out past time slots
    if (isToday) {
      final slotDateTime = buildDateTime(bookingDate, s['time'] as String);
      // Normalize to compare only date and time (ignore seconds/milliseconds)
      final slotNormalized = DateTime(
        slotDateTime.year,
        slotDateTime.month,
        slotDateTime.day,
        slotDateTime.hour,
        slotDateTime.minute,
      );
      final nowNormalized = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );
      
      // Skip if the slot time has already passed today
      if (slotNormalized.isBefore(nowNormalized)) {
        continue;
      }
    }

    // check following consecutive slots
    var ok = true;
    for (var j = 1; j < slotsNeeded; j++) {
      final idx = i + j;
      if (idx >= slots.length) {
        ok = false;
        break;
      }
      final next = slots[idx];
      if (next['status'] != 'AVAILABLE') {
        ok = false;
        break;
      }
    }
    if (ok) {
      times.add(getFormattedTime(buildDateTime(bookingDate, s['time'] as String)));
    }
  }

  return times;
});
