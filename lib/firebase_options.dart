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
    apiKey: 'AIzaSyDmNwyi5ahvVtfDF6Yl1kDyHxBE0gPTWew',
    appId: '1:133321103711:web:e9c8e439963643755e7eea',
    messagingSenderId: '133321103711',
    projectId: 'fukuhub-25859',
    authDomain: 'fukuhub-25859.firebaseapp.com',
    databaseURL: 'https://fukuhub-25859-default-rtdb.firebaseio.com',
    storageBucket: 'fukuhub-25859.appspot.com',
    measurementId: 'G-54Q087F2BC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBz5kbkf4aMc2OOt0OUJQ56jm1gDsjLS_Q',
    appId: '1:133321103711:android:bd4526c57d4020d25e7eea',
    messagingSenderId: '133321103711',
    projectId: 'fukuhub-25859',
    databaseURL: 'https://fukuhub-25859-default-rtdb.firebaseio.com',
    storageBucket: 'fukuhub-25859.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQQ7wfR6hAnTVf3cs5isGbnJSSMELtDxo',
    appId: '1:133321103711:ios:0b000b34a18ddab95e7eea',
    messagingSenderId: '133321103711',
    projectId: 'fukuhub-25859',
    databaseURL: 'https://fukuhub-25859-default-rtdb.firebaseio.com',
    storageBucket: 'fukuhub-25859.appspot.com',
    iosClientId: '133321103711-6iquhu34bd16kh3bhgb4targdni81deq.apps.googleusercontent.com',
    iosBundleId: 'com.fukuhub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQQ7wfR6hAnTVf3cs5isGbnJSSMELtDxo',
    appId: '1:133321103711:ios:834e56d4e118d1195e7eea',
    messagingSenderId: '133321103711',
    projectId: 'fukuhub-25859',
    databaseURL: 'https://fukuhub-25859-default-rtdb.firebaseio.com',
    storageBucket: 'fukuhub-25859.appspot.com',
    iosClientId: '133321103711-t443v8nu2pajndkvbnct82tmlg88dirn.apps.googleusercontent.com',
    iosBundleId: 'com.example.fukuhub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDmNwyi5ahvVtfDF6Yl1kDyHxBE0gPTWew',
    appId: '1:133321103711:web:9b1a5a071e5537dc5e7eea',
    messagingSenderId: '133321103711',
    projectId: 'fukuhub-25859',
    authDomain: 'fukuhub-25859.firebaseapp.com',
    databaseURL: 'https://fukuhub-25859-default-rtdb.firebaseio.com',
    storageBucket: 'fukuhub-25859.appspot.com',
    measurementId: 'G-0MPWK7HYY4',
  );

}