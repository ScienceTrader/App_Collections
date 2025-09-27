import 'item_model.dart';

class TrendingItemModel {
  final String? id;
  final String itemId;
  final String periodType; // 'daily', 'weekly', 'monthly'
  final DateTime periodDate;
  final double trendingScore;
  final ItemModel? item;
  final DateTime? createdAt;

  TrendingItemModel({
    this.id,
    required this.itemId,
    required this.periodType,
    required this.periodDate,
    required this.trendingScore,
    this.item,
    this.createdAt,
  });

  factory TrendingItemModel.fromJson(Map<String, dynamic> json) {
    return TrendingItemModel(
      id: json['id'],
      itemId: json['item_id'],
      periodType: json['period_type'],
      periodDate: DateTime.parse(json['period_date']),
      trendingScore: (json['trending_score'] as num).toDouble(),
      item: json['items'] != null ? ItemModel.fromJson(json['items']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'period_type': periodType,
      'period_date': periodDate.toIso8601String().substring(0, 10),
      'trending_score': trendingScore,
    };
  }
}