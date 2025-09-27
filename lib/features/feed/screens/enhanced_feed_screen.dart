import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart';
import '../controllers/personalized_feed_controller.dart';
import '../../social/controllers/social_controller.dart';
import '../../notifications/controllers/notification_controller.dart';
import '../widgets/enhanced_feed_item_card.dart';
import '../widgets/user_suggestion_card.dart';
import '../../social/screens/user_search_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class EnhancedFeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Feed'),
          actions: [
            Obx(() {
              final unreadCount = NotificationController.to.unreadCount.value;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () => Get.to(() => NotificationsScreen()),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => Get.to(() => UserSearchScreen()),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Explorar'),
              Tab(text: 'Seguindo'),
            ],
            onTap: (index) {
              PersonalizedFeedController.to.switchFeedType(
                index == 0 ? 'all' : 'following'
              );
            },
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedTab(),
            _buildPersonalizedFeedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return Obx(() {
      final controller = FeedController.to;
      
      return Column(
        children: [
          _buildSuggestedUsersSection(),
          Expanded(
            child: _buildFeedList(
              controller.feedItems,
              controller.isLoading.value,
              controller.hasMoreData.value,
              () => controller.loadFeed(),
              () => controller.loadFeed(refresh: true),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPersonalizedFeedTab() {
    return Obx(() {
      final controller = PersonalizedFeedController.to;
      
      if (controller.personalizedFeedItems.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'Seu feed personalizado está vazio',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              SizedBox(height: 8),
              Text(
                'Siga outros usuários para ver seus itens aqui!',
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.to(() => UserSearchScreen()),
                child: Text('Descobrir Usuários'),
              ),
            ],
          ),
        );
      }

      return _buildFeedList(
        controller.personalizedFeedItems,
        controller.isLoading.value,
        controller.hasMoreData.value,
        () => controller.loadPersonalizedFeed(),
        () => controller.loadPersonalizedFeed(refresh: true),
      );
    });
  }

  Widget _buildFeedList(
    List items,
    bool isLoading,
    bool hasMoreData,
    VoidCallback loadMore,
    VoidCallback refresh,
  ) {
    if (isLoading && items.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public_off, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => refresh(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            if (hasMoreData && !isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) => loadMore());
            }
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final feedItem = items[index];
          return EnhancedFeedItemCard(feedItem: feedItem);
        },
      ),
    );
  }

  Widget _buildSuggestedUsersSection() {
    return Obx(() {
      final suggestedUsers = SocialController.to.suggestedUsers;
      if (suggestedUsers.isEmpty) return SizedBox();

      return Container(
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Usuários sugeridos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestedUsers.length,
                itemBuilder: (context, index) {
                  final user = suggestedUsers[index];
                  return UserSuggestionCard(user: user);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
