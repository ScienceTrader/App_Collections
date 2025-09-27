import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/item_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import 'package:flutter/material.dart'; // Para usar AlertDialog


class CollectionController extends GetxController {
  static CollectionController get to => Get.find();

  final categories = <CategoryModel>[].obs;
  final items = <ItemModel>[].obs;
  final filteredItems = <ItemModel>[].obs;
  final isLoading = false.obs;
  final selectedCategory = Rx<CategoryModel?>(null);
  final showPublicOnly = false.obs;
  final currentSearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (AuthController.to.currentUser.value != null) {
      loadUserCollections();
      loadCategories();
      loadItems();
    }
  }

  void togglePublicFilter() {
    showPublicOnly.value = !showPublicOnly.value;
    _filterItems();
  }

  void updateSearchQuery(String query) {
    currentSearchQuery.value = query;
    _filterItems();
  }

  Future<void> loadUserCollections() async {
    try {
      isLoading.value = true;
      final userId = AuthController.to.currentUser.value?.id;
      if (userId != null) {
        categories.value = await SupabaseService.getCategories(userId);
        items.value = await SupabaseService.getItems(userId: userId);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar coleções: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) {
      Get.snackbar('Erro', 'Usuário não autenticado');
      return;
    }
    if (!SubscriptionController.to.canAddCategory()) {
      SubscriptionController.to.showLimitReachedDialog('categorias');
      return;
    }

    try {
      isLoading.value = true;

      final newCategory = category.copyWith(userId: currentUser.id);

      await SupabaseService.createCategory(newCategory);
      await loadCategories();

      Get.back();
      Get.snackbar('Sucesso', 'Categoria criada com sucesso');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao criar categoria: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  Future<void> loadCategories() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      final userCategories =
          await SupabaseService.getCategories(currentUser.id);
      categories.assignAll(userCategories);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar categorias: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(ItemModel item, {XFile? imageFile}) async {
    // Check subscription limits
    if (!SubscriptionController.to.canAddItem()) {
      SubscriptionController.to.showLimitReachedDialog('itens');
      _showUpgradeDialog('Itens');
      return;
    }

    try {
      isLoading.value = true;
      final userId = AuthController.to.currentUser.value?.id;
      if (userId == null) return;

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        imageUrl =
            await SupabaseService.uploadItemImage(imageFile.path, fileName);
      }

      final newItem = item.copyWith(
        userId: userId,
        imageUrl: imageUrl,
      );

      final createdItem = await SupabaseService.createItem(newItem);
      items.add(createdItem);

      Get.back();
      Get.snackbar('Sucesso', 'Item adicionado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao adicionar item: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /*void _applySearchFilter() {
    final searchQuery = SearchController.to.searchQuery.value;
    if (searchQuery.isNotEmpty) {
      final searchFiltered = filteredItems
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (item.description
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
                  false))
          .toList();
      filteredItems.assignAll(searchFiltered);
    }
  }*/

  Future<void> loadItems({String? categoryId}) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      final userItems = await SupabaseService.getItems(
        categoryId: categoryId,
        userId: currentUser.id,
      );
      items.assignAll(userItems);
      // Aplicar filtros após carregar
      _filterItems();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar itens: ${e.toString()}');
    }

  }

  final selectedCategoryFilter = Rxn<CategoryModel>();
  void filterByCategory(CategoryModel? category) {
    selectedCategoryFilter.value = category;
    _filterItems();
  }

  void _filterItems() {
    var filtered = items.toList();
    
    //Filtro de visibilidade
    if (showPublicOnly.value) {
      // Filtrar apenas itens públicos
      final publicItems = items.where((item) => item.isPublic).toList();
      filteredItems.assignAll(publicItems);
    } 

    // Filtrar por categoria 
    if (selectedCategoryFilter.value != null) {
    filtered = filtered.where((item) => 
      item.categoryId == selectedCategoryFilter.value!.id
    ).toList();
    } 
    //Filtro de busca
    if (currentSearchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.name.toLowerCase().contains(currentSearchQuery.value.toLowerCase()) ||
        (item.description?.toLowerCase().contains(currentSearchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }
    else {
      // Mostrar todos os itens
      filteredItems.assignAll(items);
    }
  }

  List<ItemModel> get displayItems => filteredItems;

  Future<void> deleteCategory(String categoryId) async {
    try {
      await SupabaseService.deleteCategory(categoryId);
      categories.removeWhere((cat) => cat.id == categoryId);
      items.removeWhere((item) => item.categoryId == categoryId);
      Get.snackbar('Sucesso', 'Categoria removida!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover categoria');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await SupabaseService.deleteItem(itemId);
      items.removeWhere((item) => item.id == itemId);
      Get.snackbar('Sucesso', 'Item removido!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover item');
    }
  }

  List<ItemModel> getItemsByCategory(String? categoryId) {
    if (categoryId == null) return items.toList();
    return items.where((item) => item.categoryId == categoryId).toList();
  }

  Future<void> toggleItemVisibility(ItemModel item) async {
    try {
      final newVisibility = !item.isPublic;
      await SupabaseService.updateItemVisibility(item.id!, newVisibility);

      // Atualizar item local
      final itemIndex = items.indexWhere((i) => i.id == item.id);
      if (itemIndex != -1) {
        items[itemIndex] = item.copyWith(isPublic: newVisibility);
      }

      Get.snackbar('Sucesso',
          newVisibility ? 'Item tornado público' : 'Item tornado privado');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar visibilidade: ${e.toString()}');
    }
  }

  void _showUpgradeDialog(String feature) {
    Get.dialog(
      AlertDialog(
        title: Text('Limite Atingido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Você atingiu o limite de $feature da versão gratuita.'),
            SizedBox(height: 16),
            Text('Upgrade para Premium:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Semanal - R\$ 4,99'),
              subtitle: Text('Cancelar a qualquer momento'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Anual - R\$ 39,99'),
              subtitle: Text('Economia de 75%'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              SubscriptionController.to.showUpgradeBottomSheet();
            },
            child: Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
