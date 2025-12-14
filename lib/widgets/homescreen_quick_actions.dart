import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/providers/navigation_provider.dart';

class HomescreenQuickActionsWidget extends ConsumerWidget {
  const HomescreenQuickActionsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.calendar_today,
                  label: 'Agendar',
                  onTap: () {
                    ref.read(navigationProvider.notifier).navigateTo(1, showBackButton: true);
                  },
                ),
                _QuickActionButton(
                  icon: Icons.history,
                  label: 'Histórico',
                  onTap: () {
                    ref.read(navigationProvider.notifier).navigateTo(2, showBackButton: true);
                  },
                ),
                _QuickActionButton(
                  icon: Icons.favorite_outline,
                  label: 'Favoritos',
                  onTap: () {
                    // TODO: Navigate to favorites
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
