import 'user_model.dart';

class CommentModel {
  final String? id;
  final String itemId;
  final String userId;
  final String content;
  final UserModel? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommentModel({
    this.id,
    required this.itemId,
    required this.userId,
    required this.content,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      itemId: json['item_id'],
      userId: json['user_id'],
      content: json['content'],
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
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
      'item_id': itemId,
      'user_id': userId,
      'content': content,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}