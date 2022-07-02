import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_information/device_information.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otp_auth/Provider/StateManagement.dart';
import 'package:otp_auth/alert.dart';
import 'package:otp_auth/loading.dart';
import 'package:otp_auth/loginScreen.dart';
import 'package:otp_auth/message/message_screen.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.data}');
}

Future<void> callbackDispatcher(RemoteMessage message) {
  // initialise the plugin of flutterlocalnotifications.
  FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();

  // app_icon needs to be a added as a drawable
  // resource to the Android head project.
  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var IOS = const IOSInitializationSettings();

  // initialise settings for both Android and iOS device.
  RemoteNotification? notification = message.notification;
  var settings = InitializationSettings(android: android, iOS: IOS);
  flip.initialize(settings);
  _showNotificationWithDefaultSound(
      flip, notification!.title, notification.body);
  // ignore: void_checks
  return Future.value(true);
}

Future _showNotificationWithDefaultSound(
    flip, String? title, String? body) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id', 'your channel name',
      importance: Importance.max, priority: Priority.high);
  var iOSPlatformChannelSpecifics = const IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flip.show(0, title, body, platformChannelSpecifics,
      payload: 'Default_Sound');
}

Future<void> onApp(RemoteMessage message) {
  print('app in open ${message.data}');

  // ignore: void_checks
  return Future.value(true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FirebaseMessaging.onBackgroundMessage(callbackDispatcher);
  FirebaseMessaging.onMessageOpenedApp.listen(onApp);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<StateManagement>(create: (_) => StateManagement())
    ],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _imeiNo = "";
  // late String id;
  // late String name;

  Future getImei() async {
    late String imeiNo = '';

    try {
      imeiNo = await DeviceInformation.deviceIMEINumber;
      Provider.of<StateManagement>(context, listen: false).getImei(imeiNo);
      print(imeiNo);
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (!mounted) return;

    // setState(() {
    //   _imeiNo = imeiNo;
    // });

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    firebaseFirestore
        .collection("imei")
        .where("imei",
            isEqualTo: int.parse(
                Provider.of<StateManagement>(context, listen: false).imeiNo))
        .snapshots()
        .listen((event) async {
      if (event.docs.isNotEmpty) {
        for (var element in event.docs) {
          print(element.data()['imei']);
          // setState(() {
          //   id = element.data()['id'];
          //   name = element.data()['name'];
          // });
          Provider.of<StateManagement>(context, listen: false)
              .getIdAndName(element.data()['id'], element.data()['name']);
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => message_screen(
                    Provider.of<StateManagement>(context, listen: false).id,
                    Provider.of<StateManagement>(context, listen: false)
                        .name)));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
        print("Invalid Imei");
      }
    });
  }

  @override
  initState() {
    getImei();
    super.initState();
    alert obj = alert();
    obj.requestPermission();
    obj.loadFCM();
    obj.listenFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.green[400], body: ColorLoader5());
  }
}
