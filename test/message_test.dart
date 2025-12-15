import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_app/models/message.dart';

void main() {
  group('Message Model Tests', () {
    // Check if the basic constructor works and assigns fields correctly
    test('should create Message instance correctly', () {
      final message = Message(
        id: '1',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Hello World',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Verify key fields match what we passed in
      expect(message.id, '1');
      expect(message.content, 'Hello World');
      expect(message.type, MessageType.text);
    });

    // Validates JSON serialization for database storage
    test('should convert to Map and back', () {
      final timestamp = DateTime.now();
      final message = Message(
        id: '1',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Test Message',
        type: MessageType.sos, // Testing critical message types
        status: MessageStatus.delivered,
        timestamp: timestamp,
        senderName: 'Test Sender',
      );

      // 1. Convert to JSON Map (Simulating DB insert)
      final map = message.toMap();
      expect(map['id'], '1');
      expect(map['type'], 'sos'); // Enums should store as strings
      expect(map['senderName'], 'Test Sender');

      // 2. Convert back to Object (Simulating DB read)
      final newMessage = Message.fromMap(map);
      expect(newMessage.id, message.id);
      expect(newMessage.content, message.content);
      expect(newMessage.type, message.type);
      expect(newMessage.status, message.status);

      // Compare ISO strings to ignore microsecond differences
      expect(
        newMessage.timestamp.toIso8601String(),
        timestamp.toIso8601String(),
      );
    });

    // Ensures we can modify specific fields while keeping value semantics
    test('should copyWith updated fields', () {
      final message = Message(
        id: '1',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Original',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      // Create a new instance with just the status changed
      final updated = message.copyWith(
        status: MessageStatus.read,
        isRead: true,
      );

      expect(updated.id, '1'); // ID should stay the same
      expect(updated.status, MessageStatus.read); // Status should change
      expect(updated.isRead, true);
      expect(updated.content, 'Original'); // Content should stay the same
    });
  });
}
