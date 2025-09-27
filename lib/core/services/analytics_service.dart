import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // App lifecycle events
  static Future<void> logAppOpen() async {
    await logEvent('app_open', null);
  }

  static Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
  }

  static Future<void> logSignUp(String method) async {
    await logEvent('sign_up', {'method': method});
  }

  // Collection events
  static Future<void> logItemCreated(String categoryName) async {
    await logEvent('item_created', {'category': categoryName});
  }

  static Future<void> logCategoryCreated() async {
    await logEvent('category_created', null);
  }

  static Future<void> logItemMadePublic() async {
    await logEvent('item_made_public', null);
  }

  // Social events
  static Future<void> logItemLiked(String itemId) async {
    await logEvent('item_liked', {'item_id': itemId});
  }

  static Future<void> logItemCommented(String itemId) async {
    await logEvent('item_commented', {'item_id': itemId});
  }

  static Future<void> logUserFollowed(String followedUserId) async {
    await logEvent('user_followed', {'followed_user_id': followedUserId});
  }

  static Future<void> logItemShared(String itemId, String method) async {
    await logEvent('item_shared', {
      'item_id': itemId,
      'method': method,
    });
  }

  // Premium events
  static Future<void> logSubscriptionPurchased(String plan) async {
    await logEvent('subscription_purchased', {'plan': plan});
  }

  static Future<void> logSubscriptionCanceled(String plan) async {
    await logEvent('subscription_canceled', {'plan': plan});
  }

  static Future<void> logPremiumFeatureUsed(String feature) async {
    await logEvent('premium_feature_used', {'feature': feature});
  }

  // Search and discovery events
  static Future<void> logSearch(String query, int resultsCount) async {
    await logEvent('search', {
      'search_term': query,
      'results_count': resultsCount,
    });
  }

  static Future<void> logTrendingViewed(String period) async {
    await logEvent('trending_viewed', {'period': period});
  }

  // Engagement events
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  static Future<void> logTimeSpent(String screen, int seconds) async {
    await logEvent('time_spent', {
      'screen': screen,
      'duration_seconds': seconds,
    });
  }
}
