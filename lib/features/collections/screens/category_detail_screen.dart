import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/collection_controller.dart';
import '../../../shared/models/category_model.dart';
import '../widgets/item_card.dart';
import '../../../app/routes.dart';

class CategoryDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CategoryModel category = Get.arguments as CategoryModel;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, category),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            color: _getCategoryColor(category.color),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.icon),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (category.description != null) ...[
                  SizedBox(height: 8),
                  Text(
                    category.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Itens', category.itemCount.toString()),
                    _buildStatCard('Públicos', '0'), // TODO: Count public items
                    _buildStatCard('Privados', '0'), // TODO: Count private items
                  ],
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: Obx(() {
              final controller = CollectionController.to;
              final items = controller.items.where((item) => item.categoryId == category.id).toList();

              if (controller.isLoading.value && items.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadItems(categoryId: category.id),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemCard(
                      item: item,
                      onVisibilityToggle: () => controller.toggleItemVisibility(item),
                      onDelete: () => _showDeleteDialog(item.id!, controller.deleteItem),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addItem),
        child: Icon(Icons.add),
        tooltip: 'Adicionar item',
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum item nesta categoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione seus primeiros itens a esta categoria',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.addItem),
              child: Text('Adicionar Item'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? colorHex) {
    if (colorHex == null) return Colors.blue;
    try {
      return Color(int.parse('FF$colorHex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'folder': return Icons.folder;
      case 'favorite': return Icons.favorite;
      case 'star': return Icons.star;
      case 'book': return Icons.book;
      case 'movie': return Icons.movie;
      case 'music_note': return Icons.music_note;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'restaurant': return Icons.restaurant;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'flight': return Icons.flight;
      case 'camera': return Icons.camera;
      case 'palette': return Icons.palette;
      default: return Icons.folder;
    }
  }

  void _handleMenuAction(String action, CategoryModel category) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit category screen
        Get.snackbar('Info', 'Funcionalidade de edição em desenvolvimento');
        break;
      case 'delete':
        _showDeleteDialog(category.id!, CollectionController.to.deleteCategory);
        break;
    }
  }

  void _showDeleteDialog(String id, Function(String) onDelete) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }
}