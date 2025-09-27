import 'package:get/get.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/models/category_model.dart';
import 'collection_controller.dart';

class SearchController extends GetxController {
  static SearchController get to => Get.find<SearchController>();
  
  final searchQuery = ''.obs;
  final filteredItems = <ItemModel>[].obs;
  final filteredCategories = <CategoryModel>[].obs;
  final isSearching = false.obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      clearSearch();
    } else {
      _performSearch(query);
    }
  }

  void _performSearch(String query) {
    isSearching.value = true;
    
    // Filtrar itens
    final allItems = CollectionController.to.items;
    filteredItems.assignAll(
      allItems.where((item) => 
        item.name.toLowerCase().contains(query.toLowerCase()) ||
        (item.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList()
    );

    // Filtrar categorias
    final allCategories = CollectionController.to.categories;
    filteredCategories.assignAll(
      allCategories.where((category) => 
        category.name.toLowerCase().contains(query.toLowerCase()) ||
        (category.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList()
    );

    isSearching.value = false;
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredItems.clear();
    filteredCategories.clear();
    isSearching.value = false;
  }
}