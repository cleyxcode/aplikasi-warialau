import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Optional Sentry init — no-op when DSN is empty.
class SentryService {
  SentryService._();

  /// Compile-time / runtime DSN. Leave empty in local/dev.
  /// Pass via: `--dart-define=SENTRY_DSN=https://...@sentry.io/...`
  static const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static Future<void> init(Future<void> Function() appRunner) async {
    if (dsn.isEmpty) {
      debugPrint('[Sentry] DSN empty — crash reporting disabled');
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
        options.environment = kReleaseMode ? 'production' : 'development';
        options.sendDefaultPii = false;
      },
      appRunner: appRunner,
    );
  }

  static Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    if (dsn.isEmpty) {
      debugPrint('[Sentry] $error');
      return;
    }
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (extras != null && extras.isNotEmpty) {
          scope.setContexts('extras', extras);
        }
      },
    );
  }
}
