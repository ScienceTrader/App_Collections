import 'item_model.dart';
import 'user_model.dart';

class FeedItemModel {
  final ItemModel item;
  final UserModel user;
  final bool isLikedByCurrentUser;
  final int likesCount;
  final int commentsCount;

  FeedItemModel({
    required this.item,
    required this.user,
    this.isLikedByCurrentUser = false,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json, String? currentUserId) {
    return FeedItemModel(
      item: ItemModel.fromJson(json),
      user: UserModel.fromJson(json['users'] ?? json['user'] ?? {}),
      isLikedByCurrentUser: _checkIfLiked(json, currentUserId),
      likesCount: json['likes_count'] ?? json['likes']?.length ?? 0,
      commentsCount: json['comments_count'] ?? json['comments']?.length ?? 0,
    );
  }

  static bool _checkIfLiked(Map<String, dynamic> json, String? currentUserId) {
    if (currentUserId == null) return false;
    
    final likes = json['likes'] as List?;
    if (likes != null) {
      return likes.any((like) => like['user_id'] == currentUserId);
    }
    
    return json['is_liked_by_current_user'] ?? false;
  }

  FeedItemModel copyWith({
    ItemModel? item,
    UserModel? user,
    bool? isLikedByCurrentUser,
    int? likesCount,
    int? commentsCount,
  }) {
    return FeedItemModel(
      item: item ?? this.item,
      user: user ?? this.user,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}