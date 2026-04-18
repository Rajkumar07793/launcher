import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/notification_center_widget.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Technical HUD Readouts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTechTag("SYSTEM: OPERATIONAL", Colors.cyanAccent),
                _buildTechTag("AI_CORE: ENGAGED", Colors.blueAccent),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(2), // For border glow
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.05),
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
                      color: Colors.cyanAccent.withOpacity(0.2),
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
                                "22:15",
                                style: TextStyle(
                                  color: Colors.cyanAccent.withOpacity(0.9),
                                  fontSize: 48,
                                  fontWeight: FontWeight.w100,
                                  letterSpacing: -2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const Text(
                                "SATURDAY // APR 18",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          _buildcircularStatus(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildStatItem(Icons.memory, "84%", "NEURAL LOAD"),
                          _buildStatDivider(),
                          _buildStatItem(Icons.speed, "0.12ms", "LATENCY"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

  Widget _buildcircularStatus() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 2,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.cyanAccent.withOpacity(0.5),
            ),
          ),
        ),
        Icon(
          Icons.hub_outlined,
          color: Colors.cyanAccent.withOpacity(0.8),
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
