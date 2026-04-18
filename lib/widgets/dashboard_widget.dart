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
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "22:15",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w200,
                                letterSpacing: -2,
                              ),
                            ),
                            Text(
                              "Saturday, April 18",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.wb_sunny_rounded, color: Colors.amber[300], size: 28),
                                const SizedBox(width: 8),
                                const Text(
                                  "24°C",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Sunny",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.white12),
                    Row(
                      children: [
                        _buildStatItem(Icons.timer_outlined, "3h 42m", "Screen Time"),
                        _buildStatDivider(),
                        _buildStatItem(Icons.calendar_today_outlined, "6:00 PM", "Next Meeting"),
                      ],
                    ),
                  ],
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
    return Container(
      height: 20,
      width: 1,
      color: Colors.white12,
    );
  }
}
