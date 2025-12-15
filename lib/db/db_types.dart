enum AppointmentStatus {
  pending,
  confirmed,
  cancelled;

  String get dbName => name.toUpperCase();
}

enum TimeSlotStatus {
  available,
  booked;

  String get dbName => name.toUpperCase();
}

enum UserRole {
  customer,
  barber,
  admin;

  String get dbName => name.toUpperCase();
}