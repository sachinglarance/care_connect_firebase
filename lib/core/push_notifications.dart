import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// FCM push setup: permission, token registration and foreground messages, plus
/// the background message handler.
///
/// Runs in a background isolate when a push arrives and the app isn't in the
/// foreground. The OS shows `notification` payloads itself.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background push: ${message.messageId}');
}

class PushNotifications {
  PushNotifications([FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;
  final FirebaseMessaging _messaging;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _messageSub;

  /// Asks for permission, stores the device token for this user and keeps it
  /// fresh. [onForeground] lets the UI show an in-app banner.
  Future<void> start({
    required Future<void> Function(String token) saveToken,
    required void Function(RemoteMessage message) onForeground,
  }) async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Listen before registering: onRegistered delivers the token once
    // registration completes, and again whenever FCM rotates it.
    _tokenSub = _messaging.onRegistered.listen(saveToken);
    _messageSub = FirebaseMessaging.onMessage.listen(onForeground);
    try {
      await _messaging.register();
    } on FirebaseException catch (e) {
      // iOS simulators have no APNs token.
      debugPrint('FCM registration failed: ${e.code}');
    }
  }

  Future<void> stop() async {
    await _tokenSub?.cancel();
    await _messageSub?.cancel();
  }
}
