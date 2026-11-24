import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/error_reporting.dart';
import 'core/push_notifications.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!DefaultFirebaseOptions.isConfigured) {
    runApp(const _SetupRequiredApp());
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Sentry wraps the app so uncaught Flutter and Dart errors are reported.
  await SentryFlutter.init(
    (o) => o
      ..dsn = sentryDsn
      ..environment = kReleaseMode ? 'production' : 'debug'
      ..tracesSampleRate = 0.2,
    appRunner: () => runApp(
      ProviderScope(
        observers: const [SentryProviderObserver()],
        child: const CareConnectApp(),
      ),
    ),
  );
}

class CareConnectApp extends ConsumerStatefulWidget {
  const CareConnectApp({super.key});

  @override
  ConsumerState<CareConnectApp> createState() => _CareConnectAppState();
}

class _CareConnectAppState extends ConsumerState<CareConnectApp> {
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  final _push = PushNotifications();

  @override
  void initState() {
    super.initState();
    // Register for pushes once we know who is signed in.
    ref.listenManual(currentUserProvider, (_, next) {
      final user = next.value;
      if (user == null) return;
      Sentry.configureScope(
        (s) =>
            s.setUser(SentryUser(id: user.uid, data: {'role': user.role.name})),
      );
      _push.start(
        saveToken: (t) =>
            ref.read(authRepositoryProvider).saveFcmToken(user.uid, t),
        onForeground: (m) => _messenger.currentState?.showSnackBar(
          SnackBar(content: Text(m.notification?.title ?? 'New care update')),
        ),
      );
    });
  }

  @override
  void dispose() {
    _push.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'CareConnect',
    debugShowCheckedModeBanner: false,
    scaffoldMessengerKey: _messenger,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF00897B),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorSchemeSeed: const Color(0xFF00897B),
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    routerConfig: ref.watch(routerProvider),
  );
}

class _SetupRequiredApp extends StatelessWidget {
  const _SetupRequiredApp();

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Firebase is not configured yet.\n\nRun `flutterfire configure` in the project folder, '
            'then restart the app. See README.md.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
