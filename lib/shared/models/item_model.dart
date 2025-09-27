import 'category_model.dart';

class ItemModel {
  final String? id;
  final String userId;
  final String? categoryId;
  final String? subcategoryId;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
  final CategoryModel? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItemModel({
    this.id,
    required this.userId,
    this.categoryId,
    this.subcategoryId,
    required this.name,
    this.description,
    this.imageUrl,
    this.isPublic = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      isPublic: json['is_public'] ?? false,
      likesCount: json['likes_count'] ?? json['likes']?.length ?? 0,
      commentsCount: json['comments_count'] ?? json['comments']?.length ?? 0,
      category: json['categories'] != null
          ? CategoryModel.fromJson(json['categories'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      'is_public': isPublic,
    };
  }

  ItemModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? subcategoryId,
    String? name,
    String? description,
    String? imageUrl,
    bool? isPublic,
    int? likesCount,
    int? commentsCount,
    CategoryModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}