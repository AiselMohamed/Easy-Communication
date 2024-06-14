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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC2lmCFfi4WiVeW01UBJFm95PsHBii8GMg',
    appId: '1:392491605325:web:f3bd515f00760e43a32b04',
    messagingSenderId: '392491605325',
    projectId: 'chat1-b4bc9',
    authDomain: 'chat1-b4bc9.firebaseapp.com',
    storageBucket: 'chat1-b4bc9.appspot.com',
    measurementId: 'G-J6FFKZ5XP0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBb_Upxmi0DicrI6TVopkLVoOhVDGPKHL8',
    appId: '1:392491605325:android:013129d88c66bf18a32b04',
    messagingSenderId: '392491605325',
    projectId: 'chat1-b4bc9',
    storageBucket: 'chat1-b4bc9.appspot.com',
  );
}
