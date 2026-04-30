import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/shortcut_helper.dart';
import '../models/app_info.dart';
import '../services/behavior_engine.dart';
import '../services/focus_mode_service.dart';
import '../services/launcher_service.dart';
import '../widgets/app_icon_widget.dart';

class AppGrid extends StatefulWidget {
  final String searchQuery;

  const AppGrid({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<AppGrid> createState() => _AppGridState();
}

class _AppGridState extends State<AppGrid> {
  bool _isFolderView = false;

  @override
  Widget build(BuildContext context) {
    final launcherService = Provider.of<LauncherService>(context);
    final focusService = Provider.of<FocusModeService>(context);

    final filteredApps = launcherService.apps.where((app) {
      final matchesSearch =
          widget.searchQuery.isEmpty ||
          app.name.toLowerCase().contains(widget.searchQuery.toLowerCase());
      final allowedByFocus = focusService.isAppAllowed(app.packageName);
      return matchesSearch && allowedByFocus;
    }).toList();

    if (launcherService.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Column(
      children: [
        if (widget.searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Folder View",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: _isFolderView,
                    onChanged: (v) => setState(() => _isFolderView = v),
                    activeColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),

        _isFolderView && widget.searchQuery.isEmpty
            ? _buildFolderView(filteredApps, launcherService)
            : _buildGridView(filteredApps, launcherService),
      ],
    );
  }

  Widget _buildGridView(List<AppInfo> apps, LauncherService launcherService) {
    if (apps.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) =>
          _buildAppItem(apps[index], launcherService),
    );
  }

  Widget _buildFolderView(List<AppInfo> apps, LauncherService launcherService) {
    final Map<int, String> categoryNames = {
      0: "Games",
      1: "Audio",
      2: "Video",
      3: "Image",
      4: "Social",
      5: "News",
      6: "Maps",
      7: "Productivity",
      -1: "Other",
    };

    final categorized = <int, List<AppInfo>>{};
    for (var app in apps) {
      categorized.putIfAbsent(app.category, () => []).add(app);
    }

    if (categorized.isEmpty) return _buildEmptyState();

    return Column(
      children: categorized.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                categoryNames[entry.key]?.toUpperCase() ?? "APPS",
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) =>
                  _buildAppItem(entry.value[index], launcherService),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAppItem(AppInfo app, LauncherService launcherService) {
    return GestureDetector(
      onTap: () {
        Provider.of<BehaviorEngine>(
          context,
          listen: false,
        ).logEngagement(app.packageName);
        launcherService.launchApp(app.packageName);
      },
      child: Column(
        children: [
          AppIconWidget(
            iconBytes: app.icon,
            packageName: app.packageName,
            size: 56,
            onLongPress: () => ShortcutHelper.showShortcutMenu(context, app),
          ),
          const SizedBox(height: 8),
          Text(
            app.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text("No apps found", style: TextStyle(color: Colors.white24)),
      ),
    );
  }
}
