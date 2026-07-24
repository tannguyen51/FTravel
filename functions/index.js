// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Gửi notification khi user tạo trip mới
exports.sendTripCreatedNotification = functions.firestore
  .document('trips/{tripId}')
  .onCreate(async (snap, context) => {
    const trip = snap.data();
    const userId = trip.userId;

    // Lấy FCM token của user
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();

    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log('No FCM token found for user:', userId);
      return null;
    }

    // Gửi notification
    const message = {
      token: fcmToken,
      notification: {
        title: 'Trip mới đã được tạo! 🎉',
        body: `Chuyến đi "${trip.name}" của bạn đã sẵn sàng`
      },
      data: {
        screen: 'trip_details',
        tripId: context.params.tripId
      }
    };

    try {
      await admin.messaging().send(message);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }

    return null;
  });

// Gửi reminder 1 ngày trước trip
exports.sendTripReminder = functions.pubsub
  .schedule('every day 09:00')
  .onRun(async (context) => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);

    const trips = await admin.firestore()
      .collection('trips')
      .where('startDate', '>=', tomorrow)
      .where('startDate', '<', new Date(tomorrow.getTime() + 86400000))
      .get();

    const promises = [];

    trips.forEach(async (tripDoc) => {
      const trip = tripDoc.data();
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(trip.userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: 'Trip ngày mai! 🗓️',
            body: `Chuyến đi "${trip.name}" bắt đầu ngày mai`
          }
        };

        promises.push(admin.messaging().send(message));
      }
    });

    await Promise.all(promises);
    return null;
  });
