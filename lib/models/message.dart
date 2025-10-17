enum MessageType {
  text,
  image,
  file,
  sos,
  voice,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      type: MessageType.values.firstWhere((e) => e.name == map['type']),
      status: MessageStatus.values.firstWhere((e) => e.name == map['status']),
      timestamp: DateTime.parse(map['timestamp']),
      filePath: map['filePath'],
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      isRead: map['isRead'] == 1,
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? filePath,
    String? fileName,
    int? fileSize,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isRead: isRead ?? this.isRead,
    );
  }
}
