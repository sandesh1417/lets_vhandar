import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClW2_ieHBeuFsUSPTdxYRVye8URqLu824',
    appId: '1:994211517892:android:ad7074d9ae3cbe4ae1c091',
    messagingSenderId: '994211517892',
    projectId: 'vhandar-cf8f7',
    storageBucket: 'vhandar-cf8f7.firebasestorage.app',
  );
}
