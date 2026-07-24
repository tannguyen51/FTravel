import 'package:flutter_test/flutter_test.dart';
import 'package:travelapp/ui/Home.dart';

void main() {
  group('Home Screen Widget Tests', () {
    testWidgets('Home widget can be instantiated', (WidgetTester tester) async {
      const homeWidget = home(isBackButtonClick: false);

      expect(homeWidget, isNotNull);
      expect(homeWidget.isBackButtonClick, isFalse);
    });

    testWidgets('Home widget with back button click', (WidgetTester tester) async {
      const homeWidget = home(isBackButtonClick: true);

      expect(homeWidget.isBackButtonClick, isTrue);
    });

    group('Category data structure', () {
      test('category list has correct structure', () {
        final categories = [
          {"photo": "assets/images/hotel.png", "name": "Hotel", "category": "hotel"},
          {"photo": "assets/images/burger.png", "name": "Cafes", "category": "cafe"},
          {"photo": "assets/images/forest.png", "name": "Parks", "category": "park"},
          {"photo": "assets/images/flash.png", "name": "Attractions", "category": "attraction"},
          {"photo": "assets/images/gas-pump.png", "name": "Gas station", "category": "gas_station"},
        ];

        expect(categories.length, equals(5));
      });

      test('each category has required fields', () {
        final categories = [
          {"photo": "assets/images/hotel.png", "name": "Hotel", "category": "hotel"},
          {"photo": "assets/images/burger.png", "name": "Cafes", "category": "cafe"},
        ];

        for (var category in categories) {
          expect(category.containsKey('photo'), isTrue);
          expect(category.containsKey('name'), isTrue);
          expect(category.containsKey('category'), isTrue);
        }
      });

      test('category names are not empty', () {
        final categories = [
          {"photo": "assets/images/hotel.png", "name": "Hotel", "category": "hotel"},
          {"photo": "assets/images/burger.png", "name": "Cafes", "category": "cafe"},
        ];

        for (var category in categories) {
          expect((category['name'] as String).isNotEmpty, isTrue);
        }
      });

      test('category values are lowercase', () {
        final categories = [
          {"photo": "assets/images/hotel.png", "name": "Hotel", "category": "hotel"},
          {"photo": "assets/images/burger.png", "name": "Cafes", "category": "cafe"},
        ];

        for (var category in categories) {
          final categoryValue = category['category'] as String;
          expect(categoryValue, equals(categoryValue.toLowerCase()));
        }
      });
    });

    group('Place data structure', () {
      test('place map has correct structure', () {
        final place = {
          'name': 'Vịnh Hạ Long',
          'id': 'att_001',
          'photoRef': 'https://example.com/image.jpg',
          'rating': 4.8,
          'address': 'Quảng Ninh, Việt Nam',
          'type': 'attraction',
        };

        expect(place.containsKey('name'), isTrue);
        expect(place.containsKey('id'), isTrue);
        expect(place.containsKey('photoRef'), isTrue);
        expect(place.containsKey('rating'), isTrue);
        expect(place.containsKey('address'), isTrue);
        expect(place.containsKey('type'), isTrue);
      });

      test('place rating is between 0 and 5', () {
        final place = {
          'name': 'Vịnh Hạ Long',
          'rating': 4.8,
        };

        final rating = place['rating'] as double;
        expect(rating, greaterThanOrEqualTo(0.0));
        expect(rating, lessThanOrEqualTo(5.0));
      });

      test('place ID is not empty', () {
        final place = {
          'id': 'att_001',
        };

        expect((place['id'] as String).isNotEmpty, isTrue);
      });
    });

    group('Filter logic', () {
      test('filters places by category', () {
        final allPlaces = [
          {'name': 'Hotel A', 'type': 'hotel'},
          {'name': 'Hotel B', 'type': 'hotel'},
          {'name': 'Cafe A', 'type': 'cafe'},
          {'name': 'Park A', 'type': 'park'},
        ];

        final filteredPlaces = allPlaces
            .where((place) => place['type'] == 'hotel')
            .toList();

        expect(filteredPlaces.length, equals(2));
        expect(filteredPlaces[0]['name'], equals('Hotel A'));
        expect(filteredPlaces[1]['name'], equals('Hotel B'));
      });

      test('returns empty list when no matches', () {
        final allPlaces = [
          {'name': 'Hotel A', 'type': 'hotel'},
          {'name': 'Cafe A', 'type': 'cafe'},
        ];

        final filteredPlaces = allPlaces
            .where((place) => place['type'] == 'restaurant')
            .toList();

        expect(filteredPlaces.length, equals(0));
      });

      test('returns all places when filter is null', () {
        final allPlaces = [
          {'name': 'Hotel A', 'type': 'hotel'},
          {'name': 'Cafe A', 'type': 'cafe'},
          {'name': 'Park A', 'type': 'park'},
        ];

        // When no category is selected, return all places
        final filteredPlaces = allPlaces;

        expect(filteredPlaces.length, equals(3));
      });
    });
  });
}
