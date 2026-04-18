import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/app_info.dart';

class LauncherService extends ChangeNotifier {
  static const platform = MethodChannel('com.example.launcher/apps');
  
  List<AppInfo> _apps = [];
  bool _isLoading = false;
  bool _isDefaultLauncher = false;

  List<AppInfo> get apps => _apps;
  bool get isLoading => _isLoading;
  bool get isDefaultLauncher => _isDefaultLauncher;

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
  }

  Future<void> refreshApps() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> result = await platform.invokeMethod('getInstalledApps');
      _apps = result.map((e) => AppInfo.fromMap(e as Map)).toList();
      _apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } on PlatformException catch (e) {
      debugPrint("Failed to get apps: '${e.message}'.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> launchApp(String packageName) async {
    try {
      await platform.invokeMethod('launchApp', {'packageName': packageName});
    } on PlatformException catch (e) {
      debugPrint("Failed to launch app: '${e.message}'.");
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
}
