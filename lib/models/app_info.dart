import 'dart:typed_data';

class AppInfo {
  final String name;
  final String packageName;
  final Uint8List icon;
  final int category;
  int usageTime; // in milliseconds

  AppInfo({
    required this.name,
    required this.packageName,
    required this.icon,
    this.category = -1,
    this.usageTime = 0,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      name: map['name'] as String,
      packageName: map['packageName'] as String,
      icon: map['icon'] as Uint8List,
      category: map['category'] as int? ?? -1,
    );
  }
}

