import 'item_model.dart';

class TrendingItemModel {
  final ItemModel item;
  final double trendingScore;
  final int totalLikes;
  final int totalComments;
  final int totalViews;

  TrendingItemModel({
    required this.item,
    required this.trendingScore,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalViews = 0,
  });

  factory TrendingItemModel.fromJson(Map<String, dynamic> json) {
    final item = ItemModel.fromJson(json);
    final likes = json['likes'] as List? ?? [];
    final comments = json['comments'] as List? ?? [];
    
    // Calcular score de trending baseado em engajamento
    final likesScore = likes.length * 2.0;
    final commentsScore = comments.length * 3.0;
    final viewsScore = (json['views_count'] ?? 0) * 1.0;
    
    final trendingScore = likesScore + commentsScore + viewsScore;
    
    return TrendingItemModel(
      item: item,
      trendingScore: trendingScore,
      totalLikes: likes.length,
      totalComments: comments.length,
      totalViews: json['views_count'] ?? 0,
    );
  }
}