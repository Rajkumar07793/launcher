import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:launcher/services/focus_mode_service.dart';
import 'package:launcher/services/launcher_service.dart';
import 'package:launcher/widgets/app_grid.dart';
import 'package:launcher/widgets/dashboard_widget.dart';
import 'package:launcher/widgets/smart_dock.dart';
import 'package:provider/provider.dart';

import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../widgets/voice_action_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isVoiceVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerVoice() {
    setState(() => _isVoiceVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final focusService = Provider.of<FocusModeService>(context);
    final launcherService = Provider.of<LauncherService>(context);
    final themeService = Provider.of<ThemeService>(context);

    // Dynamic Theme Update
    if (launcherService.apps.isNotEmpty && _searchQuery.isEmpty) {
      // Small timeout to avoid build-loop
      Future.microtask(() {
        final suggestedApp =
            launcherService.apps.first; // Or use logic from ContextEngine
        themeService.updateThemeFromApp(suggestedApp);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient (Dynamic)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeService.accentColor.withOpacity(0.15),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header with Mode Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildModeToggle(focusService),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.mic_none_rounded,
                                color: Colors.white70,
                              ),
                              onPressed: _triggerVoice,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white70,
                              ),
                              onPressed: () =>
                                  launcherService.openLauncherSettings(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dashboard Widget (V3 includes Notification Center inside)
                  const DashboardWidget(),

                  const SizedBox(height: 10),

                  // Glassmorphic Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: "Search apps...",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white54,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Smart Suggestions Section
                  if (_searchQuery.isEmpty) const SmartDock(),

                  const SizedBox(height: 10),

                  // Sorting Toggle
                  if (_searchQuery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildSortChip(
                            "A-Z",
                            !launcherService.hasUsagePermission || true,
                            () => launcherService.sortAppsAlphabetical(),
                          ),
                          const SizedBox(width: 8),
                          if (launcherService.hasUsagePermission)
                            _buildSortChip(
                              "Most Used",
                              false,
                              () => launcherService.sortAppsByUsage(),
                            ),
                        ],
                      ),
                    ),

                  // All Apps Grid
                  AppGrid(searchQuery: _searchQuery),

                  const SizedBox(height: 100), // Space for banners
                ],
              ),
            ),
          ),

          // Floating Banners
          _buildBanners(launcherService),

          // Voice Action Overlay
          if (_isVoiceVisible)
            VoiceActionOverlay(
              onDismiss: () => setState(() => _isVoiceVisible = false),
            ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(FocusModeService focusService) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModeItem(
            focusService,
            LauncherMode.normal,
            Icons.home_outlined,
          ),
          _buildModeItem(focusService, LauncherMode.work, Icons.work_outline),
          _buildModeItem(
            focusService,
            LauncherMode.focus,
            Icons.center_focus_strong_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildModeItem(
    FocusModeService service,
    LauncherMode mode,
    IconData icon,
  ) {
    final isSelected = service.currentMode == mode;
    return GestureDetector(
      onTap: () => service.setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.blueAccent : Colors.white38,
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isSelected ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBanners(LauncherService service) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          if (!service.hasUsagePermission)
            _buildBanner(
              "usage_access",
              "Enable usage access to see app stats",
              Icons.bar_chart,
              Colors.amberAccent,
              () => service.requestUsagePermission(),
            ),
          const SizedBox(height: 8),
          if (!service.isDefaultLauncher)
            _buildBanner(
              "default_home",
              "Set as default home to unlock full experience",
              Icons.home,
              Colors.blueAccent,
              () => service.openLauncherSettings(),
            ),
        ],
      ),
    );
  }

  Widget _buildBanner(
    String id,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: color.withOpacity(0.15),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
