import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/feed_item_model.dart';
import '../../auth/controllers/auth_controller.dart';
import 'feed_controller.dart';

class PersonalizedFeedController extends GetxController {
  static PersonalizedFeedController get to => Get.find();
  
  final personalizedFeedItems = <FeedItemModel>[].obs;
  final isLoading = false.obs;
  final hasMoreData = true.obs;
  final feedType = 'all'.obs; // 'all', 'following'
  
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void onInit() {
    super.onInit();
    loadPersonalizedFeed();
  }

  Future<void> loadPersonalizedFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      hasMoreData.value = true;
      personalizedFeedItems.clear();
    }

    try {
      isLoading.value = true;
      final currentUserId = AuthController.to.currentUser.value?.id;
      if (currentUserId == null) return;

      List<Map<String, dynamic>> response;
      final offset = _currentPage * _itemsPerPage;

      if (feedType.value == 'following') {
        response = await SupabaseService.getPersonalizedFeed(
          currentUserId: currentUserId,
          limit: _itemsPerPage,
          offset: offset,
        );
      } else {
        response = await SupabaseService.getPublicFeed(
          limit: _itemsPerPage,
          offset: offset,
          currentUserId: currentUserId,
        );
      }

      if (response.isEmpty) {
        hasMoreData.value = false;
      } else {
        final newItems = response.map((item) => 
          FeedItemModel.fromJson(item, currentUserId)
        ).toList();
        
        if (refresh) {
          personalizedFeedItems.assignAll(newItems);
        } else {
          personalizedFeedItems.addAll(newItems);
        }
        
        _currentPage++;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar feed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void switchFeedType(String type) {
    feedType.value = type;
    loadPersonalizedFeed(refresh: true);
  }

  Future<void> toggleLike(FeedItemModel feedItem) async {
    await FeedController.to.toggleLike(feedItem);
    
    // Update the item in personalized feed too
    final itemIndex = personalizedFeedItems.indexWhere((item) => item.item.id == feedItem.item.id);
    if (itemIndex != -1) {
      personalizedFeedItems[itemIndex] = personalizedFeedItems[itemIndex].copyWith(
        isLikedByCurrentUser: !feedItem.isLikedByCurrentUser,
        likesCount: feedItem.isLikedByCurrentUser 
            ? feedItem.likesCount - 1 
            : feedItem.likesCount + 1,
      );
    }
  }

  Future<void> addComment(String itemId, String content) async {
    await FeedController.to.addComment(itemId, content);
    
    // Update comments count in personalized feed
    final itemIndex = personalizedFeedItems.indexWhere((item) => item.item.id == itemId);
    if (itemIndex != -1) {
      personalizedFeedItems[itemIndex] = personalizedFeedItems[itemIndex].copyWith(
        commentsCount: personalizedFeedItems[itemIndex].commentsCount + 1,
      );
    }
  }
}