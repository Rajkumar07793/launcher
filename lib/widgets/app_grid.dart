import 'package:flutter/material.dart';
import 'package:launcher/services/theme_service.dart';
import 'package:provider/provider.dart';

import '../logic/shortcut_helper.dart';
import '../models/app_info.dart';
import '../services/behavior_engine.dart';
import '../services/focus_mode_service.dart';
import '../services/launcher_service.dart';
import '../widgets/app_icon_widget.dart';
import '../widgets/holographic_folder.dart';

class AppGrid extends StatefulWidget {
  final String searchQuery;

  const AppGrid({super.key, required this.searchQuery});

  @override
  State<AppGrid> createState() => _AppGridState();
}

class _AppGridState extends State<AppGrid> {
  bool _isFolderView = false;
  bool _sortByUsage = false;
  int? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    final launcherService = Provider.of<LauncherService>(context);
    final focusService = Provider.of<FocusModeService>(context);
    final behavior = Provider.of<BehaviorEngine>(context);

    final filteredApps = launcherService.apps.where((app) {
      final matchesSearch =
          widget.searchQuery.isEmpty ||
          app.name.toLowerCase().contains(widget.searchQuery.toLowerCase());
      final allowedByFocus = focusService.isAppAllowed(app.packageName);
      return matchesSearch && allowedByFocus;
    }).toList();

    if (_sortByUsage) {
      filteredApps.sort((a, b) {
        final freqA = behavior.appFrequencies[a.packageName] ?? 0;
        final freqB = behavior.appFrequencies[b.packageName] ?? 0;
        return freqB.compareTo(freqA); // High frequency first
      });
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Sort Toggle
                GestureDetector(
                  onTap: () => setState(() => _sortByUsage = !_sortByUsage),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sortByUsage
                          ? Provider.of<ThemeService>(context).systemAccent.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _sortByUsage
                            ? Provider.of<ThemeService>(context).systemAccent.withOpacity(0.5)
                            : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 12,
                          color: _sortByUsage
                              ? Provider.of<ThemeService>(context).systemAccent
                              : Colors.white38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "USAGE_RANK",
                          style: TextStyle(
                            color: _sortByUsage
                                ? Provider.of<ThemeService>(context).systemAccent
                                : Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Folders",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: _isFolderView,
                    onChanged: (v) => setState(() {
                      _isFolderView = v;
                      _expandedCategory = null;
                    }),
                    activeColor: Provider.of<ThemeService>(context).systemAccent,
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
    final themeService = Provider.of<ThemeService>(context);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: themeService.gridCount,
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
    final Map<int, Map<String, dynamic>> categoryMetadata = {
      0: {"name": "Games", "icon": Icons.sports_esports_outlined},
      1: {"name": "Audio", "icon": Icons.audiotrack_outlined},
      2: {"name": "Video", "icon": Icons.movie_filter_outlined},
      3: {"name": "Image", "icon": Icons.image_search_outlined},
      4: {"name": "Social", "icon": Icons.alternate_email_outlined},
      5: {"name": "News", "icon": Icons.feed_outlined},
      6: {"name": "Maps", "icon": Icons.explore_outlined},
      7: {"name": "Productivity", "icon": Icons.inventory_2_outlined},
      8: {"name": "Accessibility", "icon": Icons.accessibility_new_outlined},
      -1: {"name": "Other", "icon": Icons.widgets_outlined},
    };

    final categorized = <int, List<AppInfo>>{};
    for (var app in apps) {
      categorized.putIfAbsent(app.category, () => []).add(app);
    }

    if (categorized.isEmpty) return _buildEmptyState();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCirc,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      child: _expandedCategory == null
          ? _buildCategoryGrid(categorized, categoryMetadata, launcherService)
          : _buildExpandedFolder(
              _expandedCategory!,
              categorized[_expandedCategory!] ?? [],
              categoryMetadata[_expandedCategory!] ?? categoryMetadata[-1]!,
              launcherService,
            ),
    );
  }

  Widget _buildCategoryGrid(
    Map<int, List<AppInfo>> categorized,
    Map<int, Map<String, dynamic>> meta,
    LauncherService launcherService,
  ) {
    return GridView.builder(
      key: const ValueKey("category_grid"),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: categorized.length,
      itemBuilder: (context, index) {
        final entry = categorized.entries.elementAt(index);
        final categoryMeta = meta[entry.key] ?? meta[-1]!;

        return HolographicFolder(
          name: categoryMeta["name"],
          icon: categoryMeta["icon"],
          count: entry.value.length,
          apps: entry.value,
          onExpand: () => setState(() => _expandedCategory = entry.key),
          onAppLaunch: (packageName) {
            Provider.of<BehaviorEngine>(
              context,
              listen: false,
            ).logEngagement(packageName);
            launcherService.launchApp(packageName);
          },
        );
      },
    );
  }

  double _pinchScale = 1.0;

  Widget _buildExpandedFolder(
    int categoryId,
    List<AppInfo> apps,
    Map<String, dynamic> meta,
    LauncherService launcherService,
  ) {
    final theme = Provider.of<ThemeService>(context);
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _pinchScale = details.scale.clamp(0.4, 1.0);
        });
        if (_pinchScale < 0.6) {
          setState(() {
            _expandedCategory = null;
            _pinchScale = 1.0;
          });
        }
      },
      onScaleEnd: (details) {
        setState(() => _pinchScale = 1.0);
      },
      child: AnimatedScale(
        scale: _pinchScale,
        duration: const Duration(milliseconds: 50),
        child: Column(
          key: ValueKey("expanded_folder_$categoryId"),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: theme.systemAccent,
                      size: 14,
                    ),
                    onPressed: () => setState(() => _expandedCategory = null),
                  ),
                  Text(
                    meta["name"].toString().toUpperCase(),
                    style: TextStyle(
                      color: theme.systemAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    ">> DIRECTORY_ACCESS: GRANTED",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.72,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) =>
                  _buildAppItem(apps[index], launcherService),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
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
