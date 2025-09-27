import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_collection_app/features/auth/screens/login_screen.dart';
import 'package:my_collection_app/features/auth/controllers/auth_controller.dart';

void main() {
  testWidgets('Login screen should have required fields', (WidgetTester tester) async {
    Get.testMode = true;
    Get.put(AuthController());

    await tester.pumpWidget(
      GetMaterialApp(home: LoginScreen()),
    );

    expect(find.byType(TextFormField), findsAtLeast(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}