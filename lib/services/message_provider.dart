import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../database/database_service.dart';
import 'network_provider.dart';

class MessageProvider extends ChangeNotifier {
  final NetworkProvider _networkProvider;

  List<Message> _messages = [];
  User? _currentUser; // Needed for senderId

  List<Message> get messages => _messages;

  MessageProvider(this._networkProvider) {
    // Register callback for incoming messages
    _networkProvider.onMessageReceived = _handleIncomingMessage;
  }

  Future<void> loadMessages() async {
    _messages = await DatabaseService.getAllMessages();
    notifyListeners();
  }

  // Ensure we reload/refresh if user Context changes significantly (though messages are usually global to device owner)
  void updateUser(User? user) {
    final wasNull = _currentUser == null;
    _currentUser = user;
    if (wasNull && user != null && _messages.isEmpty) {
      loadMessages(); // Just in case it wasn't valid before
    }
  }

  List<Message> getMessagesForUser(String userId) {
    return _messages
        .where(
          (message) =>
              message.senderId == userId || message.receiverId == userId,
        )
        .toList();
  }

  Future<bool> sendMessage({
    required String content,
    required String receiverId,
    MessageType type = MessageType.text,
  }) async {
    if (_currentUser == null) return false;
    if (!_networkProvider.isConnected) return false;

    // Create Message Object
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUser!.id,
      receiverId: receiverId,
      content: content,
      type: type,
      status: MessageStatus.sent, // Set as sent immediately
      timestamp: DateTime.now(),
      senderName: _currentUser!.name,
    );

    // Add locally
    _addMessage(message);

    // Save generated message to DB
    await DatabaseService.insertMessage(message);

    // Construct JSON Payload
    final Map<String, dynamic> jsonPayload = {
      'type': 'chat',
      'id': message.id,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
    };

    final jsonString = jsonEncode(jsonPayload);

    // Send via P2P
    final success = await _networkProvider.p2pService.sendMessage(jsonString);

    if (!success) {
      return false;
    }

    return true;
  }

  // Send Read Receipt
  Future<void> sendReadReceipt(String messageId, String senderId) async {
    if (_currentUser == null) return;

    final Map<String, dynamic> jsonPayload = {
      'type': 'read_receipt',
      'messageId': messageId,
      'readerId': _currentUser!.id,
      'readerName': _currentUser!.name,
    };

    final jsonString = jsonEncode(jsonPayload);
    await _networkProvider.p2pService.sendMessage(jsonString);
  }

  void _addMessage(Message message) {
    // Maintain DESC sort order (Newest at Index 0)
    _messages.insert(0, message);
    notifyListeners();
  }

  Future<void> markAsRead(String messageId, String senderId) async {
    if (_currentUser == null) return;

    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      if (_messages[index].isRead) return; // Already read

      final updatedMessage = _messages[index].copyWith(isRead: true);
      _messages[index] = updatedMessage;
      // Don't notify listeners here if we call this in build/frame callbacks to avoid loops?
      // Actually usually safe if called in post frame callback.
      notifyListeners();
      await DatabaseService.updateMessage(updatedMessage);

      // Send receipt to sender
      await sendReadReceipt(messageId, senderId);
    }
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final updatedMessage = _messages[index].copyWith(status: status);
      _messages[index] = updatedMessage;
      DatabaseService.updateMessage(updatedMessage);
      notifyListeners();
    }
  }

  void _handleIncomingMessage(String rawContent) {
    if (_currentUser == null) return;

    try {
      final json = jsonDecode(rawContent);
      final msgType = json['type'];

      // Handle standard Chat Message
      if (msgType == 'chat') {
        final content = json['content'];
        final senderId = json['senderId'];
        final senderName = json['senderName'];
        final timestampStr = json['timestamp'];
        final messageId =
            json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

        // Check for duplicates (same content / ID)
        final alreadyExists = _messages.any((m) => m.id == messageId);
        if (alreadyExists) return;

        // Create message object calling it "delivered" instantly as we received it
        final receivedMessage = Message(
          id: messageId,
          senderId: senderId ?? 'p2p_sender',
          receiverId: _currentUser!.id,
          content: content,
          type: MessageType.text,
          status: MessageStatus.delivered,
          timestamp: timestampStr != null
              ? DateTime.parse(timestampStr)
              : DateTime.now(),
          senderName: senderName ?? 'Unknown User',
        );

        _addMessage(receivedMessage);
        DatabaseService.insertMessage(receivedMessage);

        _logActivity(
          ActivityType.messageReceived,
          'Received P2P message from $senderName',
        );
        return;
      } else if (msgType == 'read_receipt') {
        // Handle Read Receipt
        final messageId = json['messageId'];
        if (messageId != null) {
          _updateMessageStatus(messageId, MessageStatus.read);
        }
      }
    } catch (e) {
      // Fallback for legacy raw string messages
      _handleLegacyMessage(rawContent);
    }
  }

  void _handleLegacyMessage(String content) {
    if (_currentUser == null) return;

    // Legacy duplicate check
    final now = DateTime.now();
    final isDuplicate = _messages.any((msg) {
      final timeDiff = now.difference(msg.timestamp).abs().inSeconds;
      return msg.content == content && timeDiff < 2;
    });

    if (isDuplicate) return;

    final receivedMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'p2p_sender',
      receiverId: _currentUser!.id,
      content: content,
      type: MessageType.text,
      status: MessageStatus.delivered,
      timestamp: DateTime.now(),
      senderName: 'Unknown',
    );

    _addMessage(receivedMessage);
    DatabaseService.insertMessage(receivedMessage);

    _logActivity(ActivityType.messageReceived, 'Received legacy P2P message');
  }

  Future<void> _logActivity(ActivityType type, String description) async {
    if (_currentUser == null) return;
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.id,
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );
    await DatabaseService.insertActivity(activity);
  }
}