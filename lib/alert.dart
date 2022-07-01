import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class alert {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String? mtoken = " ";

  void getToken(String id) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      mtoken = token;
      saveToken(token!, id);
    });
  }

  void saveToken(String token, String id) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc(id).set({
      'token': token,
    }).then((value) => print('Token saved'));
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      var resp = await http
          .post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAirbbhQ4:APA91bFdRVgv2IwFlcS1412eYpP9FEgw6BZ8kjaSPoZbNhfAfMIPOhXrHWvIk1zrSA0gvZ9Ksx5JCR-ZgYe4bCR8lub8jJBswx0nk8JDnH1suFPll6Gc-cVFMxbLAVmjn0GZ2vliWiOs',
            },
            body: jsonEncode(
              <String, dynamic>{
                'notification': <String, dynamic>{
                  'body': body,
                  'title': title,
                  "delivery_receipt_requested": true,
                  "sound": "default"
                },
                'priority': 'high',
                'data': <String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'id': '1',
                  'status': 'done'
                },
                "to": token,
                "direct_boot_ok": true
              },
            ),
          )
          .then((value) => print(value.body));
    } catch (e) {
      print(e);
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('We  Chat', 'We Chat',
                // playSound: true,
                // priority: Priority.high,
                // importance: Importance.high,
                icon: '@mipmap/ic_launcher',
                color: Colors.green),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}
