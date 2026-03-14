import 'package:dio/dio.dart';

/// Hava durumu verisi.
class WeatherData {
  const WeatherData({
    required this.temp,
    required this.description,
    required this.emoji,
  });

  final int temp;
  final String description;
  final String emoji;
}

String _descriptionForCode(int code, bool isDay) {
  switch (code) {
    case 0:
      return isDay ? 'acik' : 'acik gece';
    case 1:
      return 'az bulutlu';
    case 2:
      return 'parcali bulutlu';
    case 3:
      return 'kapali';
    case 45:
    case 48:
      return 'sisli';
    case 51:
    case 53:
    case 55:
      return 'ciseleme';
    case 56:
    case 57:
      return 'dondurucu ciseleme';
    case 61:
    case 63:
    case 65:
      return 'yagmurlu';
    case 66:
    case 67:
      return 'dondurucu yagmur';
    case 71:
    case 73:
    case 75:
      return 'kar yagisli';
    case 77:
      return 'kar taneli';
    case 80:
    case 81:
    case 82:
      return 'saganak';
    case 85:
    case 86:
      return 'kar saganagi';
    case 95:
      return 'firtinali';
    case 96:
    case 99:
      return 'firtina dolulu';
    default:
      return 'degisken';
  }
}

String _emojiForCode(int code, bool isDay) {
  switch (code) {
    case 0:
      return isDay ? '☀️' : '🌙';
    case 1:
    case 2:
      return isDay ? '⛅' : '☁️';
    case 3:
      return '☁️';
    case 45:
    case 48:
      return '🌫️';
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return '🌦️';
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
    case 80:
    case 81:
    case 82:
      return '🌧️';
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return '❄️';
    case 95:
    case 96:
    case 99:
      return '⛈️';
    default:
      return '🌤️';
  }
}

/// Open-Meteo (keysiz). Hata olursa null döner.
class WeatherService {
  final Dio _dio = Dio();

  Future<WeatherData?> getWeather(double lat, double lng) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current': 'temperature_2m,weather_code,is_day',
          'timezone': 'auto',
        },
      );
      if (response.data == null) return null;
      final data = response.data!;
      final current = data['current'] as Map<String, dynamic>?;
      if (current == null) return null;
      final temp = (current['temperature_2m'] as num?)?.round() ?? 0;
      final code = (current['weather_code'] as num?)?.toInt() ?? -1;
      final isDay = ((current['is_day'] as num?)?.toInt() ?? 1) == 1;
      return WeatherData(
        temp: temp,
        description: _descriptionForCode(code, isDay),
        emoji: _emojiForCode(code, isDay),
      );
    } catch (_) {
      return null;
    }
  }
}
