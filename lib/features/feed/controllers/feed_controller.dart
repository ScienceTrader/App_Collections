import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/feed_item_model.dart';
import '../../../shared/models/comment_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/comments_bottom_sheet.dart';

class FeedController extends GetxController {
  static FeedController get to => Get.find();
  
  final feedItems = <FeedItemModel>[].obs;
  final isLoading = false.obs;
  final hasMoreData = true.obs;
  
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      hasMoreData.value = true;
      feedItems.clear();
    }

    try {
      isLoading.value = true;
      final currentUserId = AuthController.to.currentUser.value?.id;
      
      final response = await SupabaseService.getPublicFeed(
        limit: _itemsPerPage,
        offset: _currentPage * _itemsPerPage,
        currentUserId: currentUserId,
      );

      if (response.isEmpty) {
        hasMoreData.value = false;
      } else {
        final newItems = response.map((item) => 
          FeedItemModel.fromJson(item, currentUserId)
        ).toList();
        
        if (refresh) {
          feedItems.assignAll(newItems);
        } else {
          feedItems.addAll(newItems);
        }
        
        _currentPage++;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar feed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(FeedItemModel feedItem) async {
    final currentUserId = AuthController.to.currentUser.value?.id;
    if (currentUserId == null) return;

    try {
      final wasLiked = feedItem.isLikedByCurrentUser;
      
      // Optimistic update
      final itemIndex = feedItems.indexWhere((item) => item.item.id == feedItem.item.id);
      if (itemIndex != -1) {
        feedItems[itemIndex] = feedItem.copyWith(
          isLikedByCurrentUser: !wasLiked,
          likesCount: wasLiked ? feedItem.likesCount - 1 : feedItem.likesCount + 1,
        );
      }

      if (wasLiked) {
        await SupabaseService.unlikeItem(feedItem.item.id!, currentUserId);
      } else {
        await SupabaseService.likeItem(feedItem.item.id!, currentUserId);
        
        // Create notification for the item owner
        if (feedItem.item.userId != currentUserId) {
          // Corrigir o acesso ao username
          final currentUser = AuthController.to.currentUser.value;
          final username = currentUser?.userMetadata?['username'] ?? 
                          currentUser?.email?.split('@').first ?? 
                          'Alguém';
          
          await SupabaseService.createNotification(
            userId: feedItem.item.userId,
            senderId: currentUserId,
            type: 'like',
            title: 'Novo curtir',
            body: '$username curtiu seu item "${feedItem.item.name}"',
            itemId: feedItem.item.id,
          );
        }
      }
    } catch (e) {
      // Revert optimistic update on error
      final itemIndex = feedItems.indexWhere((item) => item.item.id == feedItem.item.id);
      if (itemIndex != -1) {
        feedItems[itemIndex] = feedItem;
      }
      Get.snackbar('Erro', 'Falha ao curtir item: ${e.toString()}');
    }
  }

  Future<void> addComment(String itemId, String content) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      final comment = CommentModel(
        itemId: itemId,
        userId: currentUser.id, // Remover o !
        content: content,
      );

      await SupabaseService.addComment(comment);
      
      // Update comments count
      final itemIndex = feedItems.indexWhere((item) => item.item.id == itemId);
      if (itemIndex != -1) {
        feedItems[itemIndex] = feedItems[itemIndex].copyWith(
          commentsCount: feedItems[itemIndex].commentsCount + 1,
        );
      }

      // Create notification for the item owner
      final feedItem = feedItems.firstWhere((item) => item.item.id == itemId);
      if (feedItem.item.userId != currentUser.id) {
        final username = currentUser.userMetadata?['username'] ?? 
                        currentUser.email?.split('@').first ?? 
                        'Alguém';
        
        await SupabaseService.createNotification(
          userId: feedItem.item.userId,
          senderId: currentUser.id, // Remover o !
          type: 'comment',
          title: 'Novo comentário',
          body: '$username comentou em "${feedItem.item.name}"',
          itemId: itemId,
        );
      }

      Get.snackbar('Sucesso', 'Comentário adicionado');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao adicionar comentário: ${e.toString()}');
    }
  }

  void showCommentsBottomSheet(FeedItemModel feedItem) {
    Get.bottomSheet(
      CommentsBottomSheet(feedItem: feedItem),
      isScrollControlled: true,
    );
  }
}
