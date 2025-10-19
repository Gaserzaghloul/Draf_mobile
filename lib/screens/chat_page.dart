import 'package:flutter/material.dart';
import '../models/message.dart'; // Keeping for structure

class ChatPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const ChatPage({super.key, required this.deviceId, required this.deviceName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Dummy messages for UI
  final List<Message> _messages = [
    Message(
      id: '1',
      senderId: 'other',
      receiverId: 'me',
      content: 'Are you safe?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      status: MessageStatus.read,
      type: MessageType.text,
    ),
    Message(
      id: '2',
      senderId: 'me',
      receiverId: 'other',
      content: 'Yes, I am near the shelter.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      status: MessageStatus.read,
      type: MessageType.text,
    ),
    Message(
      id: '3',
      senderId: 'other',
      receiverId: 'me',
      content: 'Good to know. Do you need supplies?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      status: MessageStatus.delivered,
      type: MessageType.text,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Send message.
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      receiverId: widget.deviceId,
      content: _messageController.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      type: MessageType.text,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.deviceName),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, color: Colors.greenAccent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Call feature not implemented in UI demo"),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'me';
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final time =
        "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFD4AF37) // Gold for me
              : const Color(0xFF2C3E50), // Navy/Grey for others
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? const Color(0xFF101820) : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe
                        ? const Color(0xFF101820).withOpacity(0.6)
                        : Colors.white70,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == MessageStatus.read
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color: const Color(0xFF101820).withOpacity(0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2631),
        border: const Border(top: BorderSide(color: Color(0xFF2C3E50))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFFD4AF37)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Voice note demo")),
                );
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2C3E50)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    filled: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF101820)),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}