import 'dart:io'; // Necessário para manipular o arquivo da imagem
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pacote para pegar a imagem
import 'package:na_regua/screens/welcome_screen.dart';

// Mudamos para StatefulWidget para poder atualizar a imagem na tela
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage; // Variável para guardar a imagem selecionada

  // Função para abrir o seletor de imagem
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
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
                      // Lógica do Avatar
                      GestureDetector(
                        onTap: _showImagePickerOptions, // Permite clicar na foto também
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          // Se tiver imagem, mostra ela. Se não, mostra null (e cai no child)
                          backgroundImage: _selectedImage != null 
                              ? FileImage(_selectedImage!) 
                              : null,
                          // Se NÃO tiver imagem, mostra o ícone de pessoa
                          child: _selectedImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                )
                              : null,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[400],
                ),
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
              
              // Logout Button (Mantido igual)
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