import 'dart:async';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/launcher_service.dart';
import '../services/theme_service.dart';
import '../widgets/financial_hud_widget.dart';
import '../widgets/life_insights_widget.dart';
import '../widgets/notification_center_widget.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  static const platform = MethodChannel('com.example.launcher/apps');
  final Battery _battery = Battery();

  late Timer _timer;
  late Timer _fastTimer;
  late DateTime _now;

  int _memoryUsage = 84;
  double _latency = 0.12;
  int _batteryLevel = 100;
  double _coreTemp = 36.5;
  int _activeInstances = 0;
  bool _isOverheating = false;

  bool _isKilling = false;
  double _killProgress = 0.0;
  String _killStatus = "WAITING...";

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _updateStats();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    _fastTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateStats();
    });
  }

  Future<void> _updateStats() async {
    if (_isKilling) return;
    try {
      final launcherService = Provider.of<LauncherService>(
        context,
        listen: false,
      );

      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      final instances = await launcherService.getRunningAppsCount();

      double simulatedTemp = 32.0 + (level % 10) / 2.0;
      if (state == BatteryState.charging) simulatedTemp += 8.5;
      simulatedTemp += (_memoryUsage / 20.0);
      simulatedTemp += (instances * 0.4);
      simulatedTemp += (DateTime.now().second % 10) / 10.0;

      final Map<dynamic, dynamic>? stats = await platform.invokeMethod(
        'getSystemStats',
      );
      int mem = _memoryUsage;
      if (stats != null) mem = stats['memoryUsage'] as int;

      final lat = 0.08 + (DateTime.now().microsecond % 150) / 1000.0;

      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _coreTemp = simulatedTemp;
          _memoryUsage = mem;
          _latency = lat;
          _activeInstances = instances;
          _isOverheating = _coreTemp > 45.0;
        });
      }
    } catch (e) {
      debugPrint("Failed to get system stats: $e");
    }
  }

  Future<void> _handleKillAll() async {
    if (_isKilling) return;

    setState(() {
      _isKilling = true;
      _killProgress = 0.0;
      _killStatus = "INITIATING_STARK_PROTOCOL...";
    });

    final statuses = [
      "SCANNING_BACKGROUND_NODES...",
      "ISOLATING_NON_SYSTEM_PROCESSES...",
      "INJECTING_TERMINATION_SEQUENCE...",
      "PURGING_TEMPORARY_CACHE...",
      "RECALIBRATING_NEURAL_LOAD...",
      "SYSTEM_OPTIMIZATION_COMPLETE.",
    ];

    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() {
        _killProgress = i / 100.0;
        if (i < 20) {
          _killStatus = statuses[0];
        } else if (i < 40) {
          _killStatus = statuses[1];
        } else if (i < 60) {
          _killStatus = statuses[2];
        } else if (i < 80) {
          _killStatus = statuses[3];
        } else if (i < 95) {
          _killStatus = statuses[4];
        } else if (i < 100) {
          _killStatus = statuses[5];
        }
      });
    }

    final launcherService = Provider.of<LauncherService>(
      context,
      listen: false,
    );
    await launcherService.killAllApps();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isKilling = false;
      });
      _updateStats();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _fastTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final accentColor = _isOverheating
        ? Colors.redAccent
        : themeService.systemAccent;

    final timeStr = DateFormat('HH:mm').format(_now);
    final dateStr = DateFormat('EEEE // MMM dd').format(_now).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTechTag(
                      _isOverheating
                          ? "SYSTEM: OVERHEATING"
                          : "SYSTEM: OPERATIONAL",
                      accentColor,
                    ),
                    _buildTechTag(
                      "ACTIVE_INSTANCES: $_activeInstances",
                      Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              const FinancialHudWidget(),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: accentColor.withOpacity(0.9),
                                      fontSize: 48,
                                      fontWeight: FontWeight.w100,
                                      letterSpacing: -2,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              _buildcircularStatus(accentColor),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildVitalsHUD(accentColor),

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildStatItem(
                                Icons.memory,
                                "$_memoryUsage%",
                                "NEURAL LOAD",
                                accentColor,
                              ),
                              _buildStatDivider(),
                              _buildStatItem(
                                Icons.rocket_launch_outlined,
                                "KILL_ALL",
                                "PROCESSES",
                                _isKilling ? Colors.white24 : Colors.redAccent,
                                onTap: _handleKillAll,
                              ),
                              _buildStatDivider(),
                              _buildStatItem(
                                Icons.speed,
                                "${_latency.toStringAsFixed(2)}ms",
                                "LATENCY",
                                accentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const LifeInsightsWidget(),
              const SizedBox(height: 12),
              const NotificationCenterWidget(),
            ],
          ),

          // Killing Animation Overlay
          if (_isKilling)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.security,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "STARK_PROTOCOL: ACTIVATED",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: _killProgress,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.redAccent,
                                ),
                                minHeight: 2,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _killStatus,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 8,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    "${(_killProgress * 100).toInt()}%",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalsHUD(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildVitalGauge(
            "CORE_TEMP",
            "${_coreTemp.toStringAsFixed(1)}°C",
            _coreTemp / 100.0,
            color,
          ),
          _buildVitalGauge(
            "BATT_CELL",
            "$_batteryLevel%",
            _batteryLevel / 100.0,
            color,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalGauge(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withOpacity(0.6),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTechTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "[ $text ]",
        style: TextStyle(
          color: color.withOpacity(0.7),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildcircularStatus(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: _memoryUsage / 100.0,
            strokeWidth: 2,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.5)),
          ),
        ),
        Icon(Icons.hub_outlined, color: color.withOpacity(0.8), size: 24),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color accent, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent.withOpacity(0.6), size: 14),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: onTap != null ? accent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 20, width: 1, color: Colors.white12);
  }
}
