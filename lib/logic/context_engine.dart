import '../models/app_info.dart';

enum ContextTime { morning, work, evening, night }

class ContextEngine {
  static ContextTime get currentContext {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) return ContextTime.morning;
    if (hour >= 10 && hour < 17) return ContextTime.work;
    if (hour >= 17 && hour < 22) return ContextTime.evening;
    return ContextTime.night;
  }

  static List<AppInfo> getSuggestedApps(List<AppInfo> allApps) {
    final context = currentContext;
    
    // Simple heuristic: look for keywords in package names
    return allApps.where((app) {
      final pkg = app.packageName.toLowerCase();
      final name = app.name.toLowerCase();
      
      switch (context) {
        case ContextTime.morning:
          return pkg.contains('news') || pkg.contains('weather') || pkg.contains('calendar') || name.contains('calendar');
        case ContextTime.work:
          return pkg.contains('mail') || pkg.contains('slack') || pkg.contains('teams') || pkg.contains('office') || pkg.contains('note');
        case ContextTime.evening:
          return pkg.contains('youtube') || pkg.contains('netflix') || pkg.contains('music') || pkg.contains('social') || pkg.contains('insta');
        case ContextTime.night:
          return pkg.contains('clock') || pkg.contains('alarm') || pkg.contains('sleep') || pkg.contains('meditate');
      }
    }).take(4).toList();
  }
}
