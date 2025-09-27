import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '/app/routes.dart';
import '../../../shared/models/feed_item_model.dart';
import '../../feed/controllers/feed_controller.dart';
import '../../sharing/controllers/share_controller.dart';
import '../../social/controllers/social_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class EnhancedFeedItemCard extends StatelessWidget {
  final FeedItemModel feedItem;

  const EnhancedFeedItemCard({super.key, required this.feedItem});
  @override
  Widget build(BuildContext context) {  
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showUserProfile(feedItem.user.id!),
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
                        : const Icon(Icons.person, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _showUserProfile(feedItem.user.id!),
                        child: Text(
                          feedItem.user.username ?? feedItem.user.email ?? 'Usuário',
                          style: const TextStyle(
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
                  if (isCurrentUser) return const SizedBox();
                  
                  final isFollowing = SocialController.to.followingStatus[feedItem.user.id] ?? false;
                  
                  return ElevatedButton(
                    onPressed: isFollowing
                        ? () => SocialController.to.unfollowUser(feedItem.user.id!)
                        : () => SocialController.to.followUser(feedItem.user.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                      minimumSize: const Size(70, 32),
                    ),
                    child: Text(
                      isFollowing ? 'Seguindo' : 'Seguir',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
                
                // More Options
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Compartilhar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withValues(alpha: 0.1),
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
                    const SizedBox(width: 6),
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

          const SizedBox(height: 12),

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
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
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
                          const SizedBox(width: 8),
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
                    const SizedBox(width: 24),

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
                          const SizedBox(width: 8),
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
                    
                    const Spacer(),
                    
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
                
                const SizedBox(height: 12),

                // Item Details
                Text(
                  feedItem.item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (feedItem.item.description != null) ...[
                  const SizedBox(height: 4),
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

  void _showUserProfile(String userId) {
    Get.toNamed(AppRoutes.profile, arguments: {'userId': userId});
  }

  void _handleDoubleTap() {
    if (!feedItem.isLikedByCurrentUser) {
      FeedController.to.toggleLike(feedItem);
      _showLikeAnimation();
    }
  }

  void _showLikeAnimation() {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value < 0.5 ? value * 2 : 2 - value,
                child: Opacity(
                  opacity: 1 - value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 100,
                  ),
                ),
              );
            },
            onEnd: () => Get.back(),
          ),
        ),
      ),
      barrierDismissible: false,
      transitionDuration: Duration.zero,
    );
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
        title: const Text('Denunciar Conteúdo'),
        content: const Text('Tem certeza que deseja denunciar este conteúdo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Implementar lógica de denúncia
              Get.snackbar('Sucesso', 'Conteúdo denunciado com sucesso');
            },
            child: const Text('Denunciar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Agora';
    }
  }

  Color _getCategoryColor() {
    if (feedItem.item.category == null) return Colors.grey;
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    
    final index = feedItem.item.category!.name.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getCategoryIcon() {
    if (feedItem.item.category == null) return Icons.category;
    
    final categoryName = feedItem.item.category!.name.toLowerCase();
    
    if (categoryName.contains('livro') || categoryName.contains('book')) {
      return Icons.menu_book;
    } else if (categoryName.contains('filme') || categoryName.contains('movie')) {
      return Icons.movie;
    } else if (categoryName.contains('música') || categoryName.contains('music')) {
      return Icons.music_note;
    } else if (categoryName.contains('jogo') || categoryName.contains('game')) {
      return Icons.games;
    } else if (categoryName.contains('arte') || categoryName.contains('art')) {
      return Icons.palette;
    } else {
      return Icons.category;
    }
  }
}