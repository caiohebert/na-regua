import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/screens/admin_schedule_tab.dart';
import 'package:na_regua/screens/admin_services_tab.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.calendar_today),
                text: 'Schedule',
              ),
              Tab(
                icon: Icon(Icons.content_cut),
                text: 'My Services',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminScheduleTab(),
            AdminServicesTab(),
          ],
        ),
      ),
    );
  }
}

