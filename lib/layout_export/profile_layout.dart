import 'package:flutter/material.dart';

class ProfilePageLayoutOnly extends StatelessWidget {
  const ProfilePageLayoutOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: const [
                  CircleAvatar(radius: 60, backgroundColor: Color(0xFF1E3A8A), child: Text('U', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white))),
                  SizedBox(height: 16),
                  Text('User Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('user@email.com', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildFormField(label: 'Name', icon: Icons.person),
            const SizedBox(height: 20),
            _buildFormField(label: 'Email', icon: Icons.email),
            const SizedBox(height: 40),
            _buildStatsCard(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: const Text('Save Changes')),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Profile Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
          _StatItem(icon: Icons.message, label: 'Messages', value: '0'),
          _StatItem(icon: Icons.devices, label: 'Devices', value: '0'),
          _StatItem(icon: Icons.share, label: 'Resources', value: '0'),
        ]),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _StatItem({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ]);
  }
}


