import 'dart:typed_data';
import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final Uint8List iconBytes;
  final String packageName;
  final double size;
  final VoidCallback? onSwipeUp;

  const AppIconWidget({
    Key? key,
    required this.iconBytes,
    required this.packageName,
    this.size = 50.0,
    this.onSwipeUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -300) {
          // Swipe Up
          onSwipeUp?.call();
        }
      },
      child: Hero(
        tag: 'app_icon_$packageName',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          padding: EdgeInsets.all(size * 0.12),
          child: Center(
            child: Image.memory(
              iconBytes,
              width: size * 0.75,
              height: size * 0.75,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.android,
                size: size * 0.6,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

