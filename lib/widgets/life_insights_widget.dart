import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/behavior_engine.dart';
import '../services/theme_service.dart';

class LifeInsightsWidget extends StatelessWidget {
  const LifeInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final behavior = Provider.of<BehaviorEngine>(context);
    final theme = Provider.of<ThemeService>(context);
    final insights = behavior.insights;

    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            "[ RELEVANT_INSIGHTS ]",
            style: TextStyle(
              color: theme.systemAccent,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              return _buildInsightCard(insights[index], theme.systemAccent);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String text, Color primaryColor) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Left Accent Bar
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
