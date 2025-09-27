import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/models/item_model.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onDelete;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onVisibilityToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'visibility',
                          child: Row(
                            children: [
                              Icon(item.isPublic ? Icons.visibility_off : Icons.visibility),
                              SizedBox(width: 8),
                              Text(item.isPublic ? 'Tornar privado' : 'Tornar público'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Excluir'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                if (item.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 8),
                
                Row(
                  children: [
                    if (item.category != null) ...[
                      Icon(
                        Icons.folder,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4),
                      Text(
                        item.category!.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Spacer(),
                    ],
                    
                    Icon(
                      item.isPublic ? Icons.public : Icons.lock,
                      size: 12,
                      color: item.isPublic ? Colors.green : Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      item.isPublic ? 'Público' : 'Privado',
                      style: TextStyle(
                        fontSize: 10,
                        color: item.isPublic ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                if (item.isPublic) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: Colors.red),
                      SizedBox(width: 4),
                      Text('${item.likesCount}', style: TextStyle(fontSize: 10)),
                      SizedBox(width: 12),
                      Icon(Icons.comment, size: 12, color: Colors.blue),
                      SizedBox(width: 4),
                      Text('${item.commentsCount}', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'visibility':
        onVisibilityToggle();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }
}
