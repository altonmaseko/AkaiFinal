import 'package:akai/api/firebase_api.dart';
import 'package:akai/firebase_options.dart';
import 'package:akai/utils/constants/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'app.dart';
import 'package:akai/api/firebase_api.dart';

// background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // [WORKING: triggered when app running in background and notification sent]
  print("BACKGOUND MESSAGE: ${message.messageId}");
}

void main() async {
  // HIVE ===========

  await Hive.initFlutter();

  var box = await Hive.openBox("myBox");

  // END: HIVE

  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotifications();

  runApp(const App());
}
