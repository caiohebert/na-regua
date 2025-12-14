import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/widgets/homescreen_quick_actions.dart';
import 'package:na_regua/widgets/no_upcoming_appointments.dart';
import 'package:na_regua/widgets/welcome_back.dart';
import 'package:na_regua/providers/booking_provider.dart';
import 'package:na_regua/widgets/booking_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WelcomeBackWidget(),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                    icon: const Icon(Icons.notifications_outlined),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              HomescreenQuickActionsWidget(),
              
              const SizedBox(height: 24),
              
              // Next Appointment
              Text(
                'Próximo Agendamento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              bookingsAsync.when(
                data: (bookings) {
                  final upcomingBookings = bookings
                      .where((b) => b.status == 'PENDING' || b.status == 'CONFIRMED' || b.status == 'upcoming')
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));

                  if (upcomingBookings.isEmpty) {
                    return const NoUpcomingAppointmentsWidget();
                  }
                  return Column(
                    children: upcomingBookings
                        .map((booking) => BookingCard(booking: booking))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Services
              Text(
                'Serviços Recentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              bookingsAsync.when(
                data: (bookings) {
                  final recentBookings = bookings
                      .where((b) => b.status == 'COMPLETED' || b.status == 'CANCELLED' || (b.status != 'PENDING' && b.status != 'CONFIRMED' && b.status != 'upcoming'))
                      .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

                  if (recentBookings.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'Nenhum serviço realizado ainda',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[400],
                                ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: recentBookings
                        .map((booking) => BookingCard(booking: booking))
                        .toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
