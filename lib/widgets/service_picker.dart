import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import 'service_card.dart';

class ServicePicker extends ConsumerStatefulWidget {
  final List<ServiceModel> services;
  final ValueChanged<ServiceModel> onServiceSelected;

  const ServicePicker({
    super.key,
    required this.services,
    required this.onServiceSelected,
  });

  @override
  ConsumerState<ServicePicker> createState() => _ServicePickerState();
}

class _ServicePickerState extends ConsumerState<ServicePicker> {
  ServiceModel? _selectedService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o Serviço',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...widget.services.map((service) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ServiceCard(
            service: service,
            icon: service.icon,
            isSelected: _selectedService == service,
            onTap: () {
              setState(() {
                _selectedService = service;
              });
              widget.onServiceSelected(service);
            },
          ),
        )),
      ],
    );
  }
}
