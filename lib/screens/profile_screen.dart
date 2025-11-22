import 'package:flutter/material.dart';
import 'package:na_regua/screens/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Perfil',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 32),
              
              // Profile Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usuário',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'usuario@email.com',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Edit profile
                        },
                        icon: const Icon(Icons.edit),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Account Section
              Text(
                'Conta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              
              _ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Editar Perfil',
                onTap: () {
                  // TODO: Navigate to edit profile
                },
              ),
              _ProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Alterar Senha',
                onTap: () {
                  // TODO: Navigate to change password
                },
              ),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notificações',
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
              
              const SizedBox(height: 24),
              
              // App Section
              Text(
                'Aplicativo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              
              _ProfileMenuItem(
                icon: Icons.history,
                title: 'Histórico de Serviços',
                onTap: () {
                  // TODO: Navigate to service history
                },
              ),
              _ProfileMenuItem(
                icon: Icons.favorite_outline,
                title: 'Favoritos',
                onTap: () {
                  // TODO: Navigate to favorites
                },
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Ajuda e Suporte',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'Sobre',
                onTap: () {
                  // TODO: Navigate to about
                },
              ),
              
              const SizedBox(height: 24),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sair'),
                        content: const Text('Deseja realmente sair da sua conta?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da Conta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

