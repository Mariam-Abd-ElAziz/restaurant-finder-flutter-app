import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get current location safely
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('GPS is disabled. Please enable location services.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission permanently denied. Enable it from app settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  /// Distance in KM
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final meters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );

    return meters / 1000;
  }

  /// Open GPS settings
  static Future<void> openLocationSettingsIfNeeded() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      await Geolocator.openLocationSettings();
    }
  }

  /// Optional: open app settings (for deniedForever cases)
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}