# FTravel - Flutter Travel App

A cross-platform mobile application built with Flutter for travel planning and exploration. Users can search destinations, plan trips, save favorites, and view weather info.

## Features

- User authentication (Email/Password, Google Sign-In)
- Browse and search places of interest
- Trip planning with itinerary management
- Favorites list
- Real-time weather via OpenWeatherMap API
- Firebase integration (Auth, Firestore, Realtime Database)


## Built With

- Flutter & Dart
- Firebase (Authentication, Firestore, Realtime Database)
- OpenWeatherMap API
- BLoC Pattern

## Setup

1. Clone the repository
2. Run `flutter pub get`
3. Ensure Firebase project is configured (see `lib/repositories/firebase_options.dart`)
4. Seed data into Firestore and Realtime Database via the in-app `/seed` route
5. Run `flutter run`
