import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../../shared/models/user_model.dart';
import '../../social/controllers/social_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class UserSuggestionCard extends StatelessWidget {
  final UserModel user;
  
  const UserSuggestionCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade300,
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      )
                    : Icon(Icons.person),
              ),
              SizedBox(height: 8),
              Text(
                user.username ?? user.email ?? 'Usuário',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                '${user.itemsCount} itens',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 4),
              Obx(() {
                final isFollowing = SocialController.to.followingStatus[user.id] ?? false;
                final isCurrentUser = AuthController.to.currentUser.value?.id == user.id;
                
                if (isCurrentUser) return SizedBox();
                
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFollowing
                        ? () => SocialController.to.unfollowUser(user.id!)
                        : () => SocialController.to.followUser(user.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                      minimumSize: Size(0, 28),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      isFollowing ? 'Seguindo' : 'Seguir',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}