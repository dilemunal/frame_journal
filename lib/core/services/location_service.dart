import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Konum + ilçe/şehir adı.
class LocationData {
  const LocationData({
    required this.lat,
    required this.lng,
    required this.placeName,
  });

  final double lat;
  final double lng;
  final String placeName;
}

/// Tek sorumluluk: mevcut konumu bir kez al, Türkçe yer adına çevir.
/// İzin yoksa veya hata olursa null döndürür (exception fırlatmaz).
class LocationService {
  Future<LocationData?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placeName = await _reverseGeocode(position.latitude, position.longitude);
      return LocationData(
        lat: position.latitude,
        lng: position.longitude,
        placeName: placeName ?? 'Bilinmeyen konum',
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[];
      if (p.subAdministrativeArea?.isNotEmpty == true) {
        parts.add(p.subAdministrativeArea!);
      }
      if (p.administrativeArea?.isNotEmpty == true) {
        parts.add(p.administrativeArea!);
      }
      if (parts.isEmpty && p.locality?.isNotEmpty == true) {
        parts.add(p.locality!);
      }
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
