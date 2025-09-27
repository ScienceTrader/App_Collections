import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/utils/logger.dart';



class SocialController extends GetxController {
  static SocialController get to => Get.find();
  
  final suggestedUsers = <UserModel>[].obs;
  final followingStatus = <String, bool>{}.obs;
  final isLoading = false.obs;

  static const String tag = 'SocialController';


  @override
  void onInit() {
    super.onInit();
    loadSuggestedUsers();
  }

  Future<void> loadSuggestedUsers() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      final users = await SupabaseService.getSuggestedUsers(currentUser.id);
      suggestedUsers.assignAll(users);
      
      // Load following status for each user
      for (final user in users) {
        final isFollowing = await SupabaseService.isFollowingUser(currentUser.id, user.id!);
        followingStatus[user.id!] = isFollowing;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar usuários sugeridos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.trim().length < 2) return [];
      
      return await SupabaseService.searchUsers(query.trim());
    } catch (e) {
      Logger.error('Erro na busca de usuários: $e', tag: 'SocialController');
      Get.snackbar('Erro', 'Falha na busca: ${e.toString()}');
      return [];
    }
  }

  Future<void> followUser(String userId) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      await SupabaseService.followUser(currentUser.id, userId);
      followingStatus[userId] = true;
      
      // Create notification
      await SupabaseService.createNotification(
        userId: userId,
        senderId: currentUser.id,
        type: 'follow',
        title: 'Novo seguidor',
        body: '${currentUser.userMetadata?['username'] ?? "Alguém"} começou a seguir você',
      );
      
      Get.snackbar('Sucesso', 'Usuário seguido com sucesso');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao seguir usuário: ${e.toString()}');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      await SupabaseService.unfollowUser(currentUser.id, userId);
      followingStatus[userId] = false;
      Get.snackbar('Sucesso', 'Usuário deixou de ser seguido');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao deixar de seguir usuário: ${e.toString()}');
    }
  }

  
}
