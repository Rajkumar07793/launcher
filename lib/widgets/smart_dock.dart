import 'package:flutter/material.dart';
import 'package:launcher/logic/shortcut_helper.dart';
import 'package:provider/provider.dart';
import '../services/launcher_service.dart';
import '../logic/context_engine.dart';
import 'app_icon_widget.dart';

class SmartDock extends StatelessWidget {
  const SmartDock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final launcherService = Provider.of<LauncherService>(context);
    final suggestedApps = ContextEngine.getSuggestedApps(launcherService.apps);

    if (suggestedApps.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[300], size: 18),
              const SizedBox(width: 8),
              Text(
                "SMART SUGGESTIONS",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: suggestedApps.map((app) {
              return GestureDetector(
                onTap: () => launcherService.launchApp(app.packageName),
                child: Column(
                  children: [
                    AppIconWidget(
                      iconBytes: app.icon,
                      packageName: app.packageName,
                      size: 56,
                      onSwipeUp: () =>
                          launcherService.openAppInfo(app.packageName),
                      onLongPress: () =>
                          ShortcutHelper.showShortcutMenu(context, app),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 70,
                      child: Text(
                        app.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
