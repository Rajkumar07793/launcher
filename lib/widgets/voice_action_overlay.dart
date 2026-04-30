import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/focus_mode_service.dart';
import '../services/launcher_service.dart';

class VoiceActionOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const VoiceActionOverlay({super.key, required this.onDismiss});

  @override
  State<VoiceActionOverlay> createState() => _VoiceActionOverlayState();
}

class _VoiceActionOverlayState extends State<VoiceActionOverlay> {
  late stt.SpeechToText _speech;
  // bool _isListening = false;
  String _text = "Listening...";
  // double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _listen();
  }

  void _listen() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      // if (mounted) setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (mounted) {
            setState(() {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                // _confidence = val.confidence;
              }
            });
            if (val.finalResult) {
              _handleCommand(_text.toLowerCase());
            }
          }
        },
      );
    } else {
      if (mounted) setState(() => _text = "Speech recognition unavailable");
      Future.delayed(const Duration(seconds: 2), widget.onDismiss);
    }
  }

  void _handleCommand(String command) {
    final launcherService = Provider.of<LauncherService>(
      context,
      listen: false,
    );
    final focusService = Provider.of<FocusModeService>(context, listen: false);

    if (command.contains("open") || command.contains("launch")) {
      final appName = command
          .replaceAll("open", "")
          .replaceAll("launch", "")
          .trim();
      final app = launcherService.apps.firstWhere(
        (a) => a.name.toLowerCase().contains(appName),
        orElse: () => launcherService.apps.first, // Dummy or error handle
      );
      launcherService.launchApp(app.packageName);
    } else if (command.contains("work mode")) {
      focusService.setMode(LauncherMode.work);
    } else if (command.contains("normal mode") ||
        command.contains("home mode")) {
      focusService.setMode(LauncherMode.normal);
    } else if (command.contains("focus mode") || command.contains("zen mode")) {
      focusService.setMode(LauncherMode.focus);
    }

    Future.delayed(const Duration(seconds: 1), widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.blueAccent,
                  size: 64,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 100),
              TextButton(
                onPressed: widget.onDismiss,
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
