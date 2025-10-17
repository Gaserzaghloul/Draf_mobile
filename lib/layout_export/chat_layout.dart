import 'package:flutter/material.dart';

class ChatPageLayoutOnly extends StatelessWidget {
  const ChatPageLayoutOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          _buildConnectedDevicesBar(),
          Expanded(child: _buildMessagesListPlaceholder()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConnectedDevicesBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.devices, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(3, (i) => _chip('Device ${i + 1}')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      );

  Widget _buildMessagesListPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => _messageBubble(index.isOdd),
    );
  }

  Widget _messageBubble(bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFF1E3A8A), child: Text('U', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF1E3A8A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    const Text('user-id', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  Text(
                    'Message content',
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('12:00', style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.grey[600])),
                    if (isMe) const SizedBox(width: 4),
                    if (isMe) const Icon(Icons.check, size: 12, color: Colors.white70),
                  ])
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe) const CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Text('M', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF1E3A8A))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.send, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


