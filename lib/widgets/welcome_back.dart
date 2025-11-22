import 'package:flutter/material.dart';

class WelcomeBackWidget extends StatelessWidget {
  const WelcomeBackWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá! 👋',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Bem-vindo de volta',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
