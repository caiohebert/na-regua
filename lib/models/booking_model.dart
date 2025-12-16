import 'package:na_regua/db/db_types.dart';

import 'barber_model.dart';
import 'service_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String barberId;
  final String serviceId;
  final DateTime date;
  final AppointmentStatus status;
  final String? timeSlotId;
  
  final BarberModel? barber;
  final ServiceModel? service;
  final String? userName;
  final String? userEmail;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.serviceId,
    required this.date,
    required this.status,
    this.timeSlotId,
    this.barber,
    this.service,
    this.userName,
    this.userEmail,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Combine date and time if separate, or parse if combined
    // Assuming Supabase returns them separately as per schema
    // date: YYYY-MM-DD
    // time: HH:MM:SS+TZ
    
    final dateStr = json['date'] as String;
    final timeStr = json['time'] as String;
    DateTime dateTime = DateTime.parse('${dateStr}T$timeStr'); 

    // Get user info from the users relation
    String? userName;
    String? userEmail;
    if (json['users'] != null) {
      final userData = json['users'] as Map<String, dynamic>;
      userName = userData['name'] as String?;
      userEmail = userData['email'] as String?;
    }

    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      barberId: json['barber_id'] as String,
      serviceId: json['service_id'] as String,
      date: dateTime,
      status: AppointmentStatus.fromDbName(json['status'] as String),
      timeSlotId: json['time_slot_id'] as String?,
      barber: json['barbers'] != null ? BarberModel.fromJson(json['barbers']) : null,
      service: json['services'] != null ? ServiceModel.fromJson(json['services']) : null,
      userName: userName,
      userEmail: userEmail,
    );
  }
}
