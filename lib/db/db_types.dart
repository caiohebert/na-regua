enum AppointmentStatus {
  pending,
  confirmed,
  cancelled;
  // completed  // TODO add completed status later

  String get dbName => name.toUpperCase();
  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'PENDENTE';
      case AppointmentStatus.confirmed:
        return 'CONFIRMADO';
      case AppointmentStatus.cancelled:
        return 'CANCELADO';
    }
  }

  static AppointmentStatus fromDbName(String dbName) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.dbName == dbName,
      orElse: () => throw Exception('Unknown appointment status: $dbName'),
    );
  }
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