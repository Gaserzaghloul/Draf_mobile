import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'profile_page.dart';
import 'network_dashboard_page.dart';
import '../services/voice_command_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await VoiceCommandService().startListening(
            context: context,
            intents: {
              'join network': (ctx) async => _joinNetwork(),
              'start network': (ctx) async => _startNetwork(),
              'open profile': (ctx) async => _goToProfile(),
            },
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.mic, color: Color(0xFF1E3A8A)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
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
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.9),
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
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: appState.isConnected 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: appState.isConnected 
                            ? Colors.green
                            : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            appState.isConnected 
                              ? Icons.wifi
                              : Icons.wifi_off,
                            color: appState.isConnected 
                              ? Colors.green
                              : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appState.isConnected 
                              ? 'Connected to Network'
                              : 'Not Connected',
                            style: TextStyle(
                              color: appState.isConnected 
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
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
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
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _joinNetwork() {
    // Navigate to network discovery
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NetworkDashboardPage(),
      ),
    );
  }

  void _startNetwork() {
    // Start advertising and go to dashboard
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NetworkDashboardPage(),
      ),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }
}
