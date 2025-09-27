class UserModel {
  final String? id;
  final String? email;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int itemsCount;
  final String? subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? commonCategories;
  final int? engagementScore;
  final String? suggestionReason;

  UserModel({
    this.id,
    this.email,
    this.username,
    this.avatarUrl,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.itemsCount = 0,
    this.subscriptionTier,
    this.subscriptionExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.commonCategories,
    this.engagementScore,
    this.suggestionReason,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
      subscriptionTier: json['subscription_tier'],
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      commonCategories: json['common_categories'],
      engagementScore: json['engagement_score'],
      suggestionReason: json['suggestion_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'items_count': itemsCount,
      if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
      if (subscriptionExpiresAt != null) 
        'subscription_expires_at': subscriptionExpiresAt!.toIso8601String(),
      if(commonCategories != null) 'commonCategories':commonCategories,
      if(engagementScore != null) 'engagementScore':engagementScore,
      if(suggestionReason != null) 'suggestionReason':suggestionReason,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? itemsCount,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? commonCategories,
    int? engagementScore,
    String? suggestionReason,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      itemsCount: itemsCount ?? this.itemsCount,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commonCategories: commonCategories ?? this.commonCategories,
      engagementScore: engagementScore ?? this.engagementScore,
      suggestionReason: suggestionReason ?? this.suggestionReason,
    );
  }

  bool get isPremium => subscriptionTier == 'premium' && 
      (subscriptionExpiresAt?.isAfter(DateTime.now()) ?? false);

  String get displayName => username ?? email ?? 'Usuário';
}