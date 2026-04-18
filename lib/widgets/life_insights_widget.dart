import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/behavior_engine.dart';

class LifeInsightsWidget extends StatelessWidget {
  const LifeInsightsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final behavior = Provider.of<BehaviorEngine>(context);
    final insights = behavior.insights;

    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            "[ RELEVANT_INSIGHTS ]",
            style: TextStyle(color: Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              return _buildInsightCard(insights[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String text) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.6),
        border: Border(
           left: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 3),
           top: BorderSide(color: Colors.white.withOpacity(0.1)),
           bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
           right: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_outlined, color: Colors.cyanAccent, size: 16),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w400, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
