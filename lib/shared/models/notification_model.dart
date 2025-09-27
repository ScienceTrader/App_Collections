import 'package:flutter/material.dart';
import 'user_model.dart';

class NotificationModel {
  final String? id;
  final String userId;
  final String? senderId;
  final String type;
  final String title;
  final String body;
  final String? itemId;
  final bool isRead;
  final DateTime? createdAt;
  final UserModel? sender;

  NotificationModel({
    this.id,
    required this.userId,
    this.senderId,
    required this.type,
    required this.title,
    required this.body,
    this.itemId,
    this.isRead = false,
    this.createdAt,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      senderId: json['sender_id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      itemId: json['item_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      sender: json['sender'] != null 
          ? UserModel.fromJson(json['sender']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (senderId != null) 'sender_id': senderId,
      'type': type,
      'title': title,
      'body': body,
      if (itemId != null) 'item_id': itemId,
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? senderId,
    String? type,
    String? title,
    String? body,
    String? itemId,
    bool? isRead,
    DateTime? createdAt,
    UserModel? sender,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      itemId: itemId ?? this.itemId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }

  // Helpers para UI
  IconData get icon {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'system':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get displayText {
    if (sender != null) {
      final senderName = sender!.username ?? sender!.email ?? 'Alguém';
      switch (type) {
        case 'like':
          return '$senderName curtiu seu item';
        case 'comment':
          return '$senderName comentou em seu item';
        case 'follow':
          return '$senderName começou a seguir você';
        default:
          return body;
      }
    }
    return body;
  }
}