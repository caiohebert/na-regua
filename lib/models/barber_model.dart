import 'service_model.dart';

class BarberModel {
  final String name;
  final double rating;
  final String location;
  final String imageUrl;
  final String description;
  final List<ServiceModel> services;

  const BarberModel({
    required this.name,
    required this.rating,
    required this.location,
    required this.imageUrl,
    this.description = '',
    this.services = const [],
  });
}
