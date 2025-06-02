import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  /// Return the right [FirebaseOptions] depending on the current platform.
  static FirebaseOptions get currentPlatform {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return android;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return ios;
        default:
          throw UnsupportedError(
              'DefaultFirebaseOptions have not been configured for '
                  '${defaultTargetPlatform.name}. '
                  'You can reconfigure this by running '
                  'flutterfire configure --platform all'
          );
      }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7esb0DLkchUanlqFL4DpW1umq8LNzl0Q',
    appId: '1:104407269868:android:00494aef897f47857a00c9',
    messagingSenderId: '104407269868',
    projectId: 'virtual-visiting-card-viper',
    storageBucket: 'virtual-visiting-card-viper.firebasestorage.app',
  );

  /// iOS / macOS Firebase configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATa5V_t9Ezj_Y1TAwkwmSqCRQWGDcQx3E',
    appId: '1:104407269868:ios:b63e441dd2dbdfc07a00c9',
    messagingSenderId: '104407269868',
    projectId: 'virtual-visiting-card-viper',
    storageBucket: 'virtual-visiting-card-viper.firebasestorage.app',
    iosBundleId: 'com.example.virtualVisitingCardViper',
  );
}
