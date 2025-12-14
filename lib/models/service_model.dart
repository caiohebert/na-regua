import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String? description;
  final int durationMinutes; // minutes
  final double price;
  final String? coverUrl;

  // Helper for UI compatibility if needed
  // TODO allow services to have different icons?
  IconData get icon => Icons.cut; 

  const ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    this.coverUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration'] as int,
      price: (json['price'] as num).toDouble(),
      coverUrl: json['cover'] as String?,
    );
  }
}
