import 'package:flutter/material.dart';
import 'package:launcher/services/focus_mode_service.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/launcher_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LauncherService()),
        ChangeNotifierProvider(create: (_) => FocusModeService()),
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily:
            'Inter', // Note: User might need to add this font or it defaults to system
      ),
      home: const HomeScreen(),
    );
  }
}
