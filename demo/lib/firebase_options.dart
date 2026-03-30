// Tạo file này bằng lệnh `flutterfire configure`.
// Hoặc copy config từ Firebase Console (phần web/Android/iOS) vào cấu trúc DefaultFirebaseOptions dưới.

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
        return macos;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAydcPL8v5Uv6Y_cCq7oX63Sed83MCQw6Y',
    authDomain: 'ltdd-380fa.firebaseapp.com',
    projectId: 'ltdd-380fa',
    storageBucket: 'ltdd-380fa.firebasestorage.app',
    messagingSenderId: '865940719595',
    appId: '1:865940719595:web:3c1575fabfa202a4e8bbae',
    measurementId: 'G-9BQRY2CHXL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'ltdd-380fa',
    storageBucket: 'ltdd-380fa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'ltdd-380fa',
    storageBucket: 'ltdd-380fa.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );

  static const FirebaseOptions macos = ios;
}
