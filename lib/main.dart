import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/launcher_service.dart';
import 'services/focus_mode_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LauncherService()),
        ChangeNotifierProvider(create: (_) => FocusModeService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'AI Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: themeService.accentColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeService.accentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
    );
  }
}
