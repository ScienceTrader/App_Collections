class AnalyticsModel {
  final int totalItems;
  final int totalLikes;
  final int totalComments;
  final int totalViews;
  final double engagementRate;
  final List<CategoryAnalytics> categoryBreakdown;
  final List<DailyAnalytics> dailyData;
  final ItemAnalytics topItem;
  final DateTime startDate;
  final DateTime endDate;

  AnalyticsModel({
    required this.totalItems,
    required this.totalLikes,
    required this.totalComments,
    required this.totalViews,
    required this.engagementRate,
    required this.categoryBreakdown,
    required this.dailyData,
    required this.topItem,
    required this.startDate,
    required this.endDate,
  });

  factory AnalyticsModel.fromData({
    required List<dynamic> items,
    required List<dynamic> likes,
    required List<dynamic> comments,
    required List<dynamic> views,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Calcular métricas básicas
    final totalItems = items.length;
    final totalLikes = likes.length;
    final totalComments = comments.length;
    final totalViews = views.length;

    // Calcular taxa de engajamento
    final engagementRate = totalItems > 0 
        ? ((totalLikes + totalComments) / totalItems) * 100
        : 0.0;

    // Análise por categoria
    final categoryMap = <String, CategoryAnalytics>{};
    for (final item in items) {
      final categoryName = item['categories']?['name'] ?? 'Sem categoria';
      if (categoryMap.containsKey(categoryName)) {
        categoryMap[categoryName] = categoryMap[categoryName]!.copyWith(
          itemCount: categoryMap[categoryName]!.itemCount + 1,
        );
      } else {
        categoryMap[categoryName] = CategoryAnalytics(
          name: categoryName,
          itemCount: 1,
          likesCount: 0,
          commentsCount: 0,
        );
      }
    }

    // Análise diária (simplificada)
    final dailyData = <DailyAnalytics>[];
    final daysDiff = endDate.difference(startDate).inDays;
    for (int i = 0; i <= daysDiff; i++) {
      final date = startDate.add(Duration(days: i));
      dailyData.add(DailyAnalytics(
        date: date,
        items: 0,
        likes: 0,
        comments: 0,
      ));
    }

    // Item mais popular (simplificado)
    final topItem = ItemAnalytics(
      itemName: items.isNotEmpty ? items.first['name'] : 'Nenhum item',
      likes: totalLikes,
      comments: totalComments,
      views: totalViews,
    );

    return AnalyticsModel(
      totalItems: totalItems,
      totalLikes: totalLikes,
      totalComments: totalComments,
      totalViews: totalViews,
      engagementRate: engagementRate,
      categoryBreakdown: categoryMap.values.toList(),
      dailyData: dailyData,
      topItem: topItem,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class CategoryAnalytics {
  final String name;
  final int itemCount;
  final int likesCount;
  final int commentsCount;

  CategoryAnalytics({
    required this.name,
    required this.itemCount,
    required this.likesCount,
    required this.commentsCount,
  });

  CategoryAnalytics copyWith({
    String? name,
    int? itemCount,
    int? likesCount,
    int? commentsCount,
  }) {
    return CategoryAnalytics(
      name: name ?? this.name,
      itemCount: itemCount ?? this.itemCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}

class DailyAnalytics {
  final DateTime date;
  final int items;
  final int likes;
  final int comments;

  DailyAnalytics({
    required this.date,
    required this.items,
    required this.likes,
    required this.comments,
  });
}

class ItemAnalytics {
  final String itemName;
  final int likes;
  final int comments;
  final int views;

  ItemAnalytics({
    required this.itemName,
    required this.likes,
    required this.comments,
    required this.views,
  });
}