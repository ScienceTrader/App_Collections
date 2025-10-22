import 'package:my_collection_app/app/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:my_collection_app/core/utils/logger.dart';
import '../../../shared/models/user_model.dart';
import 'package:my_collection_app/core/services/supabase_service.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  static const String _tag = 'AuthController';
  bool get isAuthenticated => currentUser.value != null;

  final _supabase = Supabase.instance.client;
  final currentUser = Rxn<User>();
  final userProfile = Rxn<UserModel>(); // Perfil customizado

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session?.user != null) {
        currentUser.value = session!.user;
        _loadUserProfile();
      } else {
        currentUser.value = null;
        userProfile.value = null;
      }
    });
  }

  //Privado
  Future<void> _checkAuthState() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        currentUser.value = session.user;
        await _loadUserProfile();
      }
    } catch (e) {
      Logger.error('Erro ao verificar estado de autenticação: $e', tag: _tag);
    }
  }

  // Versão pública também deve ser assíncrona
  Future<void> checkAuthState() async {
    try {
      isLoading.value = true;
      final session = _supabase.auth.currentSession;

      if (session != null) {
        currentUser.value = session.user;
        await _loadUserProfile();

        // Navegar para home se autenticado
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Navegar para login se não autenticado
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Logger.error('Erro ao verificar estado de autenticação: $e', tag: _tag);
      // Em caso de erro, ir para login
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        currentUser.value = response.user;
        await _loadUserProfile(); // Carregar perfil após login
        Get.offAllNamed(AppRoutes.home);
        Logger.info('Login realizado com sucesso', tag: _tag);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha no login: ${e.toString()}');
      Logger.error('Falha no login', tag: _tag, error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String username) async {
    try {
      isLoading.value = true;
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        Get.snackbar('Sucesso', 'Conta criada! Verifique seu email.');
        Logger.info('Login realizado com sucesso', tag: _tag);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha no cadastro: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserProfile() async {
    final user = currentUser.value;
    if (user == null) return;

    try {
      final profile = await SupabaseService.getUserProfile(user.id);
      if (profile != null) {
        userProfile.value = UserModel.fromJson(profile);
      }
    } catch (e) {
      Logger.error('Erro ao carregar perfil: $e', tag: _tag, error: e);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      isLoading.value = true;

      final currentUser = this.currentUser.value;
      if (currentUser == null) return;

      // Preparar dados para atualização
      final updates = <String, dynamic>{};

      if (email != null && email != currentUser.email) {
        updates['email'] = email;
      }

      if (username != null) {
        updates['data'] = {
          ...currentUser.userMetadata ?? {},
          'username': username,
        };
      }

      // Atualizar no Supabase Auth
      if (updates.isNotEmpty) {
        await _supabase.auth.updateUser(
          UserAttributes(
            email: updates['email'],
            data: updates['data'],
          ),
        );
      }

      // Atualizar tabela de usuários se existir
      if (username != null) {
        try {
          await SupabaseService.updateUser(currentUser.id, {
            'username': username,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          Logger.error('Tabela não encontrada', error: e);
        }
      }

      // CORREÇÃO: Recarregar dados do usuário corretamente
      final session = _supabase.auth.currentSession;
      if (session != null) {
        this.currentUser.value = session.user; // Usar this.currentUser.value
      }

      // Atualizar estatísticas do perfil
      if (Get.isRegistered<ProfileController>()) {
        ProfileController.to.refreshStats();
      }

      Get.snackbar('Sucesso', 'Perfil atualizado com sucesso');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar perfil: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      // Remover token push antes do logout
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await SupabaseService.removePushToken(token);
      }

      await _supabase.auth.signOut();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao fazer logout: ${e.toString()}');
    }
  }
}
