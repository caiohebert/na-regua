import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/screens/home_screen.dart';
import 'package:na_regua/screens/barber_dashboard_screen.dart';
import 'package:na_regua/screens/schedule_screen.dart';
import 'package:na_regua/screens/profile_screen.dart';
import 'package:na_regua/screens/bookings_screen.dart';
import 'package:na_regua/providers/navigation_provider.dart';
import 'package:na_regua/providers/user_role_provider.dart';
import 'package:na_regua/screens/admin_dashboard_screen.dart';
import 'package:na_regua/db/db_types.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final currentIndex = navState.index;

    return _buildClientScaffold(
      context,
      ref,
      currentIndex,
      showBarberAdminAccess: false,
    );
  }

  Widget _buildClientScaffold(
    BuildContext context,
    WidgetRef ref,
    int currentIndex, {
    bool showBarberAdminAccess = false,
  }) {
    final userRoleAsync = ref.watch(userRoleProvider);
    return userRoleAsync.when(
      data: (role) {
        final List<Widget> screens = [
          HomeScreen(showBarberAdminAccess: showBarberAdminAccess),
          const ScheduleScreen(),
          const BookingsScreen(),
          const ProfileScreen(),
        ];

        final List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Agendamentos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ];

        if (role == UserRole.admin) {
          // append admin dashboard (users + services) and nav item
          screens.add(const AdminDashboardScreen());
          items.add(const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ));
        }

        if (role == UserRole.barber) {
          // append barber dashboard screen and nav item
          screens.add(const BarberDashboardScreen());
          items.add(const BottomNavigationBarItem(
            icon: Icon(Icons.content_cut_outlined),
            activeIcon: Icon(Icons.content_cut),
            label: 'Barbeiro',
          ));
        }

        final safeIndex = (currentIndex < 0 || currentIndex >= screens.length) ? 0 : currentIndex;

        return Scaffold(
          body: screens[safeIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: (index) {
              ref.read(navigationProvider.notifier).setIndex(index);
            },
            items: items,
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Erro ao carregar role: $e'))),
    );
  }
}

