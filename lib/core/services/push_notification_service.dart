import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/supabase_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  static const String _tag = 'PushNotificationService';

  // Adicionar chave do servidor FCM (configure no Firebase Console)
  static const String _fcmServerKey = 'AIzaSyA6WyYSIDNpRWBulHSQJ3E52u45wQYTWXw';
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  static Future<void> init() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(initSettings);
      
      _initialized = true;
      Logger.info('PushNotificationService inicializado com sucesso', tag: _tag);
    } catch (e, stackTrace) {
      Logger.error('Falha ao inicializar PushNotificationService', 
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      final authorized = settings.authorizationStatus == AuthorizationStatus.authorized;
      Logger.info('Permissões de notificação: ${authorized ? "concedidas" : "negadas"}', tag: _tag);
      
      return authorized;
    } catch (e, stackTrace) {
      Logger.error('Erro ao solicitar permissões de notificação', 
          tag: _tag, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        Logger.debug('Token FCM obtido: ${token.substring(0, 20)}...', tag: _tag);
      } else {
        Logger.warning('Token FCM não disponível', tag: _tag);
      }
      return token;
    } catch (e, stackTrace) {
      Logger.error('Erro ao obter token FCM', 
          tag: _tag, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Configurar handlers de mensagens
  static void setupMessageHandlers({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onMessageOpenedApp,
  }) {
    // Mensagens em foreground
    FirebaseMessaging.onMessage.listen(onMessageReceived);
    
    // Mensagens quando app é aberto
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    
    // Mensagem inicial (app foi aberto por notificação)
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        onMessageOpenedApp(message);
      }
    });
  }

  /// Mostrar notificação local
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Canal padrão para notificações',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Inscrever em tópico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      Logger.error('Erro ao inscrever no tópico $topic: $e', tag: _tag, error: e);
    }
  }

  /// Desinscrever de tópico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      Logger.error('Erro ao desinscrever do tópico $topic: $e', tag: _tag, error: e);
    }
  }

  static Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required String notificationType,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Buscar token FCM do usuário
      final userToken = await _getUserFCMToken(userId);
      if (userToken == null) {
        Logger.warning('Token FCM não encontrado para usuário $userId', tag: _tag);
        return;
      }

      // Preparar payload da notificação
      final payload = {
        'to': userToken,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'badge': '1',
        },
        'data': {
          'type': notificationType,
          'user_id': userId,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          ...?data,
        },
        'priority': 'high',
      };

      // Enviar via FCM
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        Logger.info('Push notification enviada com sucesso para $userId', tag: _tag);
      } else {
        Logger.error('Falha ao enviar push notification: ${response.body}', tag: _tag);
      }
    } catch (e, stackTrace) {
      Logger.error('Erro ao enviar push notification', 
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  /// Buscar token FCM de um usuário
  static Future<String?> _getUserFCMToken(String userId) async {
    try {
      final response = await SupabaseService.getUserPushToken(userId);
      return response;
    } catch (e) {
      Logger.error('Erro ao buscar token FCM do usuário $userId', tag: _tag, error: e);
      return null;
    }
  }

  /// Salvar token FCM do usuário atual
  static Future<void> saveUserToken() async {
    try {
      final currentUser = AuthController.to.currentUser.value;
      if (currentUser == null) return;

      final token = await getToken();
      if (token == null) return;

      await SupabaseService.saveUserPushToken(
        userId: currentUser.id,
        token: token,
        platform: _getPlatform(),
      );

      Logger.info('Token FCM salvo para o usuário', tag: _tag);
    } catch (e, stackTrace) {
      Logger.error('Erro ao salvar token FCM', 
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  /// Detectar plataforma
  static String _getPlatform() {
    // Você pode usar Platform.isAndroid/Platform.isIOS se importar dart:io
    return 'mobile'; // Simplificado por enquanto
  }

  /// Enviar para múltiplos usuários
  static Future<void> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    required String notificationType,
    Map<String, dynamic>? data,
  }) async {
    for (final userId in userIds) {
      await sendPushNotification(
        userId: userId,
        title: title,
        body: body,
        notificationType: notificationType,
        data: data,
      );
      
      // Pequeno delay para evitar rate limiting
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

}