// Placeholder. Generate the real file for your own Firebase project with:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That overwrites this file with your project's keys.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  /// False until `flutterfire configure` has been run; main() then shows setup
  /// instructions instead of crashing.
  static bool get isConfigured => !currentPlatform.apiKey.startsWith('REPLACE');

  static FirebaseOptions get currentPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => ios,
    _ => android,
  };

  static const android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE',
  );

  static const ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE',
    iosBundleId: 'com.sachincharles.careConnectFirebase',
  );
}
