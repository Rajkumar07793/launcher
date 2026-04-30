import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/app_info.dart';
import 'db_service.dart';

enum ContextTime { morning, work, evening, night }

class BehaviorEngine extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final Map<String, dynamic> _predictions = {};
  List<String> _insights = [];
  Map<String, int> _appFrequencies = {};
  bool _isSmartMode = true;

  Map<String, dynamic> get predictions => _predictions;
  List<String> get insights => _insights;
  Map<String, int> get appFrequencies => _appFrequencies;
  bool get isSmartMode => _isSmartMode;

  BehaviorEngine() {
    _init();
  }

  Future<void> _init() async {
    debugPrint("BehaviorEngine: Initializing intelligence layer...");
    _appFrequencies = await _db.getAllFrequencies();
    await _refreshInsights();
    debugPrint("BehaviorEngine: Insights generated: ${_insights.length}");
    notifyListeners();
  }

  void toggleSmartMode() {
    _isSmartMode = !_isSmartMode;
    notifyListeners();
  }

  ContextTime get currentContext {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) return ContextTime.morning;
    if (hour >= 10 && hour < 17) return ContextTime.work;
    if (hour >= 17 && hour < 22) return ContextTime.evening;
    return ContextTime.night;
  }

  Future<void> logEngagement(String packageName) async {
    double? lat, lng;
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      );
      lat = position.latitude;
      lng = position.longitude;
    } catch (e) {
      debugPrint("Location capture failed: $e");
    }

    await _db.logAppOpen(packageName, lat: lat, lng: lng);
    _appFrequencies = await _db.getAllFrequencies();
    await _refreshInsights();
    notifyListeners();
  }

  Future<List<AppInfo>> getPredictedApps(List<AppInfo> allApps) async {
    if (!_isSmartMode) return allApps.take(4).toList();

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      );

      final db = await _db.database;
      // Query apps used within ~500m of current location at similar time (+/- 2 hours)
      final res = await db.rawQuery(
        '''
        SELECT packageName, COUNT(*) as count 
        FROM app_usage_logs 
        WHERE ABS(latitude - ?) < 0.005 
          AND ABS(longitude - ?) < 0.005
          AND ABS(hourOfDay - ?) < 3
        GROUP BY packageName
        ORDER BY count DESC
        LIMIT 4
      ''',
        [pos.latitude, pos.longitude, DateTime.now().hour],
      );

      if (res.isNotEmpty) {
        final predictedPackages = res
            .map((e) => e['packageName'] as String)
            .toSet();
        return allApps
            .where((a) => predictedPackages.contains(a.packageName))
            .toList();
      }
    } catch (e) {
      debugPrint("Smart prediction failed: $e");
    }

    // Fallback to time-based heuristic if geo-prediction fails or no data
    final context = currentContext;
    return allApps
        .where((app) {
          final pkg = app.packageName.toLowerCase();
          switch (context) {
            case ContextTime.morning:
              return pkg.contains('news') || pkg.contains('weather');
            case ContextTime.work:
              return pkg.contains('mail') || pkg.contains('slack');
            case ContextTime.evening:
              return pkg.contains('social') || pkg.contains('music');
            case ContextTime.night:
              return pkg.contains('clock') || pkg.contains('alarm');
          }
        })
        .take(4)
        .toList();
  }

  Future<void> _refreshInsights() async {
    final newInsights = <String>[];

    // Core Status Insights (Always present)
    newInsights.add("SMART_MODE: Suggestions are hyper-localized.");
    newInsights.add("NEURAL_ENGINE: Engagement tracking optimized.");

    if (_isSmartMode) {
      newInsights.add("LOCATION_SYNC: Real-time spatial tracking active.");
    }

    // Dynamic Behavioral Insights
    final totalOpens = _appFrequencies.values.fold(0, (a, b) => a + b);
    if (totalOpens > 0) {
      final topApp = _appFrequencies.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      newInsights.add(
        "ENGAGEMENT_ANALYTICS: ${topApp.key.split('.').last.toUpperCase()} is your primary node today.",
      );
    }

    _insights = newInsights;
  }
}
