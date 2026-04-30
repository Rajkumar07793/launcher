import 'package:flutter/material.dart';

import '../models/app_info.dart';

class HolographicFolder extends StatefulWidget {
  final String name;
  final IconData icon;
  final int count;
  final List<AppInfo> apps;
  final VoidCallback onExpand;
  final Function(String) onAppLaunch;
  final bool isExpanded;

  const HolographicFolder({
    super.key,
    required this.name,
    required this.icon,
    required this.count,
    required this.apps,
    required this.onExpand,
    required this.onAppLaunch,
    this.isExpanded = false,
  });

  @override
  State<HolographicFolder> createState() => _HolographicFolderState();
}

class _HolographicFolderState extends State<HolographicFolder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _pointerCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Listener(
            onPointerDown: (_) => _pointerCount++,
            onPointerUp: (_) => _pointerCount--,
            onPointerCancel: (_) => _pointerCount = 0,
            child: GestureDetector(
              onScaleUpdate: (details) {
                if (_pointerCount < 2) return;
                setState(() {
                  _scale = details.scale.clamp(1.0, 2.0);
                });
                if (_scale > 1.5) {
                  widget.onExpand();
                }
              },
              onScaleEnd: (details) {
                setState(() {
                  _scale = 1.0;
                });
              },
              onTap: widget.onExpand,
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(
                        0.2 * _pulseController.value + 0.1,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(
                          0.05 * _pulseController.value,
                        ),
                        blurRadius: 15,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      _buildCorner(0, 0),
                      _buildCorner(1, 0),
                      _buildCorner(0, 1),
                      _buildCorner(1, 1),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: AbsorbPointer(
                          absorbing: _pointerCount > 1,
                          child: _buildLargeIconPreview(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLargeIconPreview() {
    final previewApps = widget.apps;

    return GridView.builder(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: previewApps.length,
      itemBuilder: (context, index) {
        final app = previewApps[index];
        return GestureDetector(
          onTap: () => widget.onAppLaunch(app.packageName),
          child: Opacity(
            opacity: 0.9,
            child: Image.memory(app.icon, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  Widget _buildCorner(double x, double y) {
    return Positioned(
      left: x == 0 ? 8 : null,
      right: x == 1 ? 8 : null,
      top: y == 0 ? 8 : null,
      bottom: y == 1 ? 8 : null,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          border: Border(
            left: x == 0
                ? BorderSide(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1,
                  )
                : BorderSide.none,
            right: x == 1
                ? BorderSide(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1,
                  )
                : BorderSide.none,
            top: y == 0
                ? BorderSide(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1,
                  )
                : BorderSide.none,
            bottom: y == 1
                ? BorderSide(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
