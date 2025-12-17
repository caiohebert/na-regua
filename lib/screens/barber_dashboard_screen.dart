import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/screens/barber_schedule_tab.dart';
import 'package:na_regua/screens/barber_services_tab.dart';
import 'package:na_regua/screens/barber_time_slots_tab.dart';

class BarberDashboardScreen extends ConsumerWidget {
  const BarberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Área do Barbeiro'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.calendar_today),
                text: 'Agenda',
              ),
              Tab(
                icon: Icon(Icons.content_cut),
                text: 'Serviços',
              ),
              Tab(
                icon: Icon(Icons.schedule),
                text: 'Horários',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BarberScheduleTab(),
            BarberServicesTab(),
            BarberTimeSlotsTab(),
          ],
        ),
      ),
    );
  }
}


