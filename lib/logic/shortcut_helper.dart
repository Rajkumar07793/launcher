import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../services/launcher_service.dart';

class ShortcutHelper {
  static Future<void> showShortcutMenu(BuildContext context, AppInfo app) async {
    final launcherService = Provider.of<LauncherService>(context, listen: false);
    
    // Show a loading indicator briefly or just fetch
    final shortcuts = await launcherService.getShortcuts(app.packageName);
    
    if (shortcuts.isEmpty) {
      // Just open app info if no shortcuts found on long press as a fallback
      launcherService.openAppInfo(app.packageName);
      return;
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.memory(app.icon, width: 32, height: 32),
                    const SizedBox(width: 12),
                    Text(
                      app.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              ...shortcuts.map((shortcut) => ListTile(
                leading: const Icon(Icons.bolt, color: Colors.blueAccent),
                title: Text(
                  shortcut['label'] ?? 'Action',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  launcherService.launchShortcut(app.packageName, shortcut['id']!);
                  Navigator.pop(context);
                },
              )).toList(),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white38),
                title: const Text("App Info", style: TextStyle(color: Colors.white38)),
                onTap: () {
                  launcherService.openAppInfo(app.packageName);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
