import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber_model.dart';
import '../providers/timetable_provider.dart';

class TimetableWidget extends ConsumerStatefulWidget {
  final BarberModel? barber;
  final DateTime date;
  final ValueChanged<String> onTimeSelected;

  const TimetableWidget({
    super.key,
    required this.barber,
    required this.date,
    required this.onTimeSelected,
  });

  @override
  ConsumerState<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends ConsumerState<TimetableWidget> {
  String? _selectedTime;

  @override
  void didUpdateWidget(covariant TimetableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.barber != widget.barber || oldWidget.date != widget.date) {
      setState(() {
        _selectedTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(
      timetableProvider(
        TimetableParams(barber: widget.barber, date: widget.date),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horários Disponíveis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        timetableAsync.when(
          data: (times) {
            if (times.isEmpty) {
              return const Text('Nenhum horário disponível.');
            }
            times.sort();
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: times.map((time) {
                final isSelected = _selectedTime == time;
                return FilterChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTime = selected ? time : null;
                    });
                    if (selected) {
                      widget.onTimeSelected(time);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Erro ao carregar horários: $err'),
        ),
      ],
    );
  }
}
