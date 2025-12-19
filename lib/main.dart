import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/user_provider.dart';
import 'services/network_provider.dart';
import 'services/message_provider.dart';
import 'services/resource_provider.dart';
import 'database/database_service.dart';
import 'screens/landing_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(const BeaconApp());
}

class BeaconApp extends StatelessWidget {
  const BeaconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // User Provider
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Network Provider
        ChangeNotifierProxyProvider<UserProvider, NetworkProvider>(
          create: (_) => NetworkProvider(),
          update: (_, userProvider, networkProvider) {
            networkProvider!.updateUser(userProvider.currentUser);
            return networkProvider;
          },
        ),

        // Message Provider
        ChangeNotifierProxyProvider2<
          UserProvider,
          NetworkProvider,
          MessageProvider
        >(
          create: (context) => MessageProvider(
            Provider.of<NetworkProvider>(context, listen: false),
          ),
          update: (_, userProvider, networkProvider, messageProvider) {
            // Update user in MessageProvider.
            messageProvider!.updateUser(userProvider.currentUser);
            return messageProvider;
          },
        ),

        // Resource Provider
        ChangeNotifierProxyProvider3<
          UserProvider,
          NetworkProvider,
          MessageProvider,
          ResourceProvider
        >(
          create: (context) => ResourceProvider(
            Provider.of<NetworkProvider>(context, listen: false),
            Provider.of<MessageProvider>(context, listen: false),
          ),
          update:
              (
                _,
                userProvider,
                networkProvider,
                messageProvider,
                resourceProvider,
              ) {
                resourceProvider!.updateUser(userProvider.currentUser);
                return resourceProvider;
              },
        ),
      ],
      child: MaterialApp(
        title: 'BEACON - Emergency Communication',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
        routes: {
          '/': (context) => const AppInitializer(),
          '/profile': (context) => const ProfilePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _needsProfileCompletion = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize SQLite database
      await DatabaseService.database;

      // Get providers
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final messageProvider = Provider.of<MessageProvider>(
        context,
        listen: false,
      );

      // Load existing user or create demo user.
      final existingUsers = await DatabaseService.getAllUsers();
      if (existingUsers.isNotEmpty) {
        userProvider.setCurrentUser(existingUsers.first);
        await userProvider.loadUserData();

        // Load messages.
        await messageProvider.loadMessages();

        // Check profile completion.
        if (!existingUsers.first.isProfileComplete) {
          _needsProfileCompletion = true;
        }
      } else {
        // Create demo user with isProfileComplete = false
        await userProvider.createUser(
          'Demo User',
          'demo@beacon.app',
          isProfileComplete: false,
        );
        await userProvider.loadUserData();
        _needsProfileCompletion = true;
      }

      // Mark initialization as complete
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Still mark as initialized to prevent infinite loading
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
              ),
              SizedBox(height: 24),
              Text(
                'Initializing BEACON...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Route to profile page if profile is incomplete, otherwise to landing page
    return _needsProfileCompletion
        ? const ProfilePage(isFirstTime: true)
        : const LandingPage();
  }
}
