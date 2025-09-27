// lib/core/constants/app_constants.dart
//import 'lib.dart';
import '../config/environment.dart';

class AppConstants {
  // Supabase
  static const String supabaseUrl = 'https://irorvshovfhkgvcxjdmz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlyb3J2c2hvdmZoa2d2Y3hqZG16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4NDY0MzYsImV4cCI6MjA3MjQyMjQzNn0.QIC8Ev0szEL330eGZ4tjbLk9of6-JTE-CnDuc8n8y4g';

  // Clerk
  static const String clerkPublishableKey = 'pk_test_dGlkeS1tYW4tMTkuY2xlcmsuYWNjb3VudHMuZGV2JA';

  // Stripe
  static const String stripePublishableKey = 'pk_test_51S31aQEEA5jFrFDbHQtVOMTphGlIWhuBW7nbXZvnXUyLPkjshUtClzsvwBaPCsD7beHB4LzmNXKvKA2Oo7qlT6Si00RW7X1uR4';

  // Firebase (será preenchido automaticamente)
  static const String firebaseProjectId = 'MyCollection';
  
  // Firebase Configuration
  // Firebase Configuration (dinâmica)
  static String get fcmServerKey => EnvironmentConfig.firebase.fcmServerKey;
  static String get projectId => EnvironmentConfig.firebase.projectId;
  static String get messagingSenderId => EnvironmentConfig.firebase.messagingSenderId;
  static String get firebaseAppId => EnvironmentConfig.firebase.appId;

   // App Configuration
  static const String appName = 'My Collection';
  static const String appVersion = '2.0.0';

  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'monthly': {
      'name': 'Premium Mensal',
      'price': 9.90,
      'priceId': 'price_monthly_premium',
      'features': [
        'Coleções ilimitadas',
        'Análises avançadas',
        'Chat com outros usuários',
        'Promoção de itens',
        'Relatórios em PDF/Excel',
        'Suporte prioritário'
      ],
    },
    'yearly': {
      'name': 'Premium Anual',
      'price': 99.90,
      'priceId': 'price_yearly_premium',
      'features': [
        'Todos os recursos Premium',
        '2 meses grátis',
        'Acesso antecipado a novos recursos',
        'Suporte 24/7'
      ],
    },
  };
  // Subscription Limits
  static const int freeCategoriesLimit = 4;
  static const int freeItemsLimit = 50;
  static const int freeSubcategoriesLimit = 4;
  static const int premiumCategoryLimit = -1; // unlimited
  static const int premiumItemLimit = -1; // unlimited
  
  // Storage Buckets
  static const String itemImagesBucket = 'item-images';
  static const String avatarsBucket = 'avatars';
  
  // Push Notification Topics
  static const String allUsersTopicName = 'all_users';
  static const String systemTopic = 'system_notifications';
}
