import 'package:dio/dio.dart';

const String _kWeatherApiKey = String.fromEnvironment(
  'WEATHER_API_KEY',
  defaultValue: '',
);

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

/// OpenWeatherMap icon code → emoji.
String _iconCodeToEmoji(String code) {
  if (code.startsWith('01')) return code == '01d' ? '☀️' : '🌙';
  if (code.startsWith('02')) return '⛅';
  if (code.startsWith('03') || code.startsWith('04')) return '☁️';
  if (code.startsWith('09') || code.startsWith('10')) return '🌧️';
  if (code.startsWith('11')) return '⛈️';
  if (code.startsWith('13')) return '❄️';
  if (code.startsWith('50')) return '🌫️';
  return '🌤️';
}

/// OpenWeatherMap free tier. Hata olursa null döner.
class WeatherService {
  final Dio _dio = Dio();

  Future<WeatherData?> getWeather(double lat, double lng) async {
    if (_kWeatherApiKey.isEmpty) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'appid': _kWeatherApiKey,
          'units': 'metric',
          'lang': 'tr',
        },
      );
      if (response.data == null) return null;
      final data = response.data!;
      final main = data['main'] as Map<String, dynamic>?;
      final weatherList = data['weather'] as List<dynamic>?;
      if (main == null || weatherList == null || weatherList.isEmpty) return null;
      final temp = (main['temp'] as num?)?.round() ?? 0;
      final weather = weatherList.first as Map<String, dynamic>;
      final description = (weather['description'] as String?) ?? '';
      final iconCode = (weather['icon'] as String?) ?? '';
      return WeatherData(
        temp: temp,
        description: description,
        emoji: _iconCodeToEmoji(iconCode),
      );
    } catch (_) {
      return null;
    }
  }
}
