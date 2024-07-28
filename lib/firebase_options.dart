// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCva4HLL-eZ1RVJXB_evHDvZ9v8qgY378g',
    appId: '1:272258701868:web:04cb4d7adb59be3bdecf89',
    messagingSenderId: '272258701868',
    projectId: 'akaitracker-1402f',
    authDomain: 'akaitracker-1402f.firebaseapp.com',
    storageBucket: 'akaitracker-1402f.appspot.com',
    measurementId: 'G-ZMFYNY39HX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmH9ay2AGKX6xxSEOZShQrpfAIwD30Qsk',
    appId: '1:272258701868:android:9cfc434a642f760fdecf89',
    messagingSenderId: '272258701868',
    projectId: 'akaitracker-1402f',
    storageBucket: 'akaitracker-1402f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVsgW98NZCvC_6pZ2RphgEWNQ7nbQIKpc',
    appId: '1:272258701868:ios:1d7016aaf0035a43decf89',
    messagingSenderId: '272258701868',
    projectId: 'akaitracker-1402f',
    storageBucket: 'akaitracker-1402f.appspot.com',
    iosBundleId: 'com.akaitracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVsgW98NZCvC_6pZ2RphgEWNQ7nbQIKpc',
    appId: '1:272258701868:ios:1d7016aaf0035a43decf89',
    messagingSenderId: '272258701868',
    projectId: 'akaitracker-1402f',
    storageBucket: 'akaitracker-1402f.appspot.com',
    iosBundleId: 'com.akaitracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCva4HLL-eZ1RVJXB_evHDvZ9v8qgY378g',
    appId: '1:272258701868:web:730cb82517ecff32decf89',
    messagingSenderId: '272258701868',
    projectId: 'akaitracker-1402f',
    authDomain: 'akaitracker-1402f.firebaseapp.com',
    storageBucket: 'akaitracker-1402f.appspot.com',
    measurementId: 'G-5B7P48RXP7',
  );
}