import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/launcher_service.dart';
import '../services/focus_mode_service.dart';
import '../services/theme_service.dart';
import '../widgets/smart_dock.dart';
import '../widgets/app_grid.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/voice_action_overlay.dart';
import '../widgets/circuit_background.dart';

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

    const String bgPath = "/Users/rajkumar/.gemini/antigravity/brain/f4baf74e-3f5e-4055-944a-65b85f0dbb80/ai_robotics_preview_1776538562397.png";

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: CircuitBackground(
        child: Stack(
          children: [
            // AI Robotics Background Image (Atmospheric Overlay)
            if (File(bgPath).existsSync())
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.file(
                    File(bgPath),
                    fit: BoxFit.cover,
                  ),
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
                      Colors.cyan.withOpacity(0.05),
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
                          _buildModeToggle(focusService),
                          _buildHudClockTag(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.mic_none_rounded, color: Colors.cyanAccent, size: 28),
                                onPressed: _triggerVoice,
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_input_component_sharp, color: Colors.white38, size: 20),
                                onPressed: () => launcherService.openLauncherSettings(),
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
                      child: _buildHudSearch(),
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
              VoiceActionOverlay(onDismiss: () => setState(() => _isVoiceVisible = false)),
            
            // Bottom Information Banners
            _buildBanners(launcherService),
          ],
        ),
      ),
    );
  }

  Widget _buildHudClockTag() {
    return Column(
      children: [
        const Text(
          "CORE_SYNC: ACTIVE",
          style: TextStyle(color: Colors.cyanAccent, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.cyanAccent.withOpacity(0.5), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHudSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          left: BorderSide(color: Colors.cyanAccent.withOpacity(0.4), width: 2),
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1),
        decoration: InputDecoration(
          hintText: ">> EXECUTE_SEARCH_COMMAND...",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2),
          prefixIcon: const Icon(Icons.terminal, color: Colors.cyanAccent, size: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildModeToggle(FocusModeService focusService) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _buildModeItem(focusService, LauncherMode.normal, Icons.dashboard_customize_outlined),
          _buildModeItem(focusService, LauncherMode.work, Icons.terminal_outlined),
          _buildModeItem(focusService, LauncherMode.focus, Icons.remove_red_eye_outlined),
        ],
      ),
    );
  }

  Widget _buildModeItem(FocusModeService service, LauncherMode mode, IconData icon) {
    final isSelected = service.currentMode == mode;
    return GestureDetector(
      onTap: () => service.setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.cyanAccent : Colors.white38,
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
            _buildBanner("Usage Required", Icons.analytics_outlined, Colors.cyanAccent, () => service.requestUsagePermission()),
          if (!service.isDefaultLauncher)
            _buildBanner("Set Default", Icons.home_repair_service_outlined, Colors.blueAccent, () => service.openLauncherSettings()),
        ],
      ),
    );
  }

  Widget _buildBanner(String text, IconData icon, Color color, VoidCallback onTap) {
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
            Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
          ],
        ),
      ),
    );
  }
}
