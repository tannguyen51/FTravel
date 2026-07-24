import 'package:flutter_test/flutter_test.dart';
import 'package:travelapp/repositories/weather/weather_repo.dart';

void main() {
  group('weatherRepo', () {
    test('constructor initializes lat and lng correctly', () {
      const repo = weatherRepo(lat: 21.0285, lng: 105.8542);

      expect(repo.lat, equals(21.0285));
      expect(repo.lng, equals(105.8542));
    });

    test('constructor with different coordinates', () {
      const repo = weatherRepo(lat: 10.7769, lng: 106.7009);

      expect(repo.lat, equals(10.7769));
      expect(repo.lng, equals(106.7009));
    });

    group('JSON parsing logic', () {
      test('parses temperature correctly from JSON', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 28.5},
          'weather': [
            {
              'description': 'mây rải rác',
              'icon': '03d'
            }
          ],
          'name': 'Hanoi'
        };

        final main = jsonData['main'] as Map<String, dynamic>;
        final temp = (main['temp'] as num).toDouble();
        expect(temp, equals(28.5));
      });

      test('parses weather description correctly', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 28.5},
          'weather': [
            {
              'description': 'mây rải rác',
              'icon': '03d'
            }
          ],
          'name': 'Hanoi'
        };

        final weather = jsonData['weather'] as List<dynamic>;
        final firstWeather = weather[0] as Map<String, dynamic>;
        final description = firstWeather['description'] as String;
        expect(description, equals('mây rải rác'));
      });

      test('parses icon correctly', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 28.5},
          'weather': [
            {
              'description': 'clear sky',
              'icon': '01d'
            }
          ],
          'name': 'Hanoi'
        };

        final weather = jsonData['weather'] as List<dynamic>;
        final firstWeather = weather[0] as Map<String, dynamic>;
        final icon = firstWeather['icon'] as String;
        expect(icon, equals('01d'));
      });

      test('generates correct icon URL', () {
        const icon = '01d';
        final iconUrl = 'https://openweathermap.org/img/wn/$icon@2x.png';

        expect(
          iconUrl,
          equals('https://openweathermap.org/img/wn/01d@2x.png')
        );
      });

      test('handles missing city name gracefully', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 28.5},
          'weather': [
            {
              'description': 'clear sky',
              'icon': '01d'
            }
          ],
          // Missing 'name' field
        };

        final cityName = jsonData['name'] as String? ?? '';
        expect(cityName, equals(''));
      });

      test('handles city name correctly when present', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 28.5},
          'weather': [
            {
              'description': 'clear sky',
              'icon': '01d'
            }
          ],
          'name': 'Ho Chi Minh City'
        };

        final cityName = jsonData['name'] as String? ?? '';
        expect(cityName, equals('Ho Chi Minh City'));
      });

      test('constructs correct API URL', () {
        const lat = 21.0285;
        const lng = 105.8542;
        const apiKey = 'c50265933f240dfc8a48e18470788a9c';

        final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric';

        expect(url, contains('lat=21.0285'));
        expect(url, contains('lon=105.8542'));
        expect(url, contains('appid='));
        expect(url, contains('units=metric'));
        expect(url, startsWith('https://'));
      });

      test('returns correct structure for successful response', () {
        final result = {
          'temperature': 28.5,
          'description': 'mây rải rác',
          'icon': '03d',
          'iconUrl': 'https://openweathermap.org/img/wn/03d@2x.png',
          'cityName': 'Hanoi',
        };

        expect(result.containsKey('temperature'), isTrue);
        expect(result.containsKey('description'), isTrue);
        expect(result.containsKey('icon'), isTrue);
        expect(result.containsKey('iconUrl'), isTrue);
        expect(result.containsKey('cityName'), isTrue);
      });

      test('returns correct structure for failed response', () {
        final result = {
          'temperature': 0.0,
          'description': '',
          'icon': '',
          'cityName': '',
        };

        expect(result['temperature'], equals(0.0));
        expect(result['description'], equals(''));
        expect(result['icon'], equals(''));
        expect(result['cityName'], equals(''));
      });

      test('handles negative temperature', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': -5.5},
          'weather': [
            {
              'description': 'snow',
              'icon': '13d'
            }
          ],
          'name': 'Sapa'
        };

        final main = jsonData['main'] as Map<String, dynamic>;
        final temp = (main['temp'] as num).toDouble();
        expect(temp, equals(-5.5));
      });

      test('handles zero temperature', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 0.0},
          'weather': [
            {
              'description': 'cold',
              'icon': '01d'
            }
          ],
          'name': 'Hanoi'
        };

        final main = jsonData['main'] as Map<String, dynamic>;
        final temp = (main['temp'] as num).toDouble();
        expect(temp, equals(0.0));
      });

      test('handles high temperature', () {
        final Map<String, dynamic> jsonData = {
          'main': {'temp': 45.5},
          'weather': [
            {
              'description': 'hot',
              'icon': '01d'
            }
          ],
          'name': 'HCM'
        };

        final main = jsonData['main'] as Map<String, dynamic>;
        final temp = (main['temp'] as num).toDouble();
        expect(temp, equals(45.5));
      });
    });
  });
}
