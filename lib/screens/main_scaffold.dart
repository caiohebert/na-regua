import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/screens/home_screen.dart';
import 'package:na_regua/screens/schedule_screen.dart';
import 'package:na_regua/screens/profile_screen.dart';
import 'package:na_regua/screens/bookings_screen.dart';
import 'package:na_regua/providers/navigation_provider.dart';
import 'package:na_regua/providers/user_role_provider.dart';
import 'package:na_regua/screens/admin_user_management_screen.dart';
import 'package:na_regua/db/db_types.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final currentIndex = navState.index;
    final isBarberAsync = ref.watch(isBarberProvider);

    return isBarberAsync.when(
      data: (isBarber) {
        // Barbers now share the same main nav as clients; the Home tab will
        // surface a card to access the Admin Dashboard.
        return _buildClientScaffold(
          context,
          ref,
          currentIndex,
          showBarberAdminAccess: isBarber,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading user data: $error'),
            ],
          ),
        ),
      ),
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
          // append admin management screen and nav item
          screens.add(const AdminUserManagementScreen());
          items.add(const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
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

