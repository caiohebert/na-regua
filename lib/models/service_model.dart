import 'package:flutter/material.dart';

class ServiceModel {
  final String name;
  final double price;
  final int durationMinutes;
  final IconData icon;

  const ServiceModel({
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.icon = Icons.cut, // Default icon
  });
}
