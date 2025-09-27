import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_collection_app/main.dart';
import 'package:my_collection_app/features/auth/controllers/auth_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App should show login screen when not authenticated', (WidgetTester tester) async {
    final mockAuthController = AuthController();
    Get.put(mockAuthController);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsAtLeastOneWidget);
    expect(find.byType(TextFormField), findsAtLeastOneWidget);
  });
}