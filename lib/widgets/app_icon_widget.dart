import 'dart:typed_data';
import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final Uint8List iconBytes;
  final double size;

  const AppIconWidget({
    Key? key,
    required this.iconBytes,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: Center(
        child: Image.memory(
          iconBytes,
          width: size * 0.8,
          height: size * 0.8,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.android,
            size: size * 0.6,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
