import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/feed_item_model.dart';
import '../controllers/feed_controller.dart';
import '../../sharing/controllers/share_controller.dart';
import '../../social/controllers/social_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class EnhancedFeedItemCard extends StatelessWidget {
  final FeedItemModel feedItem;

  const EnhancedFeedItemCard({Key? key, required this.feedItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showUserProfile(),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    child: feedItem.user.avatarUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: feedItem.user.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : Icon(Icons.person, size: 20),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _showUserProfile(),
                        child: Text(
                          feedItem.user.username ?? feedItem.user.email ?? 'Usuário',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(feedItem.item.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Follow Button
                Obx(() {
                  final isCurrentUser = AuthController.to.currentUser.value?.id == feedItem.user.id;
                  if (isCurrentUser) return SizedBox();
                  
                  final isFollowing = SocialController.to.followingStatus[feedItem.user.id] ?? false;
                  
                  return ElevatedButton(
                    onPressed: isFollowing
                        ? () => SocialController.to.unfollowUser(feedItem.user.id!)
                        : () => SocialController.to.followUser(feedItem.user.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                      minimumSize: Size(70, 32),
                    ),
                    child: Text(
                      isFollowing ? 'Seguindo' : 'Seguir',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }),
                
                // More Options
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Compartilhar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Denunciar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category Badge
          if (feedItem.item.category != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      size: 14,
                      color: _getCategoryColor(),
                    ),
                    SizedBox(width: 6),
                    Text(
                      feedItem.item.category!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 12),

          // Item Image
          if (feedItem.item.imageUrl != null)
            GestureDetector(
              onDoubleTap: () => _handleDoubleTap(),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: feedItem.item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Like Button
                    Obx(() => GestureDetector(
                      onTap: () => FeedController.to.toggleLike(feedItem),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            feedItem.isLikedByCurrentUser
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: feedItem.isLikedByCurrentUser
                                ? Colors.red
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${feedItem.likesCount}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(width: 24),

                    // Comment Button
                    GestureDetector(
                      onTap: () => FeedController.to.showCommentsBottomSheet(feedItem),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${feedItem.commentsCount}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Spacer(),
                    
                    // Share Button
                    GestureDetector(
                      onTap: () => ShareController.to.showShareBottomSheet(feedItem.item, feedItem.user),
                      child: Icon(
                        Icons.share_outlined,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),

                // Item Details
                Text(
                  feedItem.item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (feedItem.item.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    feedItem.item.description!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDoubleTap() {
    // Double tap to like
    if (!feedItem.isLikedByCurrentUser) {
      FeedController.to.toggleLike(feedItem);
      
      // Show heart animation
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 80,
            ),
          ),
        ),
        barrierDismissible: true,
      );
      
      // Auto dismiss after 1 second
      Future.delayed(Duration(seconds: 1), () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      });
    }
  }

  void _showUserProfile() {
    // TODO: Navigate to user profile
    Get.snackbar('Info', 'Perfil de ${feedItem.user.username ?? "usuário"}');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        ShareController.to.showShareBottomSheet(feedItem.item, feedItem.user);
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Denunciar conteúdo'),
        content: Text('Por que você está denunciando este item?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Sucesso', 'Denúncia enviada. Obrigado pelo feedback!');
            },
            child: Text('Denunciar'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    if (feedItem.item.category?.color == null) return Colors.blue;
    try {
      return Color(int.parse('FF${feedItem.item.category!.color}', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    switch (feedItem.item.category?.icon) {
      case 'folder': return Icons.folder;
      case 'favorite': return Icons.favorite;
      case 'star': return Icons.star;
      case 'book': return Icons.book;
      case 'movie': return Icons.movie;
      case 'music_note': return Icons.music_note;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'restaurant': return Icons.restaurant;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'flight': return Icons.flight;
      case 'camera': return Icons.camera;
      case 'palette': return Icons.palette;
      default: return Icons.folder;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}