import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber_model.dart';
import '../data/dummy_data.dart';

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
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  if (params.barber == null) {
    return [];
  }

  // Mock logic: different barbers have different schedules or just random for now
  // In a real app, this would fetch from backend based on barberId and date
  return dummyTimetable[params.barber!.name] ?? [];
});
