import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../../collections/controllers/collection_controller.dart';
import '../../../shared/widgets/premium_badge.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/profile_controller.dart';
import '../../settings/controllers/theme_controller.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: _showSettingsMenu,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Obx(() {
        final user = AuthController.to.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: _buildAvatarWidget(user), 
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: IconButton(
                                onPressed: _editAvatar,
                                icon: const Icon(Icons.camera_alt, size: 16),
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name and Premium Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getUserDisplayName(user),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const PremiumBadge(),
                        ],
                      ),
                      
                      if (user.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.email!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(() => _buildStatCard(
                            'Seguidores', 
                            ProfileController.to.followersCount.toString()
                          )),
                          Obx(() => _buildStatCard(
                            'Seguindo', 
                            ProfileController.to.followingCount.toString()
                          )),
                          Obx(() => _buildStatCard(
                            'Itens', 
                            ProfileController.to.itemsCount.toString()
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Subscription Card
                    _buildSubscriptionCard(),
                    const SizedBox(height: 16),

                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.collections,
                      title: 'Minhas Coleções',
                      subtitle: 'Gerenciar categorias e itens',
                      onTap: () => Get.toNamed(AppRoutes.home),
                    ),
                    _buildMenuItem(
                      icon: Icons.public,
                      title: 'Feed Social',
                      subtitle: 'Ver atividades da comunidade',
                      onTap: () => Get.toNamed(AppRoutes.feed),
                    ),
                    _buildMenuItem(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      subtitle: 'Estatísticas e relatórios',
                      onTap: () {
                        if (SubscriptionController.to.isPremium.value) {
                          Get.toNamed(AppRoutes.analytics);
                        } else {
                          SubscriptionController.to.showUpgradeDialog();
                        }
                      },
                      isPremium: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.chat,
                      title: 'Conversas',
                      subtitle: 'Chat com outros usuários',
                      onTap: () {
                        if (SubscriptionController.to.isPremium.value) {
                          Get.toNamed(AppRoutes.conversations);
                        } else {
                          SubscriptionController.to.showUpgradeDialog();
                        }
                      },
                      isPremium: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications,
                      title: 'Notificações',
                      subtitle: 'Gerenciar notificações',
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                    ),
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Ajuda e Suporte',
                      subtitle: 'Central de ajuda e contato',
                      onTap: _showHelpCenter,
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Sair',
                      subtitle: 'Fazer logout da conta',
                      onTap: _showLogoutDialog,
                      textColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAvatarWidget(User user) {
    final avatarUrl = user.userMetadata?['avatar_url'];
    
    if (avatarUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.person, size: 50),
        ),
      );
    } else {
      return const Icon(Icons.person, size: 50);
    }
  }

  String _getUserDisplayName(User user) {
    return user.userMetadata?['username'] ?? 
           user.userMetadata?['name'] ?? 
           user.email?.split('@').first ?? 
           'Usuário';
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    return Obx(() {
      final isPremium = SubscriptionController.to.isPremium.value;
      final subscriptionExpiry = SubscriptionController.to.subscriptionExpiry.value;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPremium ? Icons.star : Icons.star_border,
                    color: isPremium ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPremium ? 'Premium Ativo' : 'Versão Gratuita',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (!isPremium)
                    ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoutes.payment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Upgrade'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (isPremium && subscriptionExpiry != null) ...[
                Text(
                  'Renova em ${_formatDate(subscriptionExpiry)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                // CORREÇÃO: Usar progresso da assinatura em vez de categorias
                LinearProgressIndicator(
                  value: _getSubscriptionProgress(subscriptionExpiry),
                  backgroundColor: Colors.amber.shade100,
                  color: Colors.amber,
                ),
              ] else if (!isPremium) ...[
                Text(
                  SubscriptionController.to.getCategoryLimitText(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  SubscriptionController.to.getItemLimitText(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                // Mostrar progresso dos limites para usuários gratuitos
                LinearProgressIndicator(
                  value: CollectionController.to.categories.length / AppConstants.freeCategoriesLimit,
                  backgroundColor: Colors.orange.shade100,
                  color: Colors.orange,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
    Color? textColor,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (isPremium && !SubscriptionController.to.isPremium.value) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 16, color: Colors.amber),
            ],
          ],
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference <= 0) {
      return 'Expirado';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference < 30) {
      return '$difference dias';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  double _getSubscriptionProgress(DateTime expiry) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = expiry;
    final total = end.difference(start).inDays;
    final remaining = end.difference(now).inDays;
    
    if (total <= 0) return 0.0;
    return (total - remaining) / total;
  }

  void _editAvatar() async {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    
    if (image != null) {
      // TODO: Upload image and update profile
      Get.snackbar('Info', 'Upload de avatar em desenvolvimento');
    }
  }

  // Método para obter o widget do avatar
  /*Widget _getAvatarWidget(User user) {
    final avatarUrl = user.userMetadata?['avatar_url'];
    
    if (avatarUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.person, size: 50),
        ),
      );
    } else {
      return const Icon(Icons.person, size: 50);
    }
  }*/

  

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
            'Configurações',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Adicionar o seletor de tema aqui
            _buildThemeSelector(),
            
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.pop(context);
                _showEditProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Privacidade'),
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Tema'),
              onTap: () {
                Navigator.pop(context);
                _showThemeSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final controller = Get.put(ThemeController());
    
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tema do App:', style: TextStyle(fontWeight: FontWeight.bold)),
        RadioListTile<ThemeMode>(
          title: const Text('Claro'),
          value: ThemeMode.light,
          groupValue: controller.selectedTheme.value,
          onChanged: (value) => controller.changeTheme(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Escuro'),
          value: ThemeMode.dark,
          groupValue: controller.selectedTheme.value,
          onChanged: (value) => controller.changeTheme(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Sistema'),
          value: ThemeMode.system,
          groupValue: controller.selectedTheme.value,
          onChanged: (value) => controller.changeTheme(value!),
        ),
      ],
    ));
  }

  void _showEditProfile() {
    final user = AuthController.to.currentUser.value!;
    final usernameController = TextEditingController( text: user.userMetadata?['username'] ?? '');
    final emailController = TextEditingController(text: user.email);

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Nome de usuário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthController.to.updateProfile(
                username: usernameController.text.trim(),
                email: emailController.text.trim(),
              );
              Get.back();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Configurações de Privacidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Perfil público'),
              subtitle: const Text('Outros usuários podem ver seu perfil'),
              value: true, // TODO: Get from user settings
              onChanged: (value) {
                // TODO: Update privacy settings
              },
            ),
            SwitchListTile(
              title: Text('Mostrar itens públicos'),
              subtitle: Text('Seus itens públicos aparecem no feed'),
              value: true, // TODO: Get from user settings
              onChanged: (value) {
                // TODO: Update privacy settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings() {
    Get.dialog(
      AlertDialog(
        title: const  Text('Tema do App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              subtitle: const Text('Seguir configuração do sistema'),
              value: ThemeMode.system,
              groupValue: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              onChanged: (value) {
                Get.changeThemeMode(ThemeMode.system);
                Get.back();
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('Claro'),
              value: ThemeMode.light,
              groupValue: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              onChanged: (value) {
                Get.changeThemeMode(ThemeMode.light);
                Get.back();
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('Escuro'),
              value: ThemeMode.dark,
              groupValue: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              onChanged: (value) {
                Get.changeThemeMode(ThemeMode.dark);
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    Get.dialog(
      AlertDialog(
        title: const Text('Ajuda e Suporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const  Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('suporte@mycollection.app'),
              onTap: () {
                // TODO: Open email app
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat ao vivo'),
              subtitle: const Text('Disponível 24/7'),
              onTap: () {
                // TODO: Open chat support
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_center),
              title: const Text('Central de Ajuda'),
              subtitle: const Text('FAQ e tutoriais'),
              onTap: () {
                // TODO: Open help center
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              AuthController.to.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
