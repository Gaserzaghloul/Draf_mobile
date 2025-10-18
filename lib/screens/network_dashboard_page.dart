import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'resource_sharing_page.dart';
import 'profile_page.dart';
import '../models/connected_device.dart'; // Keeping models for structure

class NetworkDashboardPage extends StatefulWidget {
  const NetworkDashboardPage({super.key});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {
  // Dummy data for UI demonstration
  bool _isAdvertising = true;
  final List<ConnectedDevice> _dummyDevices = [
    ConnectedDevice(
      id: '1',
      deviceId: 'dev1',
      name: 'John Doe',
      lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
      isHost: false,
    ),
    ConnectedDevice(
      id: '2',
      deviceId: 'dev2',
      name: 'Sarah Smith',
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      isHost: false,
    ),
    ConnectedDevice(
      id: '3',
      deviceId: 'dev3',
      name: 'Emergency Center',
      lastSeen: DateTime.now(),
      isHost: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate initial scan/setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeCrawl();
    });
  }

  void _showWelcomeCrawl() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connected to Secure Mesh Network'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleNetworkMode() {
    setState(() {
      _isAdvertising = !_isAdvertising;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAdvertising ? 'Switched to Host Mode' : 'Switched to Client Mode',
        ),
      ),
    );
  }

  void _startVoiceCommands() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Voice Command"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, size: 48, color: Color(0xFFD4AF37)),
            SizedBox(height: 16),
            Text("Listening..."),
            Text("(Simulated for UI Demo)", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _refreshDevices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing device list... (Simulated)')),
    );
  }

  void _sendSOSAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("SOS Alert"),
        content: const Text(
          "Ensure you want to broadcast an emergency signal to all connected devices?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert sent to all devices!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "SEND SOS",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
            tooltip: 'Refresh Devices',
          ),
          IconButton(
            icon: Icon(_isAdvertising ? Icons.wifi_tethering : Icons.wifi),
            onPressed: _toggleNetworkMode,
            tooltip: 'Toggle Network Mode',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Network Status Card
          _buildNetworkStatusCard(),

          Expanded(
            child: _dummyDevices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dummyDevices.length,
                    itemBuilder: (context, index) {
                      return _buildDeviceCard(_dummyDevices[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendSOSAlert,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: const Text(
          'SOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF101820),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1B3B5A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://via.placeholder.com/150',
                        ), // Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'User Profile',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'ID: #8392-ADMIN',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Color(0xFFC0C0C0),
              ),
              title: const Text(
                'My Profile',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.folder_shared_outlined,
                color: Color(0xFFC0C0C0),
              ),
              title: const Text(
                'Resource Sharing',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResourceSharingPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Color(0xFFC0C0C0),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Settings not implemented in UI demo"),
                  ),
                );
              },
            ),
            const Divider(color: Color(0xFF2C3E50)),
            ListTile(
              leading: const Icon(Icons.mic, color: Color(0xFFD4AF37)),
              title: const Text(
                'Voice Commands',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Tap to speak',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              onTap: () {
                Navigator.pop(context);
                _startVoiceCommands();
              },
            ),
            const Divider(color: Color(0xFF2C3E50)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Exit Network',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pop(context); // Back to Landing
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    final statusText = _isAdvertising
        ? 'Hosting Network'
        : 'Connected to Network';
    final statusColor = _isAdvertising ? Colors.blueAccent : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B2631),
            const Color(0xFF1B2631).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C3E50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wifi, color: statusColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_dummyDevices.length} Devices active',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // Show network details dialog (dummy)
            },
            icon: const Icon(Icons.info_outline, color: Color(0xFFC0C0C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.perm_scan_wifi, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'Scanning for devices...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(ConnectedDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2631),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C3E50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2C3E50),
              radius: 24,
              child: Text(
                device.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1B2631), width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          device.isHost ? 'Network Host • 2m away' : 'Connected • 5m away',
          style: TextStyle(
            color: device.isHost ? const Color(0xFFD4AF37) : Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              color: const Color(0xFFC0C0C0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      deviceId: device.deviceId,
                      deviceName: device.name,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
