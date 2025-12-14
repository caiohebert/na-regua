import 'barber_model.dart';
import 'service_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String barberId;
  final String serviceId;
  final DateTime date;
  final String status;
  
  final BarberModel? barber;
  final ServiceModel? service;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.serviceId,
    required this.date,
    required this.status,
    this.barber,
    this.service,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Combine date and time if separate, or parse if combined
    // Assuming Supabase returns them separately as per schema
    // date: YYYY-MM-DD
    // time: HH:MM:SS+TZ
    
    DateTime dateTime;
    if (json['date'] != null && json['time'] != null) {
       final dateStr = json['date'] as String;
       final timeStr = json['time'] as String;
       // Simple parsing, might need adjustment based on exact format
       // Removing TZ for simplicity if needed or parsing properly
       dateTime = DateTime.parse('${dateStr}T$timeStr'); 
    } else {
      dateTime = DateTime.now(); // Fallback
    }

    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      barberId: json['barber_id'] as String,
      serviceId: json['service_id'] as String,
      date: dateTime,
      status: json['status'] as String,
      barber: json['barbers'] != null ? BarberModel.fromJson(json['barbers']) : null,
      service: json['services'] != null ? ServiceModel.fromJson(json['services']) : null,
    );
  }
}
