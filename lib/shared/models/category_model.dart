class CategoryModel {
  final String? id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int itemCount;
  final int subcategoryCount;
  final DateTime? createdAt;

  CategoryModel({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.itemCount = 0,
    this.subcategoryCount = 0,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      itemCount: json['items']?.length ?? json['item_count'] ?? 0,
      subcategoryCount: json['subcategories']?.length ?? json['subcategory_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? itemCount,
    int? subcategoryCount,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      itemCount: itemCount ?? this.itemCount,
      subcategoryCount: subcategoryCount ?? this.subcategoryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}