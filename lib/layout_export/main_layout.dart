import 'package:flutter/material.dart';
import 'landing_layout.dart';

class BeaconAppLayoutOnly extends StatelessWidget {
  const BeaconAppLayoutOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BEACON',
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
      ),
      debugShowCheckedModeBanner: false,
      home: const LandingPageLayoutOnly(),
    );
  }
}


