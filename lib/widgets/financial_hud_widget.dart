import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/finance_engine.dart';

class FinancialHudWidget extends StatelessWidget {
  const FinancialHudWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceEngine>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(color: Colors.cyanAccent.withOpacity(0.1)),
          right: BorderSide(color: Colors.cyanAccent.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "FINANCIAL_EXPLOIT: DETECTED",
                style: TextStyle(color: Colors.amberAccent, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text("Σ ", style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
                  Text(
                    finance.dailySpent.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w100, letterSpacing: -1),
                  ),
                  const SizedBox(width: 4),
                  const Text("DEBITED today", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                ],
              ),
            ],
          ),
          
          _buildMiniChart(finance),
        ],
      ),
    );
  }

  Widget _buildMiniChart(FinanceEngine finance) {
    return SizedBox(
      width: 60,
      height: 30,
      child: CustomPaint(
        painter: SparklinePainter(finance.transactions.take(5).map((e) => e.amount).toList()),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  SparklinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - (data[i] / maxVal * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => true;
}
