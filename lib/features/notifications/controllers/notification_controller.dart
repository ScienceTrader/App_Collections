import 'package:get/get.dart';
import 'package:my_collection_app/core/utils/logger.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/notification_model.dart';
import '../../auth/controllers/auth_controller.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();
  
  final notifications = <NotificationModel>[].obs;
  final isEnabled = true.obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  static const String _tag = 'NotificationController';


  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
    loadNotificationSettings();

  }

  Future<void> loadNotifications({bool refresh = false}) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      final notificationsList = await SupabaseService.getNotifications(
        userId: currentUser.id,
        limit: 50,
        offset: 0,
      );
      notifications.assignAll(notificationsList);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar notificações: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotificationSettings() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      final settings = await SupabaseService.getNotificationSettings(currentUser.id);
      if (settings != null) {
        isEnabled.value = settings['push_enabled'] ?? true;
      }
    } catch (e) {
      Logger.error('Erro ao carregar configurações de notificação: $e', 
                  tag: 'NotificationController');
    }
  }

  Future<void> loadUnreadCount() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      final count = await SupabaseService.getUnreadNotificationsCount(currentUser.id);
      unreadCount.value = count;
    } catch (e) {
      Logger.error('Erro ao carregar contagem de não lidas: $e',tag: _tag, error: e);
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await SupabaseService.markNotificationAsRead(notification.id!);
      
      // Update local state
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = NotificationModel.fromJson({
          ...notification.toJson(),
          'is_read': true,
        });
      }
      
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao marcar como lida: ${e.toString()}');
    }
  }

  Future<void> markAllAsRead() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      await SupabaseService.markAllNotificationsAsRead(currentUser.id);
      
      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = NotificationModel.fromJson({
            ...notifications[i].toJson(),
            'is_read': true,
          });
        }
      }
      
      unreadCount.value = 0;
      Get.snackbar('Sucesso', 'Todas as notificações foram marcadas como lidas');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao marcar todas como lidas: ${e.toString()}');
    }
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      await SupabaseService.deleteNotification(notification.id!);
      notifications.removeWhere((n) => n.id == notification.id);
      
      if (!notification.isRead) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
      }
      
      Get.snackbar('Sucesso', 'Notificação excluída');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao excluir notificação: ${e.toString()}');
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    markAsRead(notification);
    
    // Navigate based on notification type
    switch (notification.type) {
      case 'like':
      case 'comment':
        if (notification.itemId != null) {
          // TODO: Navigate to item detail
          Get.snackbar('Info', 'Navegar para item: ${notification.itemId}');
        }
        break;
      case 'follow':
        if (notification.senderId != null) {
          // TODO: Navigate to user profile
          Get.snackbar('Info', 'Navegar para perfil do usuário');
        }
        break;
      default:
        break;
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    isEnabled.value = enabled;

    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      await SupabaseService.updateNotificationSettings(
          currentUser.id, enabled);

      if (enabled) {
        await requestPermission();
      }

      Get.snackbar(
        'Sucesso',
        enabled ? 'Notificações ativadas' : 'Notificações desativadas',
      );
    } catch (e) {
      // Reverter estado em caso de erro
      isEnabled.value = !enabled;
      Get.snackbar('Erro', 'Falha ao atualizar configurações: ${e.toString()}');
    }
  }

  Future<void> requestPermission() async {
    // Implementar requisição de permissão
    try {
      // Código de permissão aqui
    } catch (e) {
      Logger.error('Erro ao solicitar permissão: $e', tag: _tag);
    }
  }
}