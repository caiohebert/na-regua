import 'dart:io'; // Necessário para manipular o arquivo da imagem

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Pacote para pegar a imagem
import 'package:na_regua/auth_provider.dart';
import 'package:na_regua/db/user_db.dart';
import 'package:na_regua/providers/barber_profile_provider.dart';
import 'package:na_regua/providers/navigation_provider.dart';
import 'package:na_regua/providers/user_role_provider.dart';
import 'package:na_regua/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mudamos para StatefulWidget para poder atualizar a imagem na tela
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImage; // Variável para guardar a imagem selecionada
  bool _isUploadingImage = false;
  bool _isPromoting = false;
  String? _barberError;
  bool _barberFieldsInitialized = false;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de imagem
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        final imageFile = File(image.path);

        setState(() {
          _selectedImage = imageFile;
        });

        // CHAMA O UPLOAD IMEDIATAMENTE
        await _uploadAndSaveImage(imageFile);
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  // Função que mostra o menu (Câmera ou Galeria)
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context); // Fecha o menu
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context); // Fecha o menu
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAndSaveImage(File imageFile) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // pega a URL atual salva nos metadados do usuario/banco
      final oldAvatarUrl =
          supabase.auth.currentUser?.userMetadata?['avatar_url'] as String?;

      if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
        try {
          final pathParts = oldAvatarUrl.split('/media/');

          // Só tenta apagar se conseguiu extrair o caminho corretamente
          if (pathParts.length > 1) {
            final oldPath = pathParts.last;
            await supabase.storage.from('media').remove([oldPath]);
            print("Foto antiga apagada: $oldPath");
          }
        } catch (e) {
          // Se der erro ao apagar a antiga, apenas logamos e continuamos o upload da nova
          print("Aviso: Não foi possível apagar a foto antiga. $e");
        }
      }

      // prepara nome do arquivo
      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = 'users/avatars/$userId/$fileName';

      // envia para o Storage (Bucket 'files')
      await supabase.storage
          .from('media')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // pega a url publica do supa
      final imageUrl = supabase.storage.from('media').getPublicUrl(filePath);

      // atualiza o campo de url da tabela users
      await supabase
          .from('users')
          .update({
            'avatar_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // atualiza metadados do Auth para refletir em outros lugares do app sem refresh
      await supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _askBecomeBarber() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quer deixar as pessoas na Régua?'),
        content: const Text(
          'Ao aceitar, você terá acesso ao Dashboard de Barbeiro para gerenciar agenda e serviços.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quero ser barbeiro'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isPromoting = true;
      _barberError = null;
    });

    try {
      await promoteUserToAdminBarber();
      if (!mounted) return;

      // Refresh role-dependent UI and send user to dashboard tab
      ref.invalidate(userRoleProvider);
      ref.invalidate(isBarberProvider);
      ref.read(navigationProvider.notifier).setIndex(0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado para Barbeiro!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _barberError = 'Não foi possível atualizar. Tente novamente. ($e)';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPromoting = false;
        });
      }
    }
  }

  Future<void> _saveBarberSettings() async {
    setState(() {
      _barberError = null;
      _isPromoting = true;
    });

    try {
      await updateBarberProfile(
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );

      if (mounted) {
        ref.invalidate(barberProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _barberError = 'Erro ao salvar. ($e)';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPromoting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = (user?.userMetadata?['full_name'] as String?)?.trim();
    final displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (user?.email ?? 'Usuário');
    final isBarberAsync = ref.watch(isBarberProvider);
    final barberProfileAsync = ref.watch(barberProfileProvider);
    final remoteAvatarUrl = user?.userMetadata?['avatar_url'] as String?;

    if (barberProfileAsync.hasValue &&
        barberProfileAsync.value != null &&
        !_barberFieldsInitialized) {
      final data = barberProfileAsync.value!;
      _descriptionController.text = (data['description'] ?? '') as String;
      _locationController.text = (data['location'] ?? '') as String;
      _imageUrlController.text = (data['image_url'] ?? '') as String;
      _barberFieldsInitialized = true;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),

              const SizedBox(height: 32),

              // Profile Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Lógica do Avatar
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              // Lógica de Prioridade da Imagem:
                              // 1º: Foto nova que o usuário acabou de tirar (Preview local)
                              // 2º: Foto salva no banco de dados (URL)
                              // 3º: Null (para cair no child e mostrar o ícone)
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : (remoteAvatarUrl != null &&
                                            remoteAvatarUrl.isNotEmpty
                                        ? NetworkImage(remoteAvatarUrl)
                                        : null),

                              // Se não tiver imagem nenhuma (nem local, nem remota), mostra o ícone
                              child:
                                  (_selectedImage == null &&
                                      (remoteAvatarUrl == null ||
                                          remoteAvatarUrl.isEmpty))
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    )
                                  : null,
                            ),

                            // Spinner de carregamento (Aparece só quando _isUploadingImage for true)
                            if (_isUploadingImage)
                              const SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      // Botão de alterar foto (Substituindo o antigo edit profile)
                      IconButton(
                        onPressed: _showImagePickerOptions,
                        icon: const Icon(Icons.camera_alt_outlined),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Alterar foto',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Account Section
              Text(
                'Conta',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 12),

              if (_barberError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _barberError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              isBarberAsync.maybeWhen(
                data: (isBarber) {
                  if (!isBarber) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quer deixar as pessoas na Régua?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vire barbeiro para gerenciar agenda, confirmar clientes e cadastrar serviços.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isPromoting
                                    ? null
                                    : _askBecomeBarber,
                                icon: _isPromoting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.cut_outlined),
                                label: Text(
                                  _isPromoting
                                      ? 'Atualizando...'
                                      : 'Ativar dashboard de barbeiro',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Barber settings
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configurações NaRégua',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Atualize seu perfil de barbeiro. Todos os campos são opcionais.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Fale sobre você e seus serviços',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Localização',
                              hintText: 'Bairro, cidade...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL da imagem',
                              hintText: 'https://...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isPromoting
                                  ? null
                                  : _saveBarberSettings,
                              icon: _isPromoting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _isPromoting ? 'Salvando...' : 'Salvar',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              _ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Editar Dados',
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

              // App Section (Mantido igual)
              Text(
                'Aplicativo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
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

              // Logout Button (Mantido igual)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sair'),
                        content: const Text(
                          'Deseja realmente sair da sua conta?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await ref.read(authProvider.notifier).signOut();
                              if (!context.mounted) return;
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

// Widget auxiliar mantido igual
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
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
