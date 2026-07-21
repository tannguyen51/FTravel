import 'dart:convert';
import 'package:http/http.dart' as http;

class weatherRepo {
  final double lat;
  final double lng;

  const weatherRepo({required this.lat, required this.lng});

  Future<Map<String, dynamic>> findWeather() async {
    const apiKey = 'c50265933f240dfc8a48e18470788a9c';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final temp = (data['main']['temp'] as num).toDouble();
      final description = data['weather'][0]['description'] as String;
      final icon = data['weather'][0]['icon'] as String;

      return {
        'temperature': temp,
        'description': description,
        'icon': icon,
        'iconUrl': 'https://openweathermap.org/img/wn/$icon@2x.png',
      };
    } else {
      return {'temperature': 0.0, 'description': '', 'icon': ''};
    }
  }
}
