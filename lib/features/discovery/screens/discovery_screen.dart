import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';
import '../widgets/trending_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_filters_bottom_sheet.dart';

class DiscoveryScreen extends StatefulWidget {
  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    DiscoveryController.to.loadTrendingItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descobrir'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar itens, usuários, categorias...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onSubmitted: (value) => _performSearch(value),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _showFilters,
                      icon: Icon(Icons.tune),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Em Alta'),
                  Tab(text: 'Recentes'),
                  Tab(text: 'Populares'),
                ],
                onTap: (index) => _handleTabChange(index),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final controller = DiscoveryController.to;
        
        if (controller.isSearching.value && controller.currentQuery.value.isNotEmpty) {
          return SearchResultsWidget();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildTrendingTab(),
            _buildRecentTab(),
            _buildPopularTab(),
          ],
        );
      }),
    );
  }

  Widget _buildTrendingTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Today
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Trending Hoje',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TrendingWidget(period: 'daily'),
          
          // Trending This Week
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Trending Esta Semana',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TrendingWidget(period: 'weekly'),
        ],
      ),
    );
  }

  Widget _buildRecentTab() {
    return Obx(() {
      final controller = DiscoveryController.to;
      
      return RefreshIndicator(
        onRefresh: () => controller.loadRecentItems(),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.recentItems.length,
          itemBuilder: (context, index) {
            final feedItem = controller.recentItems[index];
            final item = feedItem.item; // Extrair o ItemModel
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.inventory_2),
                      ),
                title: Text(item.name),
                subtitle: Text('Por ${feedItem.user.username ?? "Usuário"}'), // Usar feedItem.user
                trailing: Text(_formatTime(item.createdAt)),
                onTap: () => _openItem(feedItem), // Passar o feedItem completo
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPopularTab() {
    return Obx(() {
      final controller = DiscoveryController.to;
      
      return RefreshIndicator(
        onRefresh: () => controller.loadPopularItems(),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.popularItems.length,
          itemBuilder: (context, index) {
            final feedItem = controller.popularItems[index];
            final item = feedItem.item; // Extrair o ItemModel
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.inventory_2),
                      ),
                title: Text(item.name),
                subtitle: Text('Por ${feedItem.user.username ?? "Usuário"}'), // Usar feedItem.user
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.red),
                    Text(' ${feedItem.likesCount}'), // Usar feedItem.likesCount
                    SizedBox(width: 8),
                    Icon(Icons.comment, size: 16, color: Colors.blue),
                    Text(' ${feedItem.commentsCount}'), // Usar feedItem.commentsCount
                  ],
                ),
                onTap: () => _openItem(feedItem),
              ),
            );
          },
        ),
      );
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    DiscoveryController.to.searchItems(query);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchFiltersBottomSheet(),
    );
  }

  void _handleTabChange(int index) {
    final controller = DiscoveryController.to;
    switch (index) {
      case 0:
        controller.loadTrendingItems();
        break;
      case 1:
        controller.loadRecentItems();
        break;
      case 2:
        controller.loadPopularItems();
        break;
    }
  }

  void _openItem(dynamic item) {
    Get.snackbar('Info', 'Abrir item: ${item.name}');
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}