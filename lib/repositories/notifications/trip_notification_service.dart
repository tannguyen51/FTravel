import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service để gửi trip reminders và notifications
class TripNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Lưu FCM token vào Firestore khi user login
  Future<void> saveFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      final user = FirebaseAuth.instance.currentUser;
      if (token != null && user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Gửi notification local khi có trip sắp đến
  Future<void> checkUpcomingTrips() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final tomorrow = DateTime(today.year, today.month, today.day + 1);

      final trips = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('trips')
          .where('startDate', isEqualTo: tomorrow)
          .get();

      for (var trip in trips.docs) {
        final tripData = trip.data();
        print('🔔 Upcoming trip tomorrow: ${tripData['tripName']}');
        // FCM handling - notification đã được log
        // Để gửi notification thực tế, cần backend Cloud Functions
      }
    } catch (e) {
      // Silent fail
    }
  }
}
