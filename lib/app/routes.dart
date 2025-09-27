import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/collections/screens/home_screen.dart';
import '../features/collections/screens/add_item_screen.dart';
import '../features/collections/screens/add_category_screen.dart';
import '../features/collections/screens/category_detail_screen.dart';
import '../features/feed/screens/enhanced_feed_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/discovery/screens/discovery_screen.dart';
import '../features/payments/screens/payment_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String addItem = '/add-item';
  static const String addCategory = '/add-category';
  static const String categoryDetail = '/category-detail';
  static const String feed = '/feed';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String discovery = '/discovery';
  static const String payment = '/payment';
  static const String analytics = '/analytics';
  static const String conversations = '/conversations';

  static List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: addItem,
      page: () => AddItemScreen(),
    ),
    GetPage(
      name: addCategory,
      page: () => AddCategoryScreen(),
    ),
    GetPage(
      name: categoryDetail,
      page: () => CategoryDetailScreen(),
    ),
    GetPage(
      name: feed,
      page: () => EnhancedFeedScreen(),
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: notifications,
      page: () => NotificationsScreen(),
    ),
    GetPage(
      name: discovery,
      page: () => DiscoveryScreen(),
    ),
    GetPage(
      name: payment,
      page: () => PaymentScreen(),
    ),
  ];
}