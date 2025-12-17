import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/providers/services_provider.dart';
import 'package:na_regua/providers/admin_provider.dart';
import 'package:na_regua/db/admin_db.dart';

class BarberServicesTab extends ConsumerWidget {
  const BarberServicesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final barberServicesAsync = ref.watch(barberServicesProvider);

    return Scaffold(
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.content_cut, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum serviço disponível',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // barberServicesAsync provides the set of service ids this barber offers
          return barberServicesAsync.when(
            data: (selectedIds) {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected = selectedIds.contains(service.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.content_cut, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (service.description != null && service.description!.isNotEmpty)
                            Text(service.description!, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${service.durationMinutes} min', style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(width: 16),
                              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                              Text('\$${service.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (v) async {
                          try {
                            if (v == true) {
                              await addServiceToCurrentBarber(service.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço adicionado'), backgroundColor: Colors.green));
                            } else {
                              await removeServiceFromCurrentBarber(service.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço removido'), backgroundColor: Colors.orange));
                            }
                            ref.invalidate(barberServicesProvider);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                          }
                        },
                      ),
                      onTap: () async {
                        // toggle
                        final newValue = !isSelected;
                        try {
                          if (newValue) {
                            await addServiceToCurrentBarber(service.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço adicionado'), backgroundColor: Colors.green));
                          } else {
                            await removeServiceFromCurrentBarber(service.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço removido'), backgroundColor: Colors.orange));
                          }
                          ref.invalidate(barberServicesProvider);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Erro ao carregar serviços do barbeiro: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar serviços: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

