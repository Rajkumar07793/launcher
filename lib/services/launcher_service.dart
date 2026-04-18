import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/app_info.dart';

class LauncherService extends ChangeNotifier {
  static const platform = MethodChannel('com.example.launcher/apps');
  
  List<AppInfo> _apps = [];
  bool _isLoading = false;
  bool _isDefaultLauncher = false;
  bool _hasUsagePermission = false;

  List<AppInfo> get apps => _apps;
  bool get isLoading => _isLoading;
  bool get isDefaultLauncher => _isDefaultLauncher;
  bool get hasUsagePermission => _hasUsagePermission;

  LauncherService() {
    _init();
  }

  Future<void> _init() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'appsChanged') {
        await refreshApps();
      }
    });
    await refreshApps();
    await checkDefaultLauncher();
    await checkUsagePermission();
    if (_hasUsagePermission) {
      await updateUsageStats();
    }
  }

  Future<void> refreshApps() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> result = await platform.invokeMethod('getInstalledApps');
      _apps = result.map((e) => AppInfo.fromMap(e as Map)).toList();
      _apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      if (_hasUsagePermission) {
        await updateUsageStats();
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get apps: '${e.message}'.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsageStats() async {
    try {
      final Map<dynamic, dynamic> stats = await platform.invokeMethod('getUsageStats');
      for (var app in _apps) {
        if (stats.containsKey(app.packageName)) {
          app.usageTime = stats[app.packageName] as int;
        }
      }
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint("Failed to get usage stats: '${e.message}'.");
    }
  }

  Future<void> launchApp(String packageName) async {
    try {
      await platform.invokeMethod('launchApp', {'packageName': packageName});
      // Refresh stats after launch as usage might have changed
      Future.delayed(const Duration(seconds: 2), () => updateUsageStats());
    } on PlatformException catch (e) {
      debugPrint("Failed to launch app: '${e.message}'.");
    }
  }

  Future<void> openAppInfo(String packageName) async {
    try {
      await platform.invokeMethod('openAppInfo', {'packageName': packageName});
    } on PlatformException catch (e) {
      debugPrint("Failed to open app info: '${e.message}'.");
    }
  }

  Future<void> checkDefaultLauncher() async {
    try {
      _isDefaultLauncher = await platform.invokeMethod('isDefaultLauncher');
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint("Failed to check default launcher: '${e.message}'.");
    }
  }

  Future<void> openLauncherSettings() async {
    try {
      await platform.invokeMethod('openLauncherSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open settings: '${e.message}'.");
    }
  }

  Future<void> checkUsagePermission() async {
    try {
      _hasUsagePermission = await platform.invokeMethod('checkUsagePermission');
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint("Failed to check usage permission: '${e.message}'.");
    }
  }

  Future<void> requestUsagePermission() async {
    try {
      await platform.invokeMethod('openUsageSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open usage settings: '${e.message}'.");
    }
  }

  void sortAppsByUsage() {
    _apps.sort((a, b) => b.usageTime.compareTo(a.usageTime));
    notifyListeners();
  }

  void sortAppsAlphabetical() {
    _apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    notifyListeners();
  }
}

