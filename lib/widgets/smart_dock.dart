import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/launcher_service.dart';
import '../services/behavior_engine.dart';
import '../logic/shortcut_helper.dart';
import 'app_icon_widget.dart';

class SmartDock extends StatelessWidget {
  const SmartDock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final launcherService = Provider.of<LauncherService>(context);
    final behavior = Provider.of<BehaviorEngine>(context);
    
    // Use the Predictive Engine instead of the old static ContextEngine
    final suggestedApps = behavior.getPredictedApps(launcherService.apps);

    if (suggestedApps.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              const Text(
                "PREDICTIVE_SUGGESTIONS",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                "[ ${behavior.currentContext.name.toUpperCase()} ]",
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: suggestedApps.map((app) {
              return GestureDetector(
                onTap: () {
                  behavior.logEngagement(app.packageName);
                  launcherService.launchApp(app.packageName);
                },
                child: Column(
                  children: [
                    AppIconWidget(
                      iconBytes: app.icon,
                      packageName: app.packageName,
                      size: 50,
                      onSwipeUp: () => launcherService.openAppInfo(app.packageName),
                      onLongPress: () => ShortcutHelper.showShortcutMenu(context, app),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        app.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
