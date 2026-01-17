import 'package:geolocator/geolocator.dart';
import '../error/exceptions.dart';

/// Location helper for GPS operations
class LocationHelper {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Check and request location permission
  static Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  /// Get current location coordinates
  static Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled');
    }
    
    // Check permissions
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      throw LocationException('Location permission denied');
    }
    
    // Get position with high accuracy
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw LocationException('Unable to get current location: ${e.toString()}');
    }
  }
  
  /// Get last known location (faster but potentially outdated)
  static Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }
  
  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    ) / 1000; // Convert meters to kilometers
  }
  
  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
