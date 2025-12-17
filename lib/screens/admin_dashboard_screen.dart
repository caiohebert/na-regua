import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/screens/admin_user_management_screen.dart';
import 'package:na_regua/screens/admin_services_tab.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.group), text: 'Usuários'),
              Tab(icon: Icon(Icons.content_cut), text: 'Serviços'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminUserManagementScreen(),
            AdminServicesTab(),
          ],
        ),
      ),
    );
  }
}
