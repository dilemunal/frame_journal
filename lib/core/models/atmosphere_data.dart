import '../services/location_service.dart';
import '../services/weather_service.dart';

class AtmosphereData {
  const AtmosphereData({
    required this.location,
    this.weather,
  });

  final LocationData location;
  final WeatherData? weather;
}
