import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LauncherNotification {
  final String packageName;
  final String title;
  final String text;
  final int id;

  LauncherNotification({
    required this.packageName,
    required this.title,
    required this.text,
    required this.id,
  });

  factory LauncherNotification.fromMap(Map<dynamic, dynamic> map) {
    return LauncherNotification(
      packageName: map['packageName'] as String? ?? 'Unknown',
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      id: map['id'] as int? ?? -1,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static const platform = MethodChannel('com.example.launcher/apps');
  
  final List<LauncherNotification> _notifications = [];
  bool _isEnabled = false;

  List<LauncherNotification> get notifications => _notifications;
  bool get isEnabled => _isEnabled;

  NotificationService() {
    _init();
  }

  Future<void> _init() async {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNotificationPosted':
          _onNotificationPosted(call.arguments as Map);
          break;
        case 'onNotificationRemoved':
          _onNotificationRemoved(call.arguments as Map);
          break;
      }
    });
    await checkPermission();
  }

  void _onNotificationPosted(Map data) {
    final notification = LauncherNotification.fromMap(data);
    
    // Smart Filter: Detect Promotional Keywords
    final text = notification.text.toLowerCase();
    final title = notification.title.toLowerCase();
    final isPromo = _promoKeywords.any((kw) => text.contains(kw) || title.contains(kw));

    if (isPromo) {
      debugPrint("Notification Triage: Filtered promo from ${notification.packageName}");
      return; 
    }

    // Remove old notification with same ID and package if exists
    _notifications.removeWhere((n) => n.id == notification.id && n.packageName == notification.packageName);
    _notifications.insert(0, notification);
    notifyListeners();
  }

  static const List<String> _promoKeywords = [
    'off', 'discount', 'sale', 'save', 'promo', 'cashback', 'exclusive', 'deal', 'offer', 'win', 'lottery'
  ];


  void _onNotificationRemoved(Map data) {
    final id = data['id'] as int;
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> checkPermission() async {
    try {
      _isEnabled = await platform.invokeMethod('checkNotificationPermission');
      notifyListeners();
    } catch (e) {
      debugPrint("Error checking notification permission: $e");
    }
  }

  Future<void> requestPermission() async {
    try {
      await platform.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint("Error opening notification settings: $e");
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
