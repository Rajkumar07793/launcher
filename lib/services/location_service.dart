import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'focus_mode_service.dart';

class LocationService extends ChangeNotifier {
  final FocusModeService _focusService;
  // Position? _currentPosition;
  bool _isAutoModeEnabled = true;

  // Mock Work Location (coordinates would be set by user in a real app)
  // Let's assume a generic central coordinate for simulation
  final double workLat = 12.9716;
  final double workLng = 77.5946;
  final double radius = 500; // 500 meters

  LocationService(this._focusService) {
    _startLocationMonitoring();
  }

  void _startLocationMonitoring() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 100, // Update every 100 meters
      ),
    ).listen((Position position) {
      // _currentPosition = position;
      _checkGeofence(position);
    });
  }

  void _checkGeofence(Position position) {
    if (!_isAutoModeEnabled) return;

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      workLat,
      workLng,
    );

    if (distance <= radius) {
      // Inside Work Area
      if (_focusService.currentMode != LauncherMode.work) {
        _focusService.setMode(LauncherMode.work);
        debugPrint("LocationService: Auto-switched to WORK MODE");
      }
    } else {
      // Outside Work Area
      if (_focusService.currentMode == LauncherMode.work) {
        _focusService.setMode(LauncherMode.normal);
        debugPrint("LocationService: Auto-switched to NORMAL MODE");
      }
    }
  }

  void toggleAutoMode(bool enabled) {
    _isAutoModeEnabled = enabled;
    notifyListeners();
  }
}
