import 'package:flutter/material.dart';

class NoUpcomingAppointmentsWidget extends StatelessWidget {
  const NoUpcomingAppointmentsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum agendamento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agende seu próximo corte',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to schedule
              },
              child: const Text('Agendar Agora'),
            ),
          ],
        ),
      ),
    );
  }
}
