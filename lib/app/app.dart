import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/themes/app_theme.dart';
import 'routes.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/collections/controllers/collection_controller.dart';
import '../features/subscription/controllers/subscription_controller.dart';
import '../features/feed/controllers/feed_controller.dart';
import '../features/feed/controllers/personalized_feed_controller.dart';
import '../features/social/controllers/social_controller.dart';
import '../features/notifications/controllers/notification_controller.dart';
import '../features/sharing/controllers/share_controller.dart';
import '../features/discovery/controllers/discovery_controller.dart';
import '../features/payments/controllers/payment_controller.dart';
import '../features/premium/controllers/analytics_controller.dart';
import '../features/profile/controllers/profile_controller.dart';
import '../features/settings/controllers/theme_controller.dart';



class MyCollectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Collection',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      locale: const Locale('pt', 'BR'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Controllers - Always initialized
    Get.put(AuthController(), permanent: true);
    Get.put(SubscriptionController(), permanent: true);
    Get.put(CollectionController(), permanent: true);
    Get.put(SearchController(), permanent: true); 
    Get.put(NotificationController(), permanent: true);
    Get.lazyPut(() => ProfileController()); 
    Get.lazyPut(() => ThemeController());

    
    // Feed Controllers
    Get.put(FeedController());
    Get.put(PersonalizedFeedController());
    
    // Social Controllers
    Get.put(SocialController());
    Get.put(NotificationController());
    Get.put(ShareController());
    
    // Discovery Controller
    Get.put(DiscoveryController());
    
    // Premium Controllers (lazy loaded based on subscription)
    Get.lazyPut<PaymentController>(() => PaymentController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}