import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class HexagonPainter extends CustomPainter {
  final Color color;
  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - (pi / 2);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppIconWidget extends StatelessWidget {
  final Uint8List iconBytes;
  final String packageName;
  final double size;
  final VoidCallback? onLongPress;

  const AppIconWidget({
    super.key,
    required this.iconBytes,
    required this.packageName,
    this.size = 50.0,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hexagon Border
          CustomPaint(
            size: Size(size * 1.2, size * 1.2),
            painter: HexagonPainter(color: Colors.cyanAccent.withOpacity(0.5)),
          ),

          // Icon with Hexagon Clip
          ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
              child: Image.memory(
                iconBytes,
                width: size * 0.7,
                height: size * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Technical scanning overlay (subtle)
          Positioned(
            top: 0,
            child: Container(
              width: size,
              height: 1,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 4,
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

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - (pi / 2);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
