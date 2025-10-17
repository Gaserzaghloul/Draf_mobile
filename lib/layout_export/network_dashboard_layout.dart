import 'package:flutter/material.dart';

class NetworkDashboardLayoutOnly extends StatelessWidget {
  const NetworkDashboardLayoutOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Dashboard')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildNetworkStatusCard(),
          _buildQuickActions(),
          Expanded(child: _buildDevicesListPlaceholder()),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Network Active',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('3 devices connected', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Text('ONLINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Expanded(child: _ActionCard(icon: Icons.chat, title: 'Chat', subtitle: 'Send messages')),
          SizedBox(width: 12),
          Expanded(child: _ActionCard(icon: Icons.share, title: 'Share', subtitle: 'Share resources')),
          SizedBox(width: 12),
          Expanded(child: _ActionCard(icon: Icons.warning, title: 'SOS', subtitle: 'Emergency alert', isEmergency: true)),
        ],
      ),
    );
  }

  Widget _buildDevicesListPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => const _DeviceCardPlaceholder(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEmergency;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, this.isEmergency = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmergency ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEmergency ? Colors.red[200]! : Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: isEmergency ? Colors.red : Colors.blue, size: 32),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isEmergency ? Colors.red : Colors.blue)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _DeviceCardPlaceholder extends StatelessWidget {
  const _DeviceCardPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.phone_android, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device Name', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('device-id-123', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
            child: const Text('ONLINE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


