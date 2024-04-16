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
    apiKey: 'AIzaSyBgcD_tyeFSOm-PhvAz7RSHVHI-xcW1Kfw',
    appId: '1:540606801653:web:f37146101c79c148dc47bc',
    messagingSenderId: '540606801653',
    projectId: 'project2mad',
    authDomain: 'project2mad.firebaseapp.com',
    storageBucket: 'project2mad.appspot.com',
    measurementId: 'G-SLS5KYYL96',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDCprSckjckDFjUDTit1FjpsyYFunHdjEA',
    appId: '1:540606801653:android:51a109d48a16ae01dc47bc',
    messagingSenderId: '540606801653',
    projectId: 'project2mad',
    storageBucket: 'project2mad.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfjNVYEOfzvpGbFZ5uIS1QiamdxW6pKUM',
    appId: '1:540606801653:ios:2d4502757427e471dc47bc',
    messagingSenderId: '540606801653',
    projectId: 'project2mad',
    storageBucket: 'project2mad.appspot.com',
    iosBundleId: 'com.example.artfolio',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfjNVYEOfzvpGbFZ5uIS1QiamdxW6pKUM',
    appId: '1:540606801653:ios:2d4502757427e471dc47bc',
    messagingSenderId: '540606801653',
    projectId: 'project2mad',
    storageBucket: 'project2mad.appspot.com',
    iosBundleId: 'com.example.artfolio',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBgcD_tyeFSOm-PhvAz7RSHVHI-xcW1Kfw',
    appId: '1:540606801653:web:512ac204a34812dfdc47bc',
    messagingSenderId: '540606801653',
    projectId: 'project2mad',
    authDomain: 'project2mad.firebaseapp.com',
    storageBucket: 'project2mad.appspot.com',
    measurementId: 'G-HRCHW1LJ4G',
  );
}
