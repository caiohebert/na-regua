import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/providers/navigation_provider.dart';
import 'package:na_regua/providers/services_provider.dart';
import 'package:na_regua/widgets/date_picker_widget.dart';
import 'package:na_regua/widgets/barber_picker.dart';
import 'package:na_regua/widgets/service_card.dart';
import 'package:na_regua/widgets/timetable_widget.dart';
import 'package:na_regua/models/barber_model.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  BarberModel? _selectedBarber;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final showBack = ref.watch(navigationProvider).showBackButton;
    final services = ref.watch(servicesProvider);

    return Scaffold(
      appBar: showBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => ref.read(navigationProvider.notifier).goBack(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Agendar Serviço',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha o serviço e horário desejado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Service Selection
              Text(
                'Selecione o Serviço',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              ...services.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ServiceCard(
                  title: service.name,
                  duration: '${service.durationMinutes} min',
                  price: 'R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: service.icon,
                  onTap: () {},
                ),
              )),
              
              const SizedBox(height: 32),
              
              // Date Selection
              Text(
                'Escolha a Data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DatePickerWidget(
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              
              const SizedBox(height: 32),

              BarberPicker(
                date: _selectedDate,
                onBarberSelected: (barber) => setState(() {
                  _selectedBarber = barber;
                  _selectedTime = null; // Reset time when barber changes
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Time Selection
              if (_selectedBarber != null)
                TimetableWidget(
                  barber: _selectedBarber,
                  date: _selectedDate,
                  onTimeSelected: (time) => setState(() => _selectedTime = time),
                ),
              
              const SizedBox(height: 32),
              
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedTime != null
                      ? () {
                          final barberName = _selectedBarber?.name ?? 'Nenhum barbeiro selecionado';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Agendamento com $barberName às $_selectedTime em desenvolvimento'),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Confirmar Agendamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
