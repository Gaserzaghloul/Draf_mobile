import 'package:flutter/material.dart';
import 'network_dashboard_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Join an existing P2P network.
  void _joinNetwork() async {
    // Show scanning dialog.
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ScanningDialog(
          onTimeout: () {
            // Handle scan timeout.
            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No networks found (UI Demo Only)'),
                  backgroundColor: Colors.orange,
                ),
              );
              // For demo purposes, we can navigate anyway or just stop.
              // Let's navigate to show the dashboard UI.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NetworkDashboardPage(),
                ),
              );
            }
          },
        ),
      );
    }
  }

  // Create and host a new network.
  void _startNetwork() async {
    // Show creation dialog.
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(height: 16),
                  Text("Creating secure network..."),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Simulate network creation delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Pop dialog
      // Navigate to dashboard.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NetworkDashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B3B5A), Color(0xFF101820)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon Section
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3B5A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.signal_wifi_4_bar,
                  size: 60,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BEACON',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const Text(
                'Emergency Communication Network', // Slogan
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFC0C0C0),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildActionButton(
                      title: 'Join Network',
                      subtitle: 'Find and connect to nearby devices',
                      icon: Icons.search,
                      onPressed: _joinNetwork,
                      isPrimary: false,
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      title: 'Start Network',
                      subtitle: 'Create a hotspot for others to join',
                      icon: Icons.wifi_tethering,
                      onPressed: _startNetwork,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color(0xFFD4AF37).withOpacity(0.2)
                : Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isPrimary
            ? const Color(0xFFD4AF37)
            : const Color(0xFF1B2631), // Gold or Navy
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.black.withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isPrimary
                        ? const Color(0xFF101820)
                        : const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPrimary
                              ? const Color(0xFF101820)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPrimary
                              ? const Color(0xFF101820).withOpacity(0.7)
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isPrimary ? const Color(0xFF101820) : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog for scanning progress with timeout.
class _ScanningDialog extends StatefulWidget {
  final VoidCallback onTimeout;

  const _ScanningDialog({required this.onTimeout});

  @override
  State<_ScanningDialog> createState() => _ScanningDialogState();
}

class _ScanningDialogState extends State<_ScanningDialog> {
  @override
  void initState() {
    super.initState();
    // Auto-timeout after 3 seconds for UI demo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onTimeout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFD4AF37)),
              SizedBox(height: 16),
              Text("Scanning for nearby devices..."),
              SizedBox(height: 8),
              Text(
                "Please wait",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
