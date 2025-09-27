import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
        actions: [
          Obx(() {
            final hasUnread = NotificationController.to.unreadCount.value > 0;
            return TextButton(
              onPressed: hasUnread 
                  ? () => NotificationController.to.markAllAsRead()
                  : null,
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(
                  color: hasUnread ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final controller = NotificationController.to;
        
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhuma notificação',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Você será notificado sobre curtidas e comentários',
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadNotifications(refresh: true),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return NotificationTile(
                notification: notification,
                onTap: () => controller.handleNotificationTap(notification),
                onDismiss: () => controller.deleteNotification(notification),
              );
            },
          ),
        );
      }),
    );
  }
}