import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../main.dart';
import '../providers/contact_list.dart';
import '../screens/chat_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class PushNotifications {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const String _authServerKey = 'YOUR_FCM_AUTH_KEY'; // Paste your FCM auth Key here

  static Future<void> initialize() async {
    if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      ContactList().updateLastMessage(
          message.data['contactid'], message.notification?.body ?? '');
      ContactList().displayLastMessage(message.data['contactid']);
      ContactList().updateUnreadMessage(message.data['contactid'], true);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data != null) {
        _serializeAndNavigate(message.data);
      }
    });

    _fcm.onTokenRefresh.listen((newToken) {
      if (FirebaseAuth.instance.currentUser != null) {
        final userID = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'notificationtoken': newToken});
      }
    });
  }

  static Future<void> _serializeAndNavigate(
      Map<String, dynamic> messageData) async {
    final chatID = messageData['chatid'];
    final contactID = messageData['contactid'];
    DocumentSnapshot contactDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(contactID)
        .get();
    navigatorKey.currentState?.pushNamed(ChatScreen.routeName,
        arguments: {'chatID': chatID, 'contactDetails': contactDetails});
  }

  static Future<void> sendNotification(
      {String? title,
        String? message,
        String? chatID,
        String? userID,
        String? notificationToken}) async {
    final postUrl = "https://fcm.googleapis.com/fcm/send";
    final data = {
      "notification": {"body": message, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "chatid": chatID,
        "contactid": userID
      },
      "to": "$notificationToken"
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$_authServerKey'
    };
    BaseOptions options = new BaseOptions(
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 3000),
      headers: headers,
    );

    try {
      final response = await Dio(options).post(postUrl, data: data);

      if (response.statusCode == 200) {
        // Notification sent successfully
      } else {
        print('Notification sending failed');
        // Handle failure
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  static Future<String?> getNotificationsToken() async {
    return await _fcm.getToken();
  }
}
