import 'package:get/get.dart';
import 'package:my_collection_app/core/utils/logger.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/notification_model.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import '../../notifications/controllers/notification_controller.dart';




class PushNotificationController extends GetxController {
  static PushNotificationController get to => Get.find();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final isEnabled = true.obs;
  static const String _tag = 'NotificationController';



  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    subscribeToTopics();
    requestPermission();
    setupMessageHandlers();
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    isEnabled.value =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    if (isEnabled.value) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToServer(token);
      }
    }
  }

  void setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

    // Handle app launched from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        handleNotificationTap(message);
      }
    });

    // Handle token refresh
    _messaging.onTokenRefresh.listen(_saveTokenToServer);
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    // Show in-app notification or update badge
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'Notificação',
        message.notification!.body ?? '',
        duration: Duration(seconds: 3),
      );
    }

    // Update notification count
    NotificationController.to.loadUnreadCount();
  }

  Future<void> handleNotificationTap(RemoteMessage message) async {
    final data = message.data;

    // Navigate based on notification type
    switch (data['type']) {
      case 'like':
      case 'comment':
        if (data['item_id'] != null) {
          // TODO: Navigate to item detail
          Get.snackbar('Info', 'Navegar para item: ${data['item_id']}');
        }
        break;
      case 'follow':
        if (data['user_id'] != null) {
          // TODO: Navigate to user profile
          Get.snackbar('Info', 'Navegar para perfil do usuário');
        }
        break;
      case 'chat':
        if (data['conversation_id'] != null) {
          // TODO: Navigate to chat
          Get.snackbar('Info', 'Navegar para conversa');
        }
        break;
      default:
        // Navigate to notifications screen
        Get.toNamed('/notifications');
        break;
    }
  }

  Future<void> _saveTokenToServer(String token) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      // Detectar plataforma automaticamente
      String platform;
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      } else {
        platform = 'web';
      }

      await SupabaseService.savePushToken(token, platform);
    } catch (e) {
      Logger.error('Erro ao salvar token push: $e', error: e, tag: _tag);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    isEnabled.value = enabled;

    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      await SupabaseService.updateNotificationSettings(currentUser.id, enabled);

      if (enabled) {
        await requestPermission();
      } else {
        try {
          final token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await SupabaseService.removePushToken(token);
          }
        } catch (e) {
          Logger.error('Erro ao remover push notification.', error: e);
        }
      }

      Get.snackbar(
        'Sucesso',
        enabled ? 'Notificações ativadas' : 'Notificações desativadas',
      );
    } catch (e) {
      isEnabled.value = !enabled;
      Get.snackbar('Erro', 'Falha ao atualizar configurações: ${e.toString()}');
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final currentUserId = AuthController.to.currentUser.value?.id;
      if (currentUserId == null) return;

      notifications.value = await SupabaseService.getPendingNotifications(
        currentUserId,
      );
    } catch (e) {
      Logger.error('Error loading push notifications: $e',tag: _tag, error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> subscribeToTopics() async {
    try {
      // Subscribe to system notifications
      await PushNotificationService.subscribeToTopic('system_notifications');

      // Subscribe to promotions if user is premium
      // This would be handled based on subscription status
    } catch (e) {
      Logger.error('Error subscribing to topics: $e', tag: _tag, error: e);
    }
  }

  Future<void> sendChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    await PushNotificationService.sendPushNotification(
      userId: recipientUserId,
      title: '$senderName enviou uma mensagem',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      notificationType: 'chat',
      data: {'conversation_id': conversationId, 'sender_name': senderName},
    );
  }

  Future<void> sendLikeNotification({
    required String recipientUserId,
    required String likerName,
    required String itemName,
    required String itemId,
  }) async {
    await PushNotificationService.sendPushNotification(
      userId: recipientUserId,
      title: '$likerName curtiu seu item!',
      body: '$likerName curtiu "$itemName"',
      notificationType: 'like',
      data: {'item_id': itemId, 'item_name': itemName, 'liker_name': likerName},
    );
  }

  Future<void> sendCommentNotification({
    required String recipientUserId,
    required String commenterName,
    required String itemName,
    required String itemId,
  }) async {
    await PushNotificationService.sendPushNotification(
      userId: recipientUserId,
      title: '$commenterName comentou!',
      body: '$commenterName comentou no seu item "$itemName"',
      notificationType: 'comment',
      data: {
        'item_id': itemId,
        'item_name': itemName,
        'commenter_name': commenterName,
      },
    );
  }

  Future<void> sendFollowNotification({
    required String recipientUserId,
    required String followerName,
    required String followerId,
  }) async {
    await PushNotificationService.sendPushNotification(
      userId: recipientUserId,
      title: 'Novo seguidor!',
      body: '$followerName começou a te seguir',
      notificationType: 'follow',
      data: {'follower_id': followerId, 'follower_name': followerName},
    );
  }

  Future<void> sendPromotionNotification({
    required String userId,
    required String itemName,
    required String promotionType,
  }) async {
    String title = 'Promoção Ativada!';
    String body = 'Seu item "$itemName" está sendo promovido';

    switch (promotionType) {
      case 'boost':
        body = 'Seu item "$itemName" recebeu um boost no feed!';
        break;
      case 'featured':
        body = 'Seu item "$itemName" está em destaque!';
        break;
      case 'trending':
        body = 'Seu item "$itemName" está nos trending!';
        break;
    }

    await PushNotificationService.sendPushNotification(
      userId: userId,
      title: title,
      body: body,
      notificationType: 'promotion',
      data: {'item_name': itemName, 'promotion_type': promotionType},
    );
  }

  Future<void> sendSystemNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await PushNotificationService.sendPushNotification(
      userId: userId,
      title: title,
      body: body,
      notificationType: 'system',
      data: data,
    );
  }
}
