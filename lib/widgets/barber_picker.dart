import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber_model.dart';
import '../providers/barbers_provider.dart';
import 'barber_card.dart';

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
    final barbersAsync = ref.watch(barbersProvider(widget.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha o Profissional',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        barbersAsync.when(
          data: (barbers) => Column(
            children: barbers.map((barber) {
              final isSelected = _selectedBarber?.id == barber.id;
              return BarberCard(
                barber: barber,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedBarber = barber;
                  });
                  widget.onBarberSelected(barber);
                },
              );
            }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ],
    );
  }
}
