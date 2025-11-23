import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_provider.dart';
import '../services/message_provider.dart';
import '../services/user_provider.dart';
import '../models/connected_device.dart';
import '../models/message.dart';
import 'chat_page.dart';
import 'resource_sharing_page.dart';

class NetworkDashboardPage extends StatefulWidget {
  const NetworkDashboardPage({super.key});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Initialize P2P. // REC-2
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
      _checkAndSetupTimeout(); // REC-2
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  // Initialize services. // REC-2
  Future<void> _initializeServices() async {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );
    await networkProvider.initializeP2P(); // REC-2
  }

  // Manage scan timeouts.
  void _checkAndSetupTimeout() {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    // Start timeout if scanning with no results. // REC-2 (Discovery)
    if (networkProvider.isDiscovering &&
        networkProvider.connectedDevices.isEmpty) {
      _timeoutTimer?.cancel();

      _timeoutTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          final currentNetwork = Provider.of<NetworkProvider>(
            context,
            listen: false,
          );
          // Stop if still discovering with no devices.
          if (currentNetwork.isDiscovering &&
              currentNetwork.connectedDevices.isEmpty) {
            // currentNetwork.stopNetwork(); // Or just stop scanning?
            // The original code just set the flag to false.
            // We'll call stopNetwork for now as that turns off scanning.
            currentNetwork.stopNetwork();

            debugPrint(
              'NetworkDashboard: Timeout - no devices found after 30 seconds',
            );
            setState(() {}); // Force UI rebuild
          }
        }
      });
    } else if (!networkProvider.isDiscovering) {
      // Cancel pending timeout.
      _timeoutTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Dashboard'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshDevices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<NetworkProvider>(
        builder: (context, networkProvider, child) {
          return Column(
            children: [
              // Network Status Card
              _buildNetworkStatusCard(networkProvider),

              // Quick Actions
              _buildQuickActions(),

              // Connected Devices List
              Expanded(child: _buildDevicesList(networkProvider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sos_btn',
        onPressed: _showSOSAlert,
        backgroundColor: Colors.red,
        tooltip: 'Send SOS',
        child: const Icon(Icons.warning, color: Colors.white),
      ),
    );
  }

  Widget _buildNetworkStatusCard(NetworkProvider networkProvider) {
    // Check network status.
    final isActive =
        networkProvider.isConnected || networkProvider.isAdvertising;
    final statusText = networkProvider.isAdvertising
        ? 'Network Created (Host)'
        : (networkProvider.isConnected ? 'Network Active' : 'Network Inactive');
    final deviceCountText = networkProvider.isAdvertising
        ? (networkProvider.connectedDevices.isEmpty
              ? 'Waiting for devices to join...'
              : '${networkProvider.connectedDevices.length} device(s) connected')
        : (networkProvider.isConnected
              ? '${networkProvider.connectedDevices.length} devices connected'
              : 'No devices found');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.red[400]!, Colors.red[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deviceCountText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                networkProvider.isAdvertising ? 'HOST' : 'ONLINE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Send messages',
              onTap: () => _navigateToChat(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.share,
              title: 'Share',
              subtitle: 'Share resources',
              onTap: () => _navigateToResourceSharing(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.warning,
              title: 'SOS',
              subtitle: 'Emergency alert',
              onTap: _showSOSAlert,
              isEmergency: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmergency ? Colors.red[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmergency ? Colors.red[200]! : Colors.blue[200]!,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isEmergency ? Colors.red : Colors.blue, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEmergency ? Colors.red : Colors.blue,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList(NetworkProvider networkProvider) {
    // Show host status if advertising.
    if (networkProvider.isAdvertising && !networkProvider.isDiscovering) {
      // Host mode: waiting for clients.
      if (networkProvider.connectedDevices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_tethering, size: 80, color: Colors.green[400]),
              const SizedBox(height: 16),
              Text(
                'Network Created',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your BEACON network is active.\nWaiting for other devices to join...',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshDevices,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    }

    // Monitor timeout in client mode.
    if (networkProvider.isDiscovering && !networkProvider.isAdvertising) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndSetupTimeout();
      });
    }

    // Show scanning indicator.
    if (networkProvider.connectedDevices.isEmpty &&
        networkProvider.isDiscovering &&
        !networkProvider.isAdvertising) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 24),
            Text(
              'Scanning for BEACON networks...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take up to 30 seconds',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Show timeout message.
    if (networkProvider.connectedDevices.isEmpty &&
        !networkProvider.isDiscovering &&
        !networkProvider.isAdvertising) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'No BEACON networks nearby',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No networks found after 30 seconds.\nMake sure other devices are nearby\nand have BEACON running',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: networkProvider.connectedDevices.length,
      itemBuilder: (context, index) {
        final device = networkProvider.connectedDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  // Build device card.
  Widget _buildDeviceCard(ConnectedDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: device.isConnected ? Colors.green : Colors.orange[300]!,
          width: device.isConnected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device.isConnected
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: device.isConnected ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.deviceId,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: device.isConnected ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      device.isConnected ? Icons.check_circle : Icons.warning,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      device.isConnected ? 'CONNECTED' : 'DISCOVERED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt,
                size: 16,
                color: _getSignalColor(device.signalStrength),
              ),
              const SizedBox(width: 4),
              Text(
                '${device.signalStrength}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Text(
                'Last seen: ${_formatLastSeen(device.lastSeen)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!device.isConnected) {
                  _connectToDevice(device);
                } else {
                  _disconnectFromDevice(device);
                }
              },
              icon: Icon(
                device.isConnected ? Icons.link_off : Icons.link,
                size: 18,
              ),
              label: Text(
                device.isConnected ? 'Disconnect' : 'Tap to Connect',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: device.isConnected ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (!device.isConnected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connect to send messages and share resources',
                      style: TextStyle(fontSize: 11, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSignalColor(int strength) {
    if (strength >= 75) return Colors.green;
    if (strength >= 50) return Colors.orange;
    if (strength >= 25) return Colors.red;
    return Colors.grey;
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  // Refresh device list. // REC-2
  void _refreshDevices() {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    // Refresh devices preserving connection state. // REC-2
    networkProvider
        .refreshDevices() // REC-2
        .then((_) {
          if (mounted) {
            // Show appropriate message based on mode
            final message = networkProvider.isAdvertising
                ? 'Network state refreshed'
                : 'Scanning for devices... (up to 30 seconds)';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 2),
              ),
            );

            // Only set timeout for client mode scanning
            if (!networkProvider.isAdvertising) {
              Timer(const Duration(seconds: 30), () {
                if (mounted &&
                    networkProvider.connectedDevices.isEmpty &&
                    !networkProvider.isDiscovering) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No BEACON networks nearby'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              });
            }
          }
        })
        .catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error refreshing devices: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  void _navigateToResourceSharing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResourceSharingPage()),
    );
  }

  void _showSOSAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Alert'),
          ],
        ),
        content: const Text(
          'Are you sure you want to send an emergency SOS alert to all connected devices?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendSOSAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  // Broadcast SOS alert. // REC-2
  void _sendSOSAlert() {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

    // Broadcast SOS. // REC-2
    final sosMessage =
        '🚨 EMERGENCY SOS ALERT 🚨\nUser ${userProvider.currentUser?.name ?? "Unknown"} needs immediate assistance!';

    // Send to all devices. // REC-2
    for (var device in networkProvider.connectedDevices) {
      if (device.isConnected) {
        // AppState had sendP2PMessage, NetworkProvider has p2pService.sendMessage
        // But messageProvider is the higher level abstraction.
        // However, messageProvider.sendMessage takes a receiverId and creates a message logic.
        // It handles optimistically adding to list.
        messageProvider.sendMessage(
          // REC-2
          content: sosMessage,
          receiverId: device.deviceId,
          type: MessageType.sos,
        );
      }
    }

    // Also send to "all" logically if we had broadcast support, but here we loop.

    // Local echo is handled by messageProvider.sendMessage internally if successful.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS Alert sent to all devices via P2P!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Connect to device. // REC-2
  void _connectToDevice(ConnectedDevice device) {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    networkProvider.connectToDevice(device).then((connected) {
      // REC-2
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              connected
                  ? 'Connected to ${device.name} via P2P'
                  : 'Failed to connect to ${device.name}',
            ),
            backgroundColor: connected ? Colors.green : Colors.red,
          ),
        );
      }
    });
  }

  // Disconnect from device.
  void _disconnectFromDevice(ConnectedDevice device) {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    networkProvider.disconnectFromDevice(device).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disconnected from ${device.name}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
}
