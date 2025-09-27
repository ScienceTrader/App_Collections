import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';
import '../../feed/widgets/enhanced_feed_item_card.dart';

class SearchResultsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFiltersInfo(),
        Expanded(
          child: Obx(() {
            final controller = DiscoveryController.to;
            
            if (controller.isSearching.value && controller.searchResults.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.searchResults.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => controller.searchItems(
                controller.currentQuery.value, 
                refresh: true,
              ),
              child: ListView.builder(
                itemCount: controller.searchResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.searchResults.length) {
                    if (controller.hasMoreResults.value && !controller.isSearching.value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.loadMoreResults();
                      });
                    }
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: controller.hasMoreResults.value
                          ? Center(child: CircularProgressIndicator())
                          : Center(child: Text('Fim dos resultados')),
                    );
                  }

                  final feedItem = controller.searchResults[index];
                  return EnhancedFeedItemCard(feedItem: feedItem);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFiltersInfo() {
    return Obx(() {
      final controller = DiscoveryController.to;
      final hasFilters = controller.currentFilters.value.hasActiveFilters;
      
      if (!hasFilters && controller.currentQuery.value.isEmpty) {
        return SizedBox();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.currentQuery.value.isNotEmpty)
                    Text(
                      'Resultados para "${controller.currentQuery.value}"',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (hasFilters)
                    Text(
                      controller.getFiltersDescription(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    '${controller.searchResults.length} itens encontrados',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            if (hasFilters)
              TextButton(
                onPressed: () => controller.clearFilters(),
                child: Text('Limpar Filtros'),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tente alterar os filtros ou buscar por outros termos',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => DiscoveryController.to.clearFilters(),
              child: Text('Limpar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}