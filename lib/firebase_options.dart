import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnWBCvEQ_8r6hC7BxRLIAsC-sWPz0RNI8',
    appId: '1:514524285235:android:b4f52c7f14a67267791646',
    messagingSenderId: '514524285235',
    projectId: 'collosian-cleaner-service-app',
    databaseURL: 'https://collosian-cleaner-service-app-default-rtdb.firebaseio.com',
    storageBucket: 'collosian-cleaner-service-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdQi5qBoHHjkCASwrup7yXwCO6nMU5kfQ',
    appId: '1:514524285235:ios:4edc3b2b41ee8af4791646',
    messagingSenderId: '514524285235',
    projectId: 'collosian-cleaner-service-app',
    databaseURL: 'https://collosian-cleaner-service-app-default-rtdb.firebaseio.com',
    storageBucket: 'collosian-cleaner-service-app.firebasestorage.app',
    iosBundleId: 'app.ccs.io',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCzzP4Ko5CPkFv7_z5bqLBBDiCbNJ4J6M4',
    appId: '1:514524285235:web:d90a90a22a389a38791646',
    messagingSenderId: '514524285235',
    projectId: 'collosian-cleaner-service-app',
    authDomain: 'collosian-cleaner-service-app.firebaseapp.com',
    databaseURL: 'https://collosian-cleaner-service-app-default-rtdb.firebaseio.com',
    storageBucket: 'collosian-cleaner-service-app.firebasestorage.app',
    measurementId: 'G-KVX2B0C6WG',
  );

}