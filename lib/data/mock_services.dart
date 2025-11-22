import 'package:flutter/material.dart';
import '../models/service_model.dart';

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
