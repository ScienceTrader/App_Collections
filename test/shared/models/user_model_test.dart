import 'package:flutter_test/flutter_test.dart';
import 'package:my_collection_app/shared/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'username': 'testuser',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
      );

      final json = user.toJson();

      expect(json['id'], equals('123'));
      expect(json['email'], equals('test@example.com'));
      expect(json['username'], equals('testuser'));
    });
  });
}