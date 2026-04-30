import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  late Timer _timer;
  late Timer _fastTimer;
  late DateTime _now;
  int _memoryUsage = 84;
  double _latency = 0.12;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _updateStats();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
    _fastTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateStats();
    });
  }

  Future<void> _updateStats() async {
    try {
      final Map<dynamic, dynamic>? stats = await platform.invokeMethod('getSystemStats');
      if (stats != null) {
        final mem = stats['memoryUsage'] as int;
        final lat = 0.08 + (DateTime.now().microsecond % 150) / 1000.0;
        if (mounted) {
          setState(() {
            _memoryUsage = mem;
            _latency = lat;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to get system stats: $e");
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
    final primaryColor = themeService.systemAccent;
    final timeStr = DateFormat('HH:mm').format(_now);
    final dateStr = DateFormat('EEEE // MMM dd').format(_now).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTechTag("SYSTEM: OPERATIONAL", primaryColor),
                _buildTechTag("AI_CORE: ENGAGED", Colors.blueAccent),
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
                  color: primaryColor.withOpacity(0.05),
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
                      color: primaryColor.withOpacity(0.2),
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
                                  color: primaryColor.withOpacity(0.9),
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
                          _buildcircularStatus(primaryColor),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildStatItem(Icons.memory, "$_memoryUsage%", "NEURAL LOAD"),
                          _buildStatDivider(),
                          _buildStatItem(Icons.speed, "${_latency.toStringAsFixed(2)}ms", "LATENCY"),
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
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withOpacity(0.5),
            ),
          ),
        ),
        Icon(
          Icons.hub_outlined,
          color: color.withOpacity(0.8),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blueAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
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
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 20, width: 1, color: Colors.white12);
  }
}
