import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

import '../models/app_info.dart';

class ThemeService extends ChangeNotifier {
  Color _accentColor = Colors.blueAccent;

  Color get accentColor => _accentColor;

  Future<void> updateThemeFromApp(AppInfo app) async {
    try {
      final paletteGenerator = await PaletteGeneratorMaster.fromImageProvider(
        MemoryImage(app.icon),
        maximumColorCount: 5,
      );

      _accentColor =
          paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          Colors.blueAccent;

      // Ensure the color is not too dark/light if needed
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating theme from app: $e");
    }
  }

  void resetTheme() {
    _accentColor = Colors.blueAccent;
    notifyListeners();
  }
}
