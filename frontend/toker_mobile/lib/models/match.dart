import 'package:flutter/material.dart';
import 'profile.dart';

class Match {
  final String id;
  final Profile profile;
  final DateTime matchedAt;
  final double compatibilityScore;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isUnread;

  Match({
    required this.id,
    required this.profile,
    required this.matchedAt,
    required this.compatibilityScore,
    this.lastMessage,
    this.lastMessageTime,
    this.isUnread = false,
  });

  Match copyWith({
    String? id,
    Profile? profile,
    DateTime? matchedAt,
    double? compatibilityScore,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isUnread,
  }) {
    return Match(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      matchedAt: matchedAt ?? this.matchedAt,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile.toJson(),
      'matchedAt': matchedAt.toIso8601String(),
      'compatibilityScore': compatibilityScore,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'isUnread': isUnread,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      matchedAt: DateTime.parse(json['matchedAt'] as String),
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime'] as String) 
          : null,
      isUnread: json['isUnread'] as bool? ?? false,
    );
  }
}
