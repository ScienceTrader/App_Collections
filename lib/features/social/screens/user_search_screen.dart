import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/social_controller.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  final _searchResults = <UserModel>[].obs;
  final _isSearching = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar usuários...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade600),
          ),
          onChanged: _onSearchChanged,
          autofocus: true,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_searchController.text.isEmpty) {
                return _buildSuggestedUsers();
              }

              if (_searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum usuário encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      Text(
                        'Tente uma busca diferente',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return UserListTile(user: user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUsers() {
    return Obx(() {
      final suggestedUsers = SocialController.to.suggestedUsers;
      
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Usuários sugeridos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (suggestedUsers.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Carregando sugestões...'),
                ],
              ),
            )
          else
            ...suggestedUsers.map((user) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: UserListTile(user: user),
            )).toList(),
        ],
      );
    });
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _searchResults.clear();
      return;
    }

    _performSearch(value);
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return;

    try {
      _isSearching.value = true;
      final results = await SocialController.to.searchUsers(query);
      _searchResults.assignAll(results);
    } finally {
      _isSearching.value = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class UserListTile extends StatelessWidget {
  final UserModel user;
  
  const UserListTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFollowing = SocialController.to.followingStatus[user.id] ?? false;
      final isCurrentUser = AuthController.to.currentUser.value?.id == user.id;
      
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: user.avatarUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.avatarUrl!,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  )
                : Icon(Icons.person),
          ),
          title: Text(user.username ?? user.email ?? 'Usuário'),
          subtitle: Text('${user.itemsCount} itens • ${user.followersCount} seguidores'),
          trailing: isCurrentUser 
              ? null 
              : ElevatedButton(
                  onPressed: isFollowing
                      ? () => SocialController.to.unfollowUser(user.id!)
                      : () => SocialController.to.followUser(user.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                    minimumSize: Size(80, 32),
                  ),
                  child: Text(
                    isFollowing ? 'Seguindo' : 'Seguir',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
          onTap: () => _showUserProfile(user),
        ),
      );
    });
  }

  void _showUserProfile(UserModel user) {
    // TODO: Navigate to user profile screen
    Get.snackbar('Info', 'Perfil de ${user.username ?? "usuário"}');
  }
}
