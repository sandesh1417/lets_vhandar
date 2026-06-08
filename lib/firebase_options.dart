import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

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
    apiKey: 'AIzaSyCBFN4IsaNk0VE4A5chVM1uy4XGCuUm-n0',
    appId: '1:683559346199:android:6a5ee3db2f9039a882fc52',
    messagingSenderId: '683559346199',
    projectId: 'vhandar-950a3',
    storageBucket: 'vhandar-950a3.firebasestorage.app',
  );
}
