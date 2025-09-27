import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/collection_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../widgets/category_card.dart';
import '../widgets/item_card.dart';
import '../../../app/routes.dart';
import '../../../shared/widgets/premium_badge.dart';
import '../../../core/constants/app_constants.dart';


class HomeScreen extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Minhas Coleções'),
      actions: [
        // Premium Badge
        Obx(() => SubscriptionController.to.isPremium.value
            ? PremiumBadge()
            : _buildUpgradeButton()),
        
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Perfil'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'feed',
              child: Row(
                children: [
                  Icon(Icons.public),
                  SizedBox(width: 8),
                  Text('Feed Social'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Configurações'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar itens...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (query) => CollectionController.to.updateSearchQuery(query),
                ),
              ),
              SizedBox(width: 8),
              Obx(() => FilterChip(
                label: Text('Públicos'),
                selected: CollectionController.to.showPublicOnly.value,
                onSelected: (_) => CollectionController.to.togglePublicFilter(),
              )),
            ],
          ),
        ),
      ),
    ),
    body: Column(
      children: [
        // Indicador de limites para usuários gratuitos
        _buildLimitIndicator(),
        
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Categorias'),
                    Tab(text: 'Itens'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCategoriesTab(),
                      _buildItemsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "add_category",
          onPressed: SubscriptionController.to.canAddCategory() 
              ? () => Get.toNamed(AppRoutes.addCategory)
              : () => SubscriptionController.to.showLimitReachedDialog('categorias'),
          backgroundColor: SubscriptionController.to.canAddCategory() 
              ? null 
              : Colors.grey,
          child: Icon(Icons.create_new_folder),
          tooltip: SubscriptionController.to.canAddCategory() 
              ? 'Nova Categoria' 
              : 'Limite atingido - Upgrade para Premium',
        ),
        SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "add_item",
          onPressed: SubscriptionController.to.canAddItem()
              ? () => Get.toNamed(AppRoutes.addItem)
              : () => SubscriptionController.to.showLimitReachedDialog('itens'),
          backgroundColor: SubscriptionController.to.canAddItem() 
              ? null 
              : Colors.grey,
          child: Icon(Icons.add),
          tooltip: SubscriptionController.to.canAddItem()
              ? 'Novo Item'
              : 'Limite atingido - Upgrade para Premium',
        ),
      ],
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}

Widget _buildLimitIndicator() {
  return Obx(() {
    final controller = SubscriptionController.to;
    if (controller.isPremium.value) return SizedBox();
    
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
              SizedBox(width: 8),
              Text(
                'Plano Gratuito',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.payment),
                child: Text('Upgrade'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(controller.getCategoryLimitText()),
          Text(controller.getItemLimitText()),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: CollectionController.to.categories.length / AppConstants.freeCategoriesLimit,
            backgroundColor: Colors.orange.shade100,
            color: Colors.orange,
          ),
        ],
      ),
    );
  });
}

  Widget _buildUpgradeButton() {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => Get.toNamed(AppRoutes.payment),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          minimumSize: Size(80, 32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16),
            SizedBox(width: 4),
            Text('Upgrade', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Obx(() {
      final controller = CollectionController.to;
      
      if (controller.isLoading.value && controller.categories.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.categories.isEmpty) {
        return _buildEmptyState(
          icon: Icons.folder_outlined,
          title: 'Nenhuma categoria ainda',
          subtitle: 'Crie sua primeira categoria para organizar seus itens',
          actionText: 'Criar Categoria',
          onPressed: () => Get.toNamed(AppRoutes.addCategory),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadCategories,
        child: MasonryGridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(16),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return CategoryCard(
              category: category,
              onTap: () {
                CollectionController.to.selectCategory(category);
                Get.toNamed(AppRoutes.categoryDetail, arguments: category);
              },
              onDelete: () => _showDeleteDialog(
                'categoria',
                () => controller.deleteCategory(category.id!),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildItemsTab() {
    return Obx(() {
      final controller = CollectionController.to;
      
      if (controller.isLoading.value && controller.items.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      // Usar displayItems ao invés de items
      final itemsToShow = controller.displayItems;
      
      if (itemsToShow.isEmpty) {
        return _buildEmptyState(
          icon: Icons.inventory_2_outlined,
          title: controller.showPublicOnly.value 
              ? 'Nenhum item público'
              : 'Nenhum item ainda',
          subtitle: controller.showPublicOnly.value
              ? 'Você não possui itens públicos'
              : 'Adicione seus primeiros itens à sua coleção',
          actionText: 'Adicionar Item',
          onPressed: () => Get.toNamed(AppRoutes.addItem),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadItems(),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(16),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: itemsToShow.length,
          itemBuilder: (context, index) {
            final item = itemsToShow[index];
            return ItemCard(
              item: item,
              onVisibilityToggle: () => controller.toggleItemVisibility(item),
              onDelete: () => _showDeleteDialog(
                'item',
                () => controller.deleteItem(item.id!),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: _onBottomNavTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Descobrir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Get.toNamed(AppRoutes.discovery);
        break;
      case 2:
        Get.toNamed(AppRoutes.feed);
        break;
      case 3:
        if (SubscriptionController.to.isPremium.value) {
          Get.toNamed(AppRoutes.analytics);
        } else {
          SubscriptionController.to.showUpgradeDialog();
        }
        break;
      case 4:
        Get.toNamed(AppRoutes.profile);
        break;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        Get.toNamed(AppRoutes.profile);
        break;
      case 'feed':
        Get.toNamed(AppRoutes.feed);
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Configurações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificações'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification settings
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Tema Escuro'),
              trailing: Switch(
                value: Get.isDarkMode,
                onChanged: (value) {
                  Get.changeThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String itemType, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir esta $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }
}