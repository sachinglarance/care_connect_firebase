import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry error reporting: a provider observer that reports failed providers,
/// and the DSN read from `--dart-define`.
///
/// Reports every provider that fails (e.g. a Firestore permission error) to
/// Sentry with the provider name attached.
final class SentryProviderObserver extends ProviderObserver {
  const SentryProviderObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) => scope.setTag(
        'provider',
        context.provider.name ?? context.provider.runtimeType.toString(),
      ),
    );
  }
}

/// DSN comes from `--dart-define=SENTRY_DSN=...` so it never lives in git.
/// With no DSN, Sentry is a no-op.
const sentryDsn = String.fromEnvironment('SENTRY_DSN');
