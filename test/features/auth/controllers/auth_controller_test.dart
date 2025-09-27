import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_collection_app/features/auth/controllers/auth_controller.dart';
import 'package:my_collection_app/core/services/supabase_service.dart';

// Generate mocks - adicionar SupabaseService
@GenerateMocks([SupabaseClient, GoTrueClient, User, SupabaseService])
import '../../../unit_tests/auth_controller_test.mocks.dart';

void main() {
  late AuthController authController;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    Get.testMode = true;
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    
    when(mockSupabaseClient.auth).thenReturn(mockAuth);
    when(mockAuth.currentSession).thenReturn(null);
    
    authController = AuthController();
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController Tests', () {
    test('should initialize with default values', () {
      expect(authController.currentUser.value, isNull);
      expect(authController.isLoading.value, isFalse);
      expect(authController.isAuthenticated, isFalse); // CORREÇÃO: remover .value
    });

    test('should handle sign in successfully', () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.id).thenReturn('user-123');
      when(mockUser.email).thenReturn('test@example.com');

      final mockSession = AuthResponse(
        user: mockUser,
        session: Session(
          accessToken: 'test-token',
          refreshToken: 'refresh-token',
          tokenType: 'bearer', // CORREÇÃO: adicionar tokenType obrigatório
          expiresIn: 3600,
          user: mockUser,
        ),
      );

      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockSession);

      // Act - CORREÇÃO: usar nome correto do método
      await authController.signInWithEmail(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(authController.isLoading.value, isFalse);
      expect(authController.currentUser.value, isNotNull);
    });

    test('should handle sign in failure', () async {
      // Arrange
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(const AuthException('Invalid credentials'));

      // Act - CORREÇÃO: usar nome correto do método
      await authController.signInWithEmail(
        'test@example.com',
        'wrongpassword',
      );

      // Assert
      expect(authController.isLoading.value, isFalse);
      expect(authController.currentUser.value, isNull);
      expect(authController.isAuthenticated, isFalse); // CORREÇÃO: remover .value
    });

    test('should handle sign up successfully', () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.id).thenReturn('user-123');

      final mockSession = AuthResponse(
        user: mockUser,
        session: null, // Sign up pode não retornar session se precisar verificação
      );

      when(mockAuth.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockSession);

      // Act - CORREÇÃO: usar nome correto do método e adicionar username
      await authController.signUpWithEmail(
        'newuser@example.com',
        'password123',
        'testuser', // username obrigatório
      );

      // Assert
      expect(authController.isLoading.value, isFalse);
    });

    test('should sign out successfully', () async {
      // Arrange
      when(mockAuth.signOut()).thenAnswer((_) async => {});

      // Act
      await authController.signOut();

      // Assert
      expect(authController.currentUser.value, isNull);
      expect(authController.isAuthenticated, isFalse); // CORREÇÃO: remover .value
    });

    test('should update authentication state correctly', () {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.id).thenReturn('user-123');
      when(mockUser.email).thenReturn('test@example.com');

      // Act
      authController.currentUser.value = mockUser;

      // Assert
      expect(authController.isAuthenticated, isTrue); // CORREÇÃO: remover .value
      expect(authController.currentUser.value?.id, equals('user-123'));
    });
  });
}