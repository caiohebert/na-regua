import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/providers/admin_provider.dart';
import 'package:na_regua/providers/user_role_provider.dart';
import 'package:na_regua/db/db_types.dart';
import 'package:na_regua/db/user_db.dart';
import 'package:na_regua/widgets/user_card.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(userRoleProvider);
    return roleAsync.when(
      data: (role) {
        if (role != UserRole.admin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gerenciamento de Usuários')),
            body: const Center(child: Text('Acesso negado: apenas admins')),
          );
        }

        final adminsAsync = ref.watch(adminsProvider);
        final barbersAsync = ref.watch(barbersProvider);
        final searchAsync = ref.watch(allUsersProvider(_searchQuery));

        return Scaffold(
          appBar: AppBar(title: const Text('Admin - Gerenciar Usuários')),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nome ou email',
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _searchQuery.isEmpty
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                child: Text('Admins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              adminsAsync.when(
                                data: (admins) => admins.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                                        child: Text('Nenhum admin encontrado.'),
                                      )
                                    : Column(
                                        children: admins.map((u) {
                                          return UserCard(
                                            name: u['name'],
                                            email: u['email'],
                                            trailing: _roleDropdown(u),
                                          );
                                        }).toList(),
                                      ),
                                loading: () => const Center(child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(),
                                )),
                                error: (e, st) => Padding(
                                    padding: const EdgeInsets.all(12.0), child: Text('Erro: $e')),
                              ),
                              const SizedBox(height: 12),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                child: Text('Barbeiros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              barbersAsync.when(
                                data: (barbers) => barbers.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                                        child: Text('Nenhum barbeiro encontrado.'),
                                      )
                                    : Column(
                                        children: barbers.map((u) {
                                          return UserCard(
                                            name: u['name'],
                                            email: u['email'],
                                            trailing: _roleDropdown(u),
                                          );
                                        }).toList(),
                                      ),
                                loading: () => const Center(child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(),
                                )),
                                error: (e, st) => Padding(
                                    padding: const EdgeInsets.all(12.0), child: Text('Erro: $e')),
                              ),
                            ],
                          ),
                        )
                      : searchAsync.when(
                          data: (results) => results.isEmpty
                              ? const Center(child: Text('Nenhum usuário encontrado para essa busca.'))
                              : ListView.builder(
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final u = results[index];
                                    return UserCard(
                                      name: u['name'],
                                      email: u['email'],
                                      trailing: _roleDropdown(u),
                                    );
                                  },
                                ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(child: Text('Erro: $e')),
                        ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }

  Widget _roleDropdown(Map<String, dynamic> u) {
    // Normalize DB role to lowercase token used by dropdown values
    final currentRaw = (u['type'] as String?) ?? UserRole.customer.dbName;
    final current = currentRaw.toLowerCase();
    return DropdownButton<String>(
      value: current,
      items: const [
        DropdownMenuItem(value: 'customer', child: Text('Cliente')),
        DropdownMenuItem(value: 'barber', child: Text('Barbeiro')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
      ],
      onChanged: (val) async {
        if (val == null) return;
        final role = val == 'admin' ? UserRole.admin : val == 'barber' ? UserRole.barber : UserRole.customer;
        try {
          final userId = u['id'] as String?;
          if (userId == null || userId.isEmpty) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro: user id inválido')),
            );
            return;
          }

          final previousRaw = (u['type'] as String?) ?? UserRole.customer.dbName;
          final previous = previousRaw.toLowerCase();

          debugPrint('Admin changing role for userId=$userId from $previous to ${role.dbName}');

          // If promoting to barber, use helper; if demoting from barber, use demote helper
          if (role == UserRole.barber) {
            await promoteUserToBarberById(userId);
          } else {
            if (previous == UserRole.barber.dbName.toLowerCase()) {
              await demoteBarberById(userId, role);
            } else {
              await updateUserRoleForUser(userId, role);
            }
          }

          ref.invalidate(adminsProvider);
          ref.invalidate(barbersProvider);
          if (_searchQuery.isNotEmpty) {
            ref.invalidate(allUsersProvider(_searchQuery));
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role de ${u['name'] ?? ''} alterada para ${role.dbName}')),
          );
        } catch (e, st) {
          debugPrint('Erro ao atualizar role para usuario ${u['id']}: $e\n$st');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar role: $e'), backgroundColor: Colors.redAccent),
          );
        }
      },
    );
  }
}
