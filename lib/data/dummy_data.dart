import '../models/barber_model.dart';
import '../models/service_model.dart';
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
    status: 'canceled',
  ),
  BookingModel(
    id: '2',
    barber: dummyBarbers[1],
    service: dummyBarbers[1].services[0],
    date: DateTime.now().subtract(const Duration(days: 5)),
    status: 'completed',
  ),
];
