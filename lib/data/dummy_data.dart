import 'package:flutter/material.dart';
import 'package:na_regua/models/service_model.dart';
import '../models/barber_model.dart';
import '../models/booking_model.dart';

final List<BarberModel> dummyBarbers = [
  const BarberModel(
    id: '1',
    name: 'Peter the Barber',
    rating: 4.0,
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'I am a barber based on NYC',
    services: [
      ServiceModel(id: 's1', name: 'Haircut', price: 60.0, durationMinutes: 30),
      ServiceModel(id: 's2', name: 'Beard Trim', price: 30.0, durationMinutes: 20),
      ServiceModel(id: 's3', name: 'Shave', price: 40.0, durationMinutes: 25),
    ],
  ),
  const BarberModel(
    id: '2',
    name: 'John Doe',
    rating: 4.8,
    avatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'Expert in classic cuts and fades.',
    services: [
      ServiceModel(id: 's4', name: 'Haircut', price: 55.0, durationMinutes: 45),
      ServiceModel(id: 's5', name: 'Hair Color', price: 80.0, durationMinutes: 90),
    ],
  ),
  const BarberModel(
    id: '3',
    name: 'Jane Smith',
    rating: 4.5,
    avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'Specializing in modern styles and treatments.',
    services: [
      ServiceModel(id: 's6', name: 'Haircut', price: 70.0, durationMinutes: 60),
      ServiceModel(id: 's7', name: 'Styling', price: 50.0, durationMinutes: 30),
    ],
  ),
  const BarberModel(
    id: '4',
    name: 'Mike Johnson',
    rating: 4.2,
    avatarUrl: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'Traditional barbering with a modern touch.',
    services: [
      ServiceModel(id: 's8', name: 'Haircut', price: 45.0, durationMinutes: 30),
      ServiceModel(id: 's9', name: 'Beard Trim', price: 25.0, durationMinutes: 15),
    ],
  ),
];

final List<ServiceModel> mockServices = [
  const ServiceModel(
    id: 's10',
    name: 'Corte de Cabelo',
    durationMinutes: 30,
    price: 40.0,
  ),
  const ServiceModel(
    id: 's11',
    name: 'Barba',
    durationMinutes: 20,
    price: 25.0,
  ),
  const ServiceModel(
    id: 's12',
    name: 'Corte + Barba',
    durationMinutes: 45,
    price: 60.0,
  ),
];

final List<BookingModel> dummyBookings = [
  BookingModel(
    id: '1',
    userId: 'u1',
    barberId: '1',
    serviceId: 's1',
    barber: dummyBarbers[0],
    service: dummyBarbers[0].services[0],
    date: DateTime.now().add(const Duration(days: 1, hours: 2)),
    status: 'upcoming',
  ),
  BookingModel(
    id: '2',
    userId: 'u1',
    barberId: '2',
    serviceId: 's4',
    barber: dummyBarbers[1],
    service: dummyBarbers[1].services[0],
    date: DateTime.now().subtract(const Duration(days: 5)),
    status: 'completed',
  ),
];

final Map<DateTime, List<BarberModel>> dummyBarberAvailability = {
  DateUtils.dateOnly(DateTime.now()): dummyBarbers,
  DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1))): [dummyBarbers[0], dummyBarbers[2]],
  DateUtils.dateOnly(DateTime.now().add(const Duration(days: 2))): [dummyBarbers[1], dummyBarbers[3]],
};

final Map<String, List<String>> dummyTimetable = {
  'Peter the Barber': [
    '09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00', '18:00',
  ],
  'John Doe': [
    '10:00', '11:00', '12:00', '13:00', '15:00',
  ],
  'Jane Smith': []
};
