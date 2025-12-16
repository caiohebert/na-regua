import 'service_model.dart';

class BarberModel {
  final String id;
  final String name;
  final String? description;
  final double? rating;
  final String? avatarUrl;
  final String? imageUrl;
  final String? location;
  final List<ServiceModel> services;

  // Compatibility getters

  const BarberModel({
    required this.id,
    required this.name,
    this.description,
    this.rating,
    this.avatarUrl,
    this.imageUrl,
    this.location,
    this.services = const [],
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userRef = json['users'];
    return BarberModel(
      id: json['id'] as String,
      name: userRef['name']! as String,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'] as String?,
      imageUrl: json['image_url'] as String?,
      location: json['location'] as String?,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
