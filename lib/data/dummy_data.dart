import 'package:flutter/material.dart';

import 'package:na_regua/models/service_model.dart';

import '../models/barber_model.dart';
import '../models/booking_model.dart';

final List<BarberModel> dummyBarbers = [
  const BarberModel(
    name: 'Peter the Barber',
    rating: 4.0,
    location: 'New York, US',
    imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'I am a barber based on NYC',
    services: [
      ServiceModel(name: 'Haircut', price: 60.0, durationMinutes: 30),
      ServiceModel(name: 'Beard Trim', price: 30.0, durationMinutes: 20),
      ServiceModel(name: 'Shave', price: 40.0, durationMinutes: 25),
    ],
  ),
  const BarberModel(
    name: 'John Doe',
    rating: 4.8,
    location: 'Los Angeles, US',
    imageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'Expert in classic cuts and fades.',
    services: [
      ServiceModel(name: 'Haircut', price: 55.0, durationMinutes: 45),
      ServiceModel(name: 'Hair Color', price: 80.0, durationMinutes: 90),
    ],
  ),
  const BarberModel(
    name: 'Jane Smith',
    rating: 4.5,
    location: 'Chicago, US',
    imageUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'Specializing in modern styles and treatments.',
    services: [
      ServiceModel(name: 'Haircut', price: 70.0, durationMinutes: 60),
      ServiceModel(name: 'Styling', price: 50.0, durationMinutes: 30),
    ],
  ),
  const BarberModel(
    name: 'Mike Johnson',
    rating: 4.2,
    location: 'Houston, US',
    imageUrl: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=100&q=80',
    description: 'Traditional barbering with a modern touch.',
    services: [
      ServiceModel(name: 'Haircut', price: 45.0, durationMinutes: 30),
      ServiceModel(name: 'Beard Trim', price: 25.0, durationMinutes: 15),
    ],
  ),
];

final List<BookingModel> dummyBookings = [
  BookingModel(
    id: '1',
    barber: dummyBarbers[0],
    service: dummyBarbers[0].services[0],
    date: DateTime.now().add(const Duration(days: 1, hours: 2)),
    status: 'upcoming',
  ),
  BookingModel(
    id: '2',
    barber: dummyBarbers[1],
    service: dummyBarbers[1].services[0],
    date: DateTime.now().subtract(const Duration(days: 5)),
    status: 'completed',
  ),
];

// map date to barber
final Map<DateTime, List<BarberModel>> dummyBarberAvailability = {
  DateUtils.dateOnly(DateTime.now()): dummyBarbers,
  DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1))): [dummyBarbers[0], dummyBarbers[2]],
  DateUtils.dateOnly(DateTime.now().add(const Duration(days: 2))): [dummyBarbers[1], dummyBarbers[3]],
};

// map barber name to list of available time slots
final Map<String, List<String>> dummyTimetable = {
  'Peter the Barber': [
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ],
  'John Doe': [
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '15:00',
  ],
  'Jane Smith': []
};

final List<ServiceModel> mockServices = [
  const ServiceModel(
    name: 'Corte de Cabelo',
    durationMinutes: 30,
    price: 40.0,
    icon: Icons.content_cut,
  ),
  const ServiceModel(
    name: 'Barba',
    durationMinutes: 20,
    price: 25.0,
    icon: Icons.face,
  ),
  const ServiceModel(
    name: 'Corte + Barba',
    durationMinutes: 45,
    price: 60.0,
    icon: Icons.spa,
  ),
];
