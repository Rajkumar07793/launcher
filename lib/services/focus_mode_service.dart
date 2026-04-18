import 'package:flutter/foundation.dart';

enum LauncherMode { normal, work, focus }

class FocusModeService extends ChangeNotifier {
  LauncherMode _currentMode = LauncherMode.normal;

  LauncherMode get currentMode => _currentMode;

  void setMode(LauncherMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  // Define curated lists of "Always Allowed" apps
  static const List<String> essentialPackages = [
    'com.android.phone',
    'com.android.server.telecom',
    'com.android.dialer',
    'com.android.mms',
    'com.google.android.apps.messaging',
    'com.whatsapp',
    'com.google.android.dialer',
  ];

  bool isAppAllowed(String packageName) {
    if (_currentMode == LauncherMode.normal) return true;
    
    // Always allow essentials
    if (essentialPackages.contains(packageName)) return true;

    if (_currentMode == LauncherMode.work) {
      // Logic for Work: allow productivity, mail, slack, etc.
      final pkgLower = packageName.toLowerCase();
      return pkgLower.contains('mail') || 
             pkgLower.contains('slack') || 
             pkgLower.contains('teams') || 
             pkgLower.contains('office') || 
             pkgLower.contains('zoom') ||
             pkgLower.contains('meet');
    }

    if (_currentMode == LauncherMode.focus) {
      // Focus mode is very restrictive
      return false; // Only essentials
    }

    return true;
  }
}
