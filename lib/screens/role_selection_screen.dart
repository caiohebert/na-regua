import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/db/db_types.dart';
import 'package:na_regua/db/user_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String _selectedRole = 'customer';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRoleSelection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create a proper `UserRole` value from the selection
      final UserRole role = _selectedRole == 'barber' ? UserRole.barber : UserRole.customer;

      // Update user metadata with the canonical DB role name
      final supabase = Supabase.instance.client;
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'selected_role': role.dbName},
        ),
      );

      // Create user in database with the chosen role (will create barber profile when role == barber)
      await insertUserFromSession(role);

      // Navigation will be handled automatically by AuthenticationWrapper
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Erro ao configurar conta. Por favor, tente novamente.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Icon
              Icon(
                Icons.person_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Tipo de Conta',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Selecione como você vai usar o aplicativo',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // Role selection cards
              Card(
                elevation: _selectedRole == 'customer' ? 4 : 0,
                color: _selectedRole == 'customer'
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: InkWell(
                  onTap: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRole = 'customer';
                          });
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 48,
                          color: _selectedRole == 'customer'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cliente',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'customer'
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agendar cortes e serviços',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: _selectedRole == 'barber' ? 4 : 0,
                color: _selectedRole == 'barber'
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: InkWell(
                  onTap: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRole = 'barber';
                          });
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cut_outlined,
                          size: 48,
                          color: _selectedRole == 'barber'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Barbeiro',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'barber'
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gerenciar agenda e serviços',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRoleSelection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuar'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
