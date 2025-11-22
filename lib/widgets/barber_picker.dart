import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber_model.dart';
import '../providers/barbers_provider.dart';

class BarberPicker extends ConsumerStatefulWidget {
  final DateTime date;
  final ValueChanged<BarberModel> onBarberSelected;

  const BarberPicker({
    super.key,
    required this.date,
    required this.onBarberSelected,
  });

  @override
  ConsumerState<BarberPicker> createState() => _BarberPickerState();
}

class _BarberPickerState extends ConsumerState<BarberPicker> {
  BarberModel? _selectedBarber;

  @override
  Widget build(BuildContext context) {
    final barbers = ref.watch(barbersProvider(widget.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha o Profissional',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...barbers.map((barber) {
          final isSelected = _selectedBarber == barber;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBarber = barber;
              });
              widget.onBarberSelected(barber);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(barber.imageUrl),
                    radius: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barber.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              barber.rating.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                barber.location,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
