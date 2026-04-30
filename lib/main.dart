import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/behavior_engine.dart';
import 'services/finance_engine.dart';
import 'services/focus_mode_service.dart';
import 'services/launcher_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LauncherService()),
        ChangeNotifierProvider(create: (_) => FocusModeService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => BehaviorEngine()),
        ChangeNotifierProvider(create: (_) => FinanceEngine()),
        ChangeNotifierProxyProvider<FocusModeService, LocationService>(
          create: (context) => LocationService(
            Provider.of<FocusModeService>(context, listen: false),
          ),
          update: (context, focus, previous) =>
              previous ?? LocationService(focus),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
          surface: const Color(0xFF020617),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
    );
  }
}
