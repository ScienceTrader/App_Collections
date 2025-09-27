import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();
  
  final followersCount = 0.obs;
  final followingCount = 0.obs;
  final itemsCount = 0.obs;
  final categoriesCount = 0.obs;
  final isLoading = false.obs;
  
  static const String _tag = 'ProfileController';

  @override
  void onInit() {
    super.onInit();
    loadUserStats();
  }

  Future<void> loadUserStats() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      
      await Future.wait([
        _loadFollowersCount(currentUser.id),
        _loadFollowingCount(currentUser.id),
        _loadItemsCount(currentUser.id),
        _loadCategoriesCount(currentUser.id),
      ]);
      
    } catch (e) {
      Logger.error('Erro ao carregar estatísticas do usuário', tag: _tag, error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFollowersCount(String userId) async {
    try {
      final count = await SupabaseService.getFollowersCount(userId);
      followersCount.value = count;
    } catch (e) {
      Logger.error('Erro ao carregar seguidores', tag: _tag, error: e);
    }
  }

  Future<void> _loadFollowingCount(String userId) async {
    try {
      final count = await SupabaseService.getFollowingCount(userId);
      followingCount.value = count;
    } catch (e) {
      Logger.error('Erro ao carregar seguindo', tag: _tag, error: e);
    }
  }

  Future<void> _loadItemsCount(String userId) async {
    try {
      final count = await SupabaseService.getUserItemsCount(userId);
      itemsCount.value = count;
    } catch (e) {
      Logger.error('Erro ao carregar itens', tag: _tag, error: e);
    }
  }

  Future<void> _loadCategoriesCount(String userId) async {
    try {
      final count = await SupabaseService.getUserCategoriesCount(userId);
      categoriesCount.value = count;
    } catch (e) {
      Logger.error('Erro ao carregar categorias', tag: _tag, error: e);
    }
  }

  Future<void> refreshStats() async {
    await loadUserStats();
  }
}