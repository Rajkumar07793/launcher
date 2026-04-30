import 'package:flutter/material.dart';

class CircuitBackground extends StatefulWidget {
  final Widget child;
  const CircuitBackground({super.key, required this.child});

  @override
  State<CircuitBackground> createState() => _CircuitBackgroundState();
}

class _CircuitBackgroundState extends State<CircuitBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CircuitPainter(_controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class CircuitPainter extends CustomPainter {
  final double progress;
  CircuitPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.05)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Fixed circuit paths for stability
    final paths = [
      _createPath(
        const Offset(0.1, 0.1),
        const Offset(0.3, 0.1),
        const Offset(0.3, 0.3),
      ),
      _createPath(
        const Offset(0.9, 0.2),
        const Offset(0.7, 0.2),
        const Offset(0.7, 0.4),
      ),
      _createPath(
        const Offset(0.2, 0.8),
        const Offset(0.4, 0.8),
        const Offset(0.4, 0.6),
      ),
      _createPath(
        const Offset(0.8, 0.9),
        const Offset(0.6, 0.9),
        const Offset(0.6, 0.7),
      ),
      _createPath(
        const Offset(0.1, 0.5),
        const Offset(0.2, 0.5),
        const Offset(0.2, 0.4),
      ),
      _createPath(
        const Offset(0.9, 0.6),
        const Offset(0.8, 0.6),
        const Offset(0.8, 0.7),
      ),
    ];

    for (var points in paths) {
      final path = Path();
      path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
      }
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);

      // Draw small "nodes" at joints
      for (var p in points) {
        canvas.drawCircle(
          Offset(p.dx * size.width, p.dy * size.height),
          2,
          Paint()..color = const Color(0xFF00F5FF).withOpacity(0.3),
        );
      }
    }

    // Animated "data pulse"
    final pulsePaint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (var points in paths) {
      // Logic to move a small dot along the path based on progress
      final totalPoints = points.length;
      final segmentProgress = (progress * totalPoints) % totalPoints;
      final currentIdx = segmentProgress.floor();
      final nextIdx = (currentIdx + 1) % totalPoints;
      final t = segmentProgress - currentIdx;

      final start = points[currentIdx];
      final end = points[nextIdx];

      final currentPos = Offset(
        (start.dx + (end.dx - start.dx) * t) * size.width,
        (start.dy + (end.dy - start.dy) * t) * size.height,
      );

      canvas.drawCircle(currentPos, 1.5, pulsePaint);
      canvas.drawCircle(
        currentPos,
        4,
        Paint()..color = const Color(0xFF00F5FF).withOpacity(0.1),
      );
    }
  }

  List<Offset> _createPath(Offset p1, Offset p2, Offset p3) {
    return [p1, p2, p3];
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
