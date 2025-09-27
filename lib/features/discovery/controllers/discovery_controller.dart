import 'package:get/get.dart';
import 'package:my_collection_app/core/utils/logger.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/search_models.dart';
import '../../../shared/models/feed_item_model.dart';
import '../../../shared/models/discovery_models.dart';
import '../../../shared/models/category_model.dart';
import '../../auth/controllers/auth_controller.dart';

class DiscoveryController extends GetxController {
  static DiscoveryController get to => Get.find();
  
  static const String _tag = 'AuthController';

  final trendingItemsDaily = <TrendingItemModel>[].obs;
  final trendingItemsWeekly = <TrendingItemModel>[].obs;
  final trendingItemsMonthly = <TrendingItemModel>[].obs;
  final recentItems = <FeedItemModel>[].obs;
  final popularItems = <FeedItemModel>[].obs;
  final searchResults = <FeedItemModel>[].obs;
  final popularCategories = <CategoryModel>[].obs;
  
  final currentQuery = ''.obs;
  final currentFilters = SearchFilters().obs;
  final isSearching = false.obs;
  final hasMoreResults = true.obs;
  
  int _searchPage = 0;
  final int _itemsPerPage = 20;

  @override
  void onInit() {
    super.onInit();
    loadTrendingItems();
    loadPopularCategories();
  }

  Future<void> loadTrendingItems({String period = 'daily'}) async {
    try {
      final trending = await SupabaseService.getTrendingItems(
        period: period,
        limit: 20,
      );
      
      switch (period) {
        case 'daily':
        trendingItemsDaily.assignAll(trending.cast<TrendingItemModel>());
        break;
      case 'weekly':
        trendingItemsWeekly.assignAll(trending.cast<TrendingItemModel>());
        break;
      case 'monthly':
        trendingItemsMonthly.assignAll(trending.cast<TrendingItemModel>());
        break;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar itens em alta: ${e.toString()}');
    }
  }

  Future<void> loadRecentItems() async {
    try {
      final currentUserId = AuthController.to.currentUser.value?.id;
      final filters = SearchFilters(sortBy: 'recent');
      
      final response = await SupabaseService.searchItems(
        query: null,
        filters: filters,
        limit: 20,
        currentUserId: currentUserId,
      );
      
      final items = response.map((item) => 
        FeedItemModel.fromJson(item, currentUserId)
      ).toList();
      
      recentItems.assignAll(items);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar itens recentes: ${e.toString()}');
    }
  }

  Future<void> loadPopularItems() async {
    try {
      final currentUserId = AuthController.to.currentUser.value?.id;
      final filters = SearchFilters(sortBy: 'popular');
      
      final response = await SupabaseService.searchItems(
        query: null,
        filters: filters,
        limit: 20,
        currentUserId: currentUserId,
      );
      
      final items = response.map((item) => 
        FeedItemModel.fromJson(item, currentUserId)
      ).toList();
      
      popularItems.assignAll(items);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar itens populares: ${e.toString()}');
    }
  }

  Future<void> loadPopularCategories() async {
    try {
      final categories = await SupabaseService.getPopularCategories(limit: 10);
      popularCategories.assignAll(categories);
    } catch (e) {
      Logger.error('Erro ao carregar categorias populares: $e', tag: _tag, error: e);
    }
  }

  Future<void> searchItems(String query, {bool refresh = false}) async {
    if (refresh) {
      _searchPage = 0;
      hasMoreResults.value = true;
      searchResults.clear();
    }

    try {
      isSearching.value = true;
      currentQuery.value = query;
      
      final currentUserId = AuthController.to.currentUser.value?.id;
      final response = await SupabaseService.searchItems(
        query: query,
        filters: currentFilters.value,
        limit: _itemsPerPage,
        offset: _searchPage * _itemsPerPage,
        currentUserId: currentUserId,
      );

      if (response.isEmpty) {
        hasMoreResults.value = false;
      } else {
        final items = response.map((item) => 
          FeedItemModel.fromJson(item, currentUserId)
        ).toList();
        
        if (refresh) {
          searchResults.assignAll(items);
        } else {
          searchResults.addAll(items);
        }
        
        _searchPage++;
      }
      
      // Track search analytics
      if (currentUserId != null) {
        await _trackSearchEvent(query, searchResults.length);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha na busca: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> loadMoreResults() async {
    if (currentQuery.value.isNotEmpty && hasMoreResults.value) {
      await searchItems(currentQuery.value);
    }
  }

  void applyFilters(SearchFilters filters) {
    currentFilters.value = filters;
    if (currentQuery.value.isNotEmpty) {
      searchItems(currentQuery.value, refresh: true);
    }
  }

  void clearFilters() {
    currentFilters.value = SearchFilters();
    if (currentQuery.value.isNotEmpty) {
      searchItems(currentQuery.value, refresh: true);
    }
  }

  String getFiltersDescription() {
    final filters = currentFilters.value;
    final descriptions = <String>[];
    
    if (filters.category != null) {
      descriptions.add('Categoria: ${filters.category}');
    }
    
    if (filters.username != null) {
      descriptions.add('Por: ${filters.username}');
    }
    
    if (filters.startDate != null || filters.endDate != null) {
      descriptions.add('Período personalizado');
    }
    
    if (filters.isPromoted == true) {
      descriptions.add('Apenas promovidos');
    }
    
    return descriptions.join(', ');
  }

  List<TrendingItemModel> getTrendingItemsByPeriod(String period) {
    switch (period) {
      case 'daily':
        return trendingItemsDaily;
      case 'weekly':
        return trendingItemsWeekly;
      case 'monthly':
        return trendingItemsMonthly;
      default:
        return trendingItemsDaily;
    }
  }

  Future<void> _trackSearchEvent(String query, int resultsCount) async {
    try {
      final currentUserId = AuthController.to.currentUser.value?.id;
      if (currentUserId != null) {
        await SupabaseService.saveSearchQuery(
          userId: currentUserId,
          query: query,
          filters: currentFilters.value.toJson(),
          resultsCount: resultsCount,
        );
      }
    } catch (e) {
      Logger.error('Erro ao rastrear busca: $e', tag: _tag, error: e);
    }
  }

  

}
