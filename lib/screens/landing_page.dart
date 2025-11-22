import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_provider.dart';
import 'profile_page.dart';
import 'network_dashboard_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title (icon removed)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'BEACON',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Emergency Communication Network',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Main Action Buttons
                _buildActionButton(
                  icon: Icons.person_add,
                  title: 'Join Existing Network',
                  subtitle: 'Connect to nearby devices',
                  onTap: () => _joinNetwork(),
                ),

                const SizedBox(height: 20),

                _buildActionButton(
                  icon: Icons.wifi_tethering,
                  title: 'Start New Network',
                  subtitle: 'Create your own network',
                  onTap: () => _startNetwork(),
                ),

                const SizedBox(height: 20),

                _buildActionButton(
                  icon: Icons.person,
                  title: 'Profile Settings',
                  subtitle: 'Manage your profile',
                  onTap: () => _goToProfile(),
                ),

                const SizedBox(height: 40),

                // Status Indicator
                Consumer<NetworkProvider>(
                  builder: (context, networkProvider, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: networkProvider.isConnected
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: networkProvider.isConnected
                              ? Colors.green
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            networkProvider.isConnected
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color: networkProvider.isConnected
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            networkProvider.isConnected
                                ? 'Connected to Network'
                                : 'Not Connected',
                            style: TextStyle(
                              color: networkProvider.isConnected
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Join an existing P2P network. // REC-2
  void _joinNetwork() async {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    // Show scanning dialog.
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ScanningDialog(
          onTimeout: () {
            // Handle scan timeout. // REC-2
            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No networks found. Try starting one or scan again.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      );
    }

    // Attempt to join. // REC-2
    final joined = await networkProvider.joinExistingNetwork(); // REC-2

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (joined) {
        // Navigate to dashboard on success.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NetworkDashboardPage()),
        );
      } else {
        // Show error on failure.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to join network. Please check permissions and try again.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Create and host a new network. // REC-2
  void _startNetwork() async {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    ); // REC-2

    // Show creation dialog.
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Creating network...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Begin advertising. // REC-2
    debugPrint('LandingPage: Starting new network...'); // REC-2
    final started = await networkProvider.startNewNetwork(); // REC-2
    debugPrint('LandingPage: startNewNetwork() returned: $started');

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (started) {
        debugPrint('LandingPage: ✅ Network started, navigating to dashboard');
        // Navigate to dashboard.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NetworkDashboardPage()),
        );
      } else {
        debugPrint('LandingPage: ❌ Network start failed');
        // Show error on failure.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to start network. Please check:\n- WiFi permissions\n- Location services enabled\n- No other app using hotspot',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
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
    // Auto-timeout after 30 seconds.
    Timer(const Duration(seconds: 30), () {
      if (mounted) {
        widget.onTimeout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scanning for BEACON networks...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take up to 30 seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
