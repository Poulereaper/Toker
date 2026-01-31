enum SwipeAction {
  nope,
  like,
  superlike,
}

class Swipe {
  final String id;
  final String fromUserId;
  final String toUserId;
  final SwipeAction action;
  final DateTime timestamp;

  Swipe({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.action,
    required this.timestamp,
  });

  bool get isLike => action == SwipeAction.like || action == SwipeAction.superlike;
  bool get isSuperLike => action == SwipeAction.superlike;

  Swipe copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    SwipeAction? action,
    DateTime? timestamp,
  }) {
    return Swipe(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'action': action.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Swipe.fromJson(Map<String, dynamic> json) {
    return Swipe(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      action: SwipeAction.values.firstWhere(
        (e) => e.name == json['action'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
