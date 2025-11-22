import 'barber_model.dart';
import 'service_model.dart';

class BookingModel {
  final String id;
  final BarberModel barber;
  final ServiceModel service;
  final DateTime date;
  final String status; // 'upcoming', 'completed', 'cancelled'

  const BookingModel({
    required this.id,
    required this.barber,
    required this.service,
    required this.date,
    required this.status,
  });
}
