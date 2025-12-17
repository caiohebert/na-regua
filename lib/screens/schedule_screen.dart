import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/booking_db.dart';
import 'package:na_regua/models/service_model.dart';
import 'package:na_regua/providers/barbers_provider.dart';
import 'package:na_regua/providers/booking_provider.dart';
import 'package:na_regua/providers/navigation_provider.dart';
import 'package:na_regua/providers/services_provider.dart';
import 'package:na_regua/providers/timetable_provider.dart';
import 'package:na_regua/utils/date.dart';
import 'package:na_regua/widgets/date_picker.dart';
import 'package:na_regua/widgets/barber_picker.dart';
import 'package:na_regua/widgets/service_picker.dart';
import 'package:na_regua/widgets/timetable.dart';
import 'package:na_regua/models/barber_model.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  ServiceModel? _selectedService;
  DateTime _selectedDate = DateTime.now();
  BarberModel? _selectedBarber;
  String? _selectedTime;

  bool get isFormComplete {
    return _selectedService != null &&
        _selectedBarber != null &&
        _selectedTime != null;
  }

  @override
  Widget build(BuildContext context) {
    final showBack = ref.watch(navigationProvider).showBackButton;
    final servicesAsync = ref.watch(servicesProvider);

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
              
              servicesAsync.when(
                data: (services) => ServicePicker(
                  services: services,
                  onServiceSelected: (service) => setState(() {
                    _selectedService = service;
                    _selectedBarber = null;
                    _selectedTime = null;
                  }),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
              
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

              if (_selectedService == null) ...[
                Text(
                  'Selecione um serviço primeiro',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Escolha um serviço para ver os profissionais disponíveis nessa data.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ] else ...[
                BarberPicker(
                  date: _selectedDate,
                  selectedService: _selectedService,
                  onBarberSelected: (barber) => setState(() {
                    _selectedBarber = barber;
                    _selectedTime = null; // Reset time when barber changes
                  }),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Time Selection
              if (_selectedBarber != null)
                TimetableWidget(
                  barber: _selectedBarber,
                  date: _selectedDate,
                  serviceDurationMinutes: _selectedService?.durationMinutes,
                  onTimeSelected: (time) => setState(() => _selectedTime = time),
                ),
              
              const SizedBox(height: 32),
              
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFormComplete
                      ? () async {
                        // form is complete so parameters should never be null
                        await createBooking(
                          _selectedService!,
                          _selectedBarber!,
                          getDate(_selectedDate),
                          _selectedTime!
                        );

                        // Refresh shared bookings data (Home + Bookings screens)
                        ref.invalidate(bookingsProvider);

                        // Refresh availability for the selected day/barber
                        ref.invalidate(barbersProvider(BarbersParams(date: _selectedDate, serviceId: _selectedService?.id)));
                        ref.invalidate(
                          timetableProvider(
                            TimetableParams(barber: _selectedBarber, date: _selectedDate),
                          ),
                        );

                        final barberName = _selectedBarber!.name;
                        final serviceName = _selectedService!.name;
                        // flutter analyze complains without this if, don't know why
                        // see https://stackoverflow.com/questions/68871880/do-not-use-buildcontexts-across-async-gaps for fix
                        if (context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Agendamento de $serviceName com $barberName às $_selectedTime realizado'),
                            ),
                          );
                        }
                        // return to home screen
                        ref.read(navigationProvider.notifier).goBack();
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
