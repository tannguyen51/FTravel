import 'package:firebase_messaging/firebase_messaging.dart';

/// Service để xử lý Firebase Cloud Messaging (FCM)
/// Nhận push notifications từ Firebase
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Khởi tạo notification service
  Future<void> initialize() async {
    // Request permission (iOS 10+)
    await _requestPermission();

    // Lấy FCM token
    await _getFCMToken();

    // Lắng nghe notifications
    _setupFCMListeners();
  }

  /// Request notification permission (iOS 10+)
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  /// Lấy FCM token để gửi lên server
  Future<String?> _getFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      print('========================================');
      print('FCM TOKEN (Copy this):');
      print(token);
      print('========================================');

      // TODO: Lưu token vào Firestore để gửi notifications từ server
      // Example:
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .update({'fcmToken': token});

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Lắng nghe FCM messages
  void _setupFCMListeners() {
    // Khi app ở foreground - notification sẽ được hiển thị bởi hệ thống
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');

      // Notification sẽ tự động hiển thị bởi hệ thống Android/iOS
      // khi app ở background hoặc terminated
    });

    // Khi user tap vào notification (app ở background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened by user');
      print('Title: ${message.notification?.title}');

      // TODO: Navigate to specific screen based on notification data
      // Example:
      // if (message.data['screen'] == 'trip_details') {
      //   Navigator.pushNamed(context, '/tripDetails', arguments: message.data['tripId']);
      // }
    });

    // Kiểm tra notification đã mở khi app khởi động (app was terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        // TODO: Navigate to specific screen
      }
    });
  }

  /// Subscribe to topic (ví dụ: nhận notifications về trips)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
