import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/message_provider.dart';
import '../services/network_provider.dart';
import '../services/user_provider.dart';
import '../models/message.dart';

class ChatPage extends StatefulWidget {
  final String? deviceId; // Added to match usage in _loadMessages

  const ChatPage({super.key, this.deviceId}); // Updated constructor

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Force scroll to bottom (visually) on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });

    // Check if we need to load messages for a specific device context
    if (widget.deviceId != null) {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showDeviceSelector,
            icon: const Icon(Icons.people),
          ),
        ],
      ),
      body: Consumer3<MessageProvider, NetworkProvider, UserProvider>(
        builder:
            (context, messageProvider, networkProvider, userProvider, child) {
              return Column(
                children: [
                  // Connected Devices Bar
                  _buildConnectedDevicesBar(networkProvider),

                  // Messages List
                  Expanded(
                    child: _buildMessagesList(messageProvider, userProvider),
                  ),

                  // Message Input
                  _buildMessageInput(),
                ],
              );
            },
      ),
    );
  }

  Widget _buildConnectedDevicesBar(NetworkProvider networkProvider) {
    final hasConnectedDevices = networkProvider.connectedDevices.any(
      (d) => d.isConnected,
    );

    if (networkProvider.connectedDevices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red[50],
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No devices found. Go to Network Dashboard to discover devices.',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
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
                    children: networkProvider.connectedDevices.map((device) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: device.isConnected
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              device.isConnected
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              device.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!hasConnectedDevices)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Devices discovered but not connected. Tap "Tap to Connect" in Network Dashboard to connect.',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessagesList(
    MessageProvider messageProvider,
    UserProvider userProvider,
  ) {
    if (messageProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with connected devices',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Mark unread messages as read

    // We'll wrap in a post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myId = userProvider.currentUser?.id;
      if (myId == null) return;

      // Receipt sending logic would go here if needed.
    });

    // Fix: ListView(reverse: true) puts Index 0 at the bottom.
    // messageProvider.messages is Newest-First (DESC).
    // So Index 0 is Newest. This is exactly what we want.
    final messages = messageProvider.messages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      reverse: true, // Index 0 (Newest) is at bottom
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        _checkAndSendReadReceipt(message, userProvider, messageProvider);
        return _buildMessageBubble(message, userProvider);
      },
    );
  }

  void _checkAndSendReadReceipt(
    Message message,
    UserProvider userProvider,
    MessageProvider messageProvider,
  ) {
    final myId = userProvider.currentUser?.id;
    if (myId != null && message.senderId != myId && !message.isRead) {
      // Send Read receipt
      Future.microtask(() {
        messageProvider.markAsRead(message.id, message.senderId);
      });
    }
  }

  Widget _buildMessageBubble(Message message, UserProvider userProvider) {
    final isMe = message.senderId == userProvider.currentUser?.id;
    final displayName = message.senderName ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // Other User Avatar
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1E3A8A),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message Bubble
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
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        // Status Icon logic
                        _buildStatusIcon(message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Me User Avatar
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                userProvider.currentUser?.name.isNotEmpty == true
                    ? userProvider.currentUser!.name[0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData icon;
    Color color = Colors.white70; // Default text color match

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        break;
      case MessageStatus.sent:
        icon = Icons.check; // One tick
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all; // Two ticks
        break;
      case MessageStatus.read:
        icon = Icons.done_all; // Two ticks (Blue)
        color = Colors.lightBlueAccent;
        break;
      case MessageStatus.failed:
        icon = Icons.error;
        color = Colors.redAccent;
        break;
    }
    return Icon(icon, size: 16, color: color);
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.day}/${timestamp.month}';
  }

  // Load messages. // REC-3
  void _loadMessages() {
    if (widget.deviceId == null) return;

    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    messageProvider.loadMessages(widget.deviceId!); // REC-3
  }

  // Send message.
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return; // REC-2

    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    final messageContent = _messageController.text.trim();

    // Capture ScaffoldMessenger before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // sendMessage in provider handles creating message logic, adding to list, and P2P sending
    final success = await messageProvider.sendMessage(
      content: messageContent,
      receiverId: 'all', // Assuming broadcast for chat room
    );

    if (success) {
      _messageController.clear();

      // Scroll default behavior for reverse list is to stay at bottom (index 0).
      // If not at bottom, we might want to scroll to 0.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ... (scroll logic)
      });
    } else {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. No connection?'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Scroll default behavior for reverse list is to stay at bottom (index 0).
    // If not at bottom, we might want to scroll to 0.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // Top of reversed list (which is visually the bottom)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showDeviceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<NetworkProvider>(
        builder: (context, networkProvider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connected Devices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (networkProvider.connectedDevices.isEmpty)
                  const Text('No devices connected')
                else
                  ...networkProvider.connectedDevices.map((device) {
                    return ListTile(
                      leading: Icon(
                        Icons.phone_android,
                        color: device.isConnected ? Colors.green : Colors.grey,
                      ),
                      title: Text(device.name),
                      subtitle: Text(device.deviceId),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: device.isConnected
                              ? Colors.green
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          device.isConnected ? 'ONLINE' : 'OFFLINE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}