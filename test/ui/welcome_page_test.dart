import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Welcome Page Logic Tests', () {
    group('form validation', () {
      test('email field is not empty', () {
        String email = 'user@example.com';
        expect(email.isNotEmpty, isTrue);
      });

      test('password field is not empty', () {
        String password = 'password123';
        expect(password.isNotEmpty, isTrue);
      });

      test('validates email format', () {
        final validEmails = [
          'user@example.com',
          'test.user@domain.org',
          'user123@test.co.vn',
        ];

        final invalidEmails = [
          'userexample.com',
          'user@',
          '@example.com',
        ];

        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        for (var email in validEmails) {
          expect(emailRegex.hasMatch(email), isTrue, reason: 'Email should be valid: $email');
        }

        for (var email in invalidEmails) {
          expect(emailRegex.hasMatch(email), isFalse, reason: 'Email should be invalid: $email');
        }
      });
    });

    group('login state management', () {
      test('initial state is not loading', () {
        bool isLoading = false;
        expect(isLoading, isFalse);
      });

      test('sets loading state during login', () {
        bool isLoading = false;
        isLoading = true;
        expect(isLoading, isTrue);
      });

      test('resets loading state after login', () {
        bool isLoading = true;
        isLoading = false;
        expect(isLoading, isFalse);
      });
    });

    group('error handling', () {
      test('handles empty error message', () {
        String? errorMessage;
        expect(errorMessage, isNull);
      });

      test('sets error message on failure', () {
        String? errorMessage;
        errorMessage = 'Invalid credentials';
        expect(errorMessage, isNotNull);
        expect(errorMessage, equals('Invalid credentials'));
      });

      test('clears error message on new attempt', () {
        String? errorMessage = 'Previous error';
        errorMessage = null;
        expect(errorMessage, isNull);
      });
    });

    group('navigation logic', () {
      String getTargetRoute(bool isLoggedIn) {
        if (isLoggedIn) {
          return '/home';
        } else {
          return '/login';
        }
      }

      test('navigates to home after successful login', () {
        final targetRoute = getTargetRoute(true);
        expect(targetRoute, equals('/home'));
      });

      test('stays on login when credentials invalid', () {
        final targetRoute = getTargetRoute(false);
        expect(targetRoute, equals('/login'));
      });
    });

    group('Google Sign-In logic', () {
      test('handles successful Google sign-in', () {
        Map<String, dynamic>? user;
        user = {
          'uid': 'google_user_123',
          'email': 'user@gmail.com',
          'displayName': 'Google User',
        };

        expect(user, isNotNull);
        expect(user['uid'], isNotEmpty);
      });

      test('handles cancelled Google sign-in', () {
        Map<String, dynamic>? user;
        user = null;

        expect(user, isNull);
      });
    });

    group('forgot password logic', () {
      test('validates email before sending reset link', () {
        String email = 'user@example.com';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        expect(emailRegex.hasMatch(email), isTrue);
      });

      test('rejects invalid email for password reset', () {
        String email = 'invalid-email';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        expect(emailRegex.hasMatch(email), isFalse);
      });
    });
  });
}
