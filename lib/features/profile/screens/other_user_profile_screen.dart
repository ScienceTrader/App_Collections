// ============================================
// FILE: lib/features/profile/screens/other_user_profile_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/item_model.dart';
import '../../social/controllers/social_controller.dart';
//import '../../auth/controllers/auth_controller.dart';
import '../../collections/widgets/item_card.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _isLoading = false.obs;
  final _userProfile = Rxn<UserModel>();
  final _userItems = <ItemModel>[].obs;
  final _followersCount = 0.obs;
  final _followingCount = 0.obs;
  final _itemsCount = 0.obs;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    _loadUserItems();
    _loadUserStats();
  }

  Future<void> _loadUserProfile() async {
    try {
      _isLoading.value = true;
      
      final profileData = await SupabaseService.getUserProfile(widget.userId);
      if (profileData != null) {
        _userProfile.value = UserModel.fromJson(profileData);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar perfil: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadUserItems() async {
    try {
      final items = await SupabaseService.getItems(userId: widget.userId);
      _userItems.value = items.where((item) => item.isPublic).toList();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar itens: ${e.toString()}');
    }
  }

  Future<void> _loadUserStats() async {
    try {
      _followersCount.value = await SupabaseService.getFollowersCount(widget.userId);
      _followingCount.value = await SupabaseService.getFollowingCount(widget.userId);
      _itemsCount.value = await SupabaseService.getUserItemsCount(widget.userId);
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_isLoading.value && _userProfile.value == null) {
          return Center(child: CircularProgressIndicator());
        }

        final user = _userProfile.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Perfil não encontrado'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Voltar'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildUserHeader(user),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Itens (${_userItems.length})'),
                    Tab(text: 'Sobre'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItemsTab(),
                  _buildAboutTab(user),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUserHeader(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatarUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.person, size: 50),
                        ),
                      )
                    : Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                user.username ?? user.email ?? 'Usuário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (user.bio != null) ...[
                SizedBox(height: 8),
                Text(
                  user.bio!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Itens', _itemsCount.value.toString()),
                  _buildStatCard('Seguidores', _followersCount.value.toString()),
                  _buildStatCard('Seguindo', _followingCount.value.toString()),
                ],
              ),
              SizedBox(height: 16),
              _buildFollowButton(user.id!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(String userId) {
    return Obx(() {
      final isFollowing = SocialController.to.followingStatus[userId] ?? false;
      final isLoading = SocialController.to.isLoading.value;

      return ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                if (isFollowing) {
                  await SocialController.to.unfollowUser(userId);
                } else {
                  await SocialController.to.followUser(userId);
                }
                _loadUserStats();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.grey : Colors.white,
          foregroundColor: isFollowing ? Colors.white : Theme.of(context).primaryColor,
          minimumSize: Size(200, 40),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowing ? Icons.person_remove : Icons.person_add,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(isFollowing ? 'Deixar de Seguir' : 'Seguir'),
                ],
              ),
      );
    });
  }

  Widget _buildItemsTab() {
    return Obx(() {
      if (_userItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Nenhum item público'),
              Text(
                'Este usuário ainda não compartilhou nenhum item',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadUserItems,
        child: MasonryGridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(16),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: _userItems.length,
          itemBuilder: (context, index) {
            final item = _userItems[index];
            return ItemCard(
              item: item,
              onVisibilityToggle: () {},
              onDelete: () {},
            );
          },
        ),
      );
    });
  }

  Widget _buildAboutTab(UserModel user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Informações',
            [
              _buildInfoRow(Icons.person, 'Usuário', user.username ?? 'Não informado'),
              _buildInfoRow(Icons.email, 'Email', user.email ?? 'Não informado'),
              if (user.bio != null)
                _buildInfoRow(Icons.info, 'Biografia', user.bio!),
              _buildInfoRow(
                Icons.calendar_today,
                'Membro desde',
                _formatDate(user.createdAt),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            'Estatísticas',
            [
              _buildInfoRow(Icons.inventory, 'Total de Itens', _itemsCount.value.toString()),
              _buildInfoRow(Icons.people, 'Seguidores', _followersCount.value.toString()),
              _buildInfoRow(Icons.person_add, 'Seguindo', _followingCount.value.toString()),
            ],
          ),
          if (user.subscriptionTier == 'premium') ...[
            SizedBox(height: 16),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usuário Premium',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          Text(
                            'Este usuário possui recursos premium',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareProfile(user),
              icon: Icon(Icons.share),
              label: Text('Compartilhar Perfil'),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _reportUser(user),
              icon: Icon(Icons.flag, color: Colors.red),
              label: Text('Denunciar Usuário', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informado';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "mês" : "meses"} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "ano" : "anos"} atrás';
    }
  }

  void _shareProfile(UserModel user) {
    final profileUrl = 'https://mycollection.app/user/${user.id}';
    final message = 'Confira o perfil de ${user.username ?? "este usuário"} no My Collection!\n$profileUrl';
    Share.share(message);
  }

  void _reportUser(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: Text('Denunciar Usuário'),
        content: Text('Tem certeza que deseja denunciar este usuário?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Denúncia Enviada',
                'Obrigado por ajudar a manter nossa comunidade segura',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Denunciar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}