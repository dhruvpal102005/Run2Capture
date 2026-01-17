import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration matching React Native .env settings
class FirebaseConfig {
  static const String apiKey = 'AIzaSyCg-fdxwVolTxixdTd7jdJDmOH4hLl2u_M';
  static const String authDomain = 'kapture-a8a6a.firebaseapp.com';
  static const String projectId = 'kapture-a8a6a';
  static const String storageBucket = 'kapture-a8a6a.firebasestorage.app';
  static const String messagingSenderId = '510774180540';
  static const String appId = '1:510774180540:web:4ba1cf7bf4c0ce1aa1eeb9';

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
          'FirebaseConfig has not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'FirebaseConfig are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.kapture.kaptureFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.kapture.kaptureFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );
}

/// Google Maps API Key
class MapsConfig {
  static const String googleMapsApiKey = 'AIzaSyCeT7MezueKPo9ueFSo8bg8R3dlTejD9cs';
  static const String mapboxAccessToken = 'pk.eyJ1IjoiZGhydXZwYWwyMyIsImEiOiJjbWtnd25xbXEwYWc2M2VxdGZ2aGI4ZWFoIn0.ZG6jeEz0dcgYni_YwlpmHA';
}
