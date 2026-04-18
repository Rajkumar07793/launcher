import 'package:flutter/material.dart';
import 'db_service.dart';
import '../models/app_info.dart';

enum ContextTime { morning, work, evening, night }

class BehaviorEngine extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  Map<String, dynamic> _predictions = {};
  List<String> _insights = [];

  Map<String, dynamic> get predictions => _predictions;
  List<String> get insights => _insights;

  BehaviorEngine() {
    _refreshInsights();
  }

  ContextTime get currentContext {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) return ContextTime.morning;
    if (hour >= 10 && hour < 17) return ContextTime.work;
    if (hour >= 17 && hour < 22) return ContextTime.evening;
    return ContextTime.night;
  }

  Future<void> logEngagement(String packageName) async {
    await _db.logAppOpen(packageName);
    await _refreshInsights();
    notifyListeners();
  }

  List<AppInfo> getPredictedApps(List<AppInfo> allApps) {
    final context = currentContext;
    
    // V1: Heuristic + Frequency (Hybrid)
    return allApps.where((app) {
      final pkg = app.packageName.toLowerCase();
      final name = app.name.toLowerCase();
      
      switch (context) {
        case ContextTime.morning:
          return pkg.contains('news') || pkg.contains('weather') || pkg.contains('calendar');
        case ContextTime.work:
          return pkg.contains('mail') || pkg.contains('slack') || pkg.contains('note') || pkg.contains('office');
        case ContextTime.evening:
          return pkg.contains('tube') || pkg.contains('flix') || pkg.contains('social') || pkg.contains('music');
        case ContextTime.night:
          return pkg.contains('clock') || pkg.contains('alarm') || pkg.contains('meditate');
      }
    }).take(4).toList();
  }

  Future<void> _refreshInsights() async {
    // Mock logic for V1 - Real logic would query DB for anomalies
    final newInsights = <String>[];
    
    // Example: Distraction Insight
    newInsights.add("SOCIAL_LIMIT: You've opened Instagram 12 times this hour. Try Mode: Focus?");
    
    // Example: Relationship Insight
    newInsights.add("RELATIONSHIP_GAP: Haven't connected with 'Mom' in 4 days.");
    
    _insights = newInsights;
  }
}
