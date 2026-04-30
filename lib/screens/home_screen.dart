import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:launcher/services/behavior_engine.dart';
import 'package:provider/provider.dart';

import '../services/finance_engine.dart';
import '../services/focus_mode_service.dart';
import '../services/launcher_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_grid.dart';
import '../widgets/circuit_background.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/smart_dock.dart';
import '../widgets/voice_action_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  Future<void> _pickWallpaper(ThemeService themeService) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      themeService.setWallpaperPath(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusService = Provider.of<FocusModeService>(context);
    final launcherService = Provider.of<LauncherService>(context);
    final financeService = Provider.of<FinanceEngine>(context);
    final themeService = Provider.of<ThemeService>(context);

    final String? bgPath = themeService.wallpaperPath;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: CircuitBackground(
        child: Stack(
          children: [
            // AI Robotics Background Image (Atmospheric Overlay)
            if (bgPath != null && File(bgPath).existsSync())
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.file(File(bgPath), fit: BoxFit.cover),
                ),
              ),

            // Neon Gradient Underlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      themeService.systemAccent.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Technical Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildModeToggle(focusService, themeService),
                          _buildHudClockTag(themeService),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.mic_none_rounded,
                                  color: themeService.systemAccent,
                                  size: 28,
                                ),
                                onPressed: _triggerVoice,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.settings_input_component_sharp,
                                  color: themeService.systemAccent,
                                  size: 20,
                                ),
                                onPressed: () => _showSettingsDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    const DashboardWidget(),
                    const SizedBox(height: 10),

                    // Technical Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildHudSearch(themeService),
                    ),

                    const SizedBox(height: 20),
                    const SmartDock(),
                    const SizedBox(height: 10),
                    AppGrid(searchQuery: _searchQuery),

                    const SizedBox(height: 120), // Banner space
                  ],
                ),
              ),
            ),

            // Voice Overlay
            if (_isVoiceVisible)
              VoiceActionOverlay(
                onDismiss: () => setState(() => _isVoiceVisible = false),
              ),

            // Bottom Information Banners
            _buildBanners(launcherService, financeService, themeService),
          ],
        ),
      ),
    );
  }

  Widget _buildHudClockTag(ThemeService themeService) {
    return Column(
      children: [
        Text(
          "CORE_SYNC: ACTIVE",
          style: TextStyle(
            color: themeService.systemAccent,
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                themeService.systemAccent.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHudSearch(ThemeService themeService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          left: BorderSide(
            color: themeService.systemAccent.withOpacity(0.4),
            width: 2,
          ),
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          letterSpacing: 1,
        ),
        decoration: InputDecoration(
          hintText: ">> EXECUTE_SEARCH_COMMAND...",
          hintStyle: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
            letterSpacing: 2,
          ),
          prefixIcon: Icon(
            Icons.terminal,
            color: themeService.systemAccent,
            size: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildModeToggle(FocusModeService focusService, ThemeService theme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _buildModeItem(
            focusService,
            LauncherMode.normal,
            Icons.dashboard_customize_outlined,
            theme,
          ),
          _buildModeItem(
            focusService,
            LauncherMode.work,
            Icons.terminal_outlined,
            theme,
          ),
          _buildModeItem(
            focusService,
            LauncherMode.focus,
            Icons.remove_red_eye_outlined,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildModeItem(
    FocusModeService service,
    LauncherMode mode,
    IconData icon,
    ThemeService theme,
  ) {
    final isSelected = service.currentMode == mode;
    return GestureDetector(
      onTap: () => service.setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.systemAccent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? theme.systemAccent : Colors.white38,
        ),
      ),
    );
  }

  Widget _buildBanners(
    LauncherService service,
    FinanceEngine finance,
    ThemeService theme,
  ) {
    bool anyMissing =
        !finance.hasSmsPermission ||
        !service.hasUsagePermission ||
        !service.isDefaultLauncher;

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          if (anyMissing)
            _buildBanner(
              "Permission Troubleshooting",
              Icons.help_outline,
              Colors.white38,
              () => _showRestrictedSettingsGuide(context),
            ),
          const SizedBox(height: 8),
          if (!finance.hasSmsPermission)
            _buildBanner(
              "SMS Access Required",
              Icons.sms_failed_outlined,
              Colors.orangeAccent,
              () => finance.requestSmsPermission(),
            ),
          if (!service.hasUsagePermission)
            _buildBanner(
              "Usage Required",
              Icons.analytics_outlined,
              theme.systemAccent,
              () => service.requestUsagePermission(),
            ),
          if (!service.isDefaultLauncher)
            _buildBanner(
              "Set Default",
              Icons.home_repair_service_outlined,
              Colors.blueAccent,
              () => service.openLauncherSettings(),
            ),
        ],
      ),
    );
  }

  void _showRestrictedSettingsGuide(BuildContext context) {
    final theme = Provider.of<ThemeService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.systemAccent, width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.security, color: theme.systemAccent),
            const SizedBox(width: 10),
            const Text(
              "Restricted Settings",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Android 13+ Security Feature",
              style: TextStyle(
                color: theme.systemAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Android blocks sensitive permissions for sideloaded apps to protect against malware. If a setting is grayed out, follow these steps:",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Open System Settings\n2. Navigate to Apps\n3. Select 'AI Launcher'\n4. Tap the three dots (⋮) or 'More' at the top right\n5. Select 'Allow restricted settings'",
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "After enabling this, you can return here and grant the required permissions.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "UNDERSTOOD",
              style: TextStyle(
                color: theme.systemAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final themeService = Provider.of<ThemeService>(context);
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: themeService.systemAccent, width: 1),
          ),
          title: Row(
            children: [
              Icon(Icons.tune, color: themeService.systemAccent),
              const SizedBox(width: 10),
              const Text(
                "SYSTEM_CONFIG",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GRID_DENSITY",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "COLUMNS",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  DropdownButton<int>(
                    value: themeService.gridCount,
                    dropdownColor: const Color(0xFF1E293B),
                    underline: Container(),
                    items: [2, 3, 4, 5, 6].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          value.toString(),
                          style: TextStyle(color: themeService.systemAccent),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) themeService.setGridCount(v);
                    },
                  ),
                ],
              ),
              const Text(
                "INTELLIGENCE_LAYER",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SMART_MODE",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Switch(
                    value: Provider.of<BehaviorEngine>(context).isSmartMode,
                    activeColor: themeService.systemAccent,
                    onChanged: (v) => Provider.of<BehaviorEngine>(
                      context,
                      listen: false,
                    ).toggleSmartMode(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "WALLPAPER_CONFIG",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _pickWallpaper(themeService),
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text(
                  "SELECT_WALLPAPER",
                  style: TextStyle(fontSize: 10),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: themeService.systemAccent,
                  side: BorderSide(
                    color: themeService.systemAccent.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "ACCENT_COLOR",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              // Full Spectrum Hue Slider
              Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.yellow,
                      Colors.green,
                      Colors.cyan,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                ),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 30,
                    overlayColor: Colors.transparent,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 5,
                    ),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: HSVColor.fromColor(themeService.systemAccent).hue,
                    min: 0,
                    max: 360,
                    onChanged: (h) {
                      themeService.setSystemAccent(
                        HSVColor.fromColor(
                          themeService.systemAccent,
                        ).withHue(h).toColor(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      [
                        Colors.cyanAccent,
                        Colors.blueAccent,
                        Colors.purpleAccent,
                        Colors.pinkAccent,
                        Colors.orangeAccent,
                        Colors.greenAccent,
                        Colors.redAccent,
                      ].map((color) {
                        final isSelected = themeService.systemAccent == color;
                        return GestureDetector(
                          onTap: () => themeService.setSystemAccent(color),
                          child: Container(
                            width: 30,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () => Provider.of<LauncherService>(
                  context,
                  listen: false,
                ).openDevelopmentSettings(),
                icon: const Icon(Icons.code, size: 16),
                label: const Text(
                  "DEVELOPER_OPTIONS",
                  style: TextStyle(fontSize: 10),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white24),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Provider.of<LauncherService>(
                  context,
                  listen: false,
                ).openLauncherSettings(),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text(
                  "ANDROID_SETTINGS",
                  style: TextStyle(fontSize: 10),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white24),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CLOSE",
                style: TextStyle(
                  color: themeService.systemAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBanner(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
