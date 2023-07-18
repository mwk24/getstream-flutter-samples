// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyD6ZgqOySWdKxqc7z3-g6x6cl4KcayCVFs',
    appId: '1:484969089316:web:c5d3da5febbbc8bf9dcbb1',
    messagingSenderId: '484969089316',
    projectId: 'group-fund-7becd',
    authDomain: 'group-fund-7becd.firebaseapp.com',
    storageBucket: 'group-fund-7becd.appspot.com',
    measurementId: 'G-8YL5Z61T9Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2p1vCrvG785lkl7zc9HapJFP6xjnxk7c',
    appId: '1:484969089316:android:ab149ef6835f934e9dcbb1',
    messagingSenderId: '484969089316',
    projectId: 'group-fund-7becd',
    storageBucket: 'group-fund-7becd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAm3j8STvWtK8vjPNim3OGFhz6mblrmt1U',
    appId: '1:484969089316:ios:942381ada05ceab09dcbb1',
    messagingSenderId: '484969089316',
    projectId: 'group-fund-7becd',
    storageBucket: 'group-fund-7becd.appspot.com',
    iosClientId: '484969089316-e0jvl38928e1f6hvfpd7mtfh93cm8tlk.apps.googleusercontent.com',
    iosBundleId: 'com.mwk24.getstreamdemo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAm3j8STvWtK8vjPNim3OGFhz6mblrmt1U',
    appId: '1:484969089316:ios:1eb82990e1b02ca39dcbb1',
    messagingSenderId: '484969089316',
    projectId: 'group-fund-7becd',
    storageBucket: 'group-fund-7becd.appspot.com',
    iosClientId: '484969089316-r44lke7rq0b2oup1nvvo8c31pd3ahfvc.apps.googleusercontent.com',
    iosBundleId: 'io.getstream.streamChatV1',
  );
}
