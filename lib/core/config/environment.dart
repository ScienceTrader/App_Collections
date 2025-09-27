import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment get current {
    if (kDebugMode) return Environment.development;
    if (kProfileMode) return Environment.staging;
    return Environment.production;
  }

  static FirebaseConfig get firebase {
    switch (current) {
      case Environment.development:
        return FirebaseConfig.development();
      case Environment.staging:
        return FirebaseConfig.staging();
      case Environment.production:
        return FirebaseConfig.production();
    }
  }
}

class FirebaseConfig {
  final String fcmServerKey;
  final String projectId;
  final String messagingSenderId;
  final String appId;

  FirebaseConfig({
    required this.fcmServerKey,
    required this.projectId,
    required this.messagingSenderId,
    required this.appId,
  });

  factory FirebaseConfig.development() {
    return FirebaseConfig(
      fcmServerKey: 'AIzaSyA6WyYSIDNpRWBulHSQJ3E52u45wQYTWXw',
      projectId: 'mycollection-1767c-dev',
      messagingSenderId: '123456789',
      appId: 'dev_app_id',
    );
  }

  factory FirebaseConfig.staging() {
    return FirebaseConfig(
      fcmServerKey: 'AIzaSyA6WyYSIDNpRWBulHSQJ3E52u45wQYTWXw',
      projectId: 'mycollection-1767c-staging',
      messagingSenderId: '987654321',
      appId: 'staging_app_id',
    );
  }

  factory FirebaseConfig.production() {
    return FirebaseConfig(
      fcmServerKey: 'AIzaSyA6WyYSIDNpRWBulHSQJ3E52u45wQYTWXw',
      projectId: 'mycollection-1767c-prod',
      messagingSenderId: '555666777',
      appId: 'prod_app_id',
    );
  }
}