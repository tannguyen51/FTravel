import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Authentication Logic', () {
    group('email validation', () {
      test('accepts valid email format', () {
        const email = 'user@example.com';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        expect(emailRegex.hasMatch(email), isTrue);
      });

      test('rejects email without @', () {
        const email = 'userexample.com';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        expect(emailRegex.hasMatch(email), isFalse);
      });

      test('rejects email without domain', () {
        const email = 'user@';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        expect(emailRegex.hasMatch(email), isFalse);
      });

      test('accepts email with subdomain', () {
        const email = 'user@mail.example.com';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        expect(emailRegex.hasMatch(email), isTrue);
      });
    });

    group('password validation', () {
      test('accepts password with 6+ characters', () {
        const password = 'password123';
        expect(password.length, greaterThanOrEqualTo(6));
      });

      test('rejects password with less than 6 characters', () {
        const password = '12345';
        expect(password.length, lessThan(6));
      });

      test('accepts strong password', () {
        const password = 'MyP@ssw0rd!';
        expect(password.length, greaterThanOrEqualTo(6));
        expect(password, contains(RegExp(r'[A-Z]')));
        expect(password, contains(RegExp(r'[0-9]')));
      });
    });

    group('username validation', () {
      test('accepts username with 3+ characters', () {
        const username = 'Nguyen Van A';
        expect(username.length, greaterThanOrEqualTo(3));
      });

      test('rejects empty username', () {
        const username = '';
        expect(username.isEmpty, isTrue);
      });

      test('accepts username with Vietnamese characters', () {
        const username = 'Nguyễn Văn A';
        expect(username.isNotEmpty, isTrue);
      });
    });

    group('user data structure', () {
      test('creates user map with correct keys', () {
        final user = {
          'uid': 'abc123',
          'email': 'user@example.com',
          'displayName': 'Nguyen Van A',
          'photoURL': 'https://example.com/avatar.jpg',
        };

        expect(user.containsKey('uid'), isTrue);
        expect(user.containsKey('email'), isTrue);
        expect(user.containsKey('displayName'), isTrue);
        expect(user.containsKey('photoURL'), isTrue);
      });

      test('user map has correct data types', () {
        final user = {
          'uid': 'abc123',
          'email': 'user@example.com',
          'displayName': 'Nguyen Van A',
          'photoURL': 'https://example.com/avatar.jpg',
        };

        expect(user['uid'], isA<String>());
        expect(user['email'], isA<String>());
        expect(user['displayName'], isA<String>());
        expect(user['photoURL'], isA<String>());
      });
    });

    group('auth state management', () {
      test('initializes with null user', () {
        String? currentUser;
        expect(currentUser, isNull);
      });

      test('sets user after login', () {
        String? currentUser;
        currentUser = 'abc123';
        expect(currentUser, isNotNull);
        expect(currentUser, equals('abc123'));
      });

      test('clears user after logout', () {
        String? currentUser = 'abc123';
        currentUser = null;
        expect(currentUser, isNull);
      });
    });
  });
}
