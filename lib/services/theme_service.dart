import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

import '../models/app_info.dart';

class ThemeService extends ChangeNotifier {
  Color _accentColor = Colors.blueAccent;
  Color _systemAccent = Colors.cyanAccent;
  int _gridCount = 4;
  String? _wallpaperPath;

  Color get accentColor => _accentColor;
  Color get systemAccent => _systemAccent;
  int get gridCount => _gridCount;
  String? get wallpaperPath => _wallpaperPath;

  void setSystemAccent(Color color) {
    _systemAccent = color;
    notifyListeners();
  }

  void setGridCount(int count) {
    _gridCount = count;
    notifyListeners();
  }

  void setWallpaperPath(String? path) {
    _wallpaperPath = path;
    notifyListeners();
  }

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

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating theme from app: $e");
    }
  }

  void resetTheme() {
    _accentColor = Colors.blueAccent;
    _systemAccent = Colors.cyanAccent;
    _gridCount = 4;
    notifyListeners();
  }
}
