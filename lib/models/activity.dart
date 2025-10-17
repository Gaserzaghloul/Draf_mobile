enum ActivityType {
  deviceConnected,
  deviceDisconnected,
  messageSent,
  messageReceived,
  resourceShared,
  resourceDownloaded,
  sosAlert,
  profileUpdated,
}

class Activity {
  final String id;
  final String userId;
  final ActivityType type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata != null ? metadata.toString() : null,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      userId: map['userId'],
      type: ActivityType.values.firstWhere((e) => e.name == map['type']),
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      metadata: map['metadata'] != null ? 
        Map<String, dynamic>.from(map['metadata']) : null,
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}
