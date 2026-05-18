import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the current device position.
  /// Handles permission requests automatically.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception(
          'Location permission permanently denied. Please allow it from app settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Calculates distance in kilometers between two lat/lng points.
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceInMeters / 1000.0; // convert to km
  }
  static Future<void> openLocationSettingsIfNeeded() async {
  bool enabled = await Geolocator.isLocationServiceEnabled();

  if (!enabled) {
    await Geolocator.openLocationSettings();
  }
}
}