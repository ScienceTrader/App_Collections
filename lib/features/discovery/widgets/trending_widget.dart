import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/discovery_controller.dart';

class TrendingWidget extends StatelessWidget {
  final String period;
  
  const TrendingWidget({Key? key, required this.period}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Obx(() {
        final controller = DiscoveryController.to;
        final trendingItems = controller.getTrendingItemsByPeriod(period);
        
        if (trendingItems.isEmpty) {
          return Center(
            child: Text(
              'Nenhum item em alta ainda',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: trendingItems.length,
          itemBuilder: (context, index) {
            final trending = trendingItems[index];
            return _buildTrendingCard(trending);
          },
        );
      }),
    );
  }

  Widget _buildTrendingCard(dynamic trending) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: trending.item?.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: trending.item!.imageUrl!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 100,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.inventory_2, size: 40),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTrendingColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTrendingIcon(),
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2),
                        Text(
                          _getTrendingLabel(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trending.item?.name ?? 'Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Por ${trending.item?.user?.username ?? "Usuário"}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        '${trending.trendingScore?.toStringAsFixed(0) ?? "0"} pts',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendingColor() {
    switch (period) {
      case 'daily':
        return Colors.orange;
      case 'weekly':
        return Colors.purple;
      case 'monthly':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTrendingIcon() {
    switch (period) {
      case 'daily':
        return Icons.local_fire_department;
      case 'weekly':
        return Icons.trending_up;
      case 'monthly':
        return Icons.star;
      default:
        return Icons.trending_up;
    }
  }

  String _getTrendingLabel() {
    switch (period) {
      case 'daily':
        return 'HOT';
      case 'weekly':
        return 'ALTA';
      case 'monthly':
        return 'TOP';
      default:
        return 'TREND';
    }
  }
}
