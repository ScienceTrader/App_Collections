import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/payment_service.dart';
import 'core/constants/app_constants.dart';
import 'features/settings/controllers/theme_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  
  // Initialize Firebase
  await Firebase.initializeApp();

  await GetStorage.init();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  Get.put(ThemeController(), permanent: true);
  // Initialize Stripe
  await PaymentService.init();
  
  // Initialize Push Notifications
  await PushNotificationService.init();

  
  
  runApp(MyCollectionApp());
}

