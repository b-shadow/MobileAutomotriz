import 'package:mobile1_app/core/constants/api_constants.dart';

/// Application environment configuration.
enum Environment { local, production }

class EnvConfig {
  EnvConfig._();

  static Environment currentEnv = Environment.local;

  /// ─── TENANT FIJO ───────────────────────────────────────
  /// Slug de la empresa para este prototipo.
  /// Cada build de la app va dirigido a una empresa específica.
  /// Cambia este valor según la empresa que usará la app.
  static const String tenantSlug = 'santacruz';

  /// ─── STRIPE ─────────────────────────────────────────
  static const String stripePublishableKey =
      'pk_test_51T75yKLq4p0YDKntvZ339U5Tpglyn9fuxuKGSOmDBgAh2wQhAHuxf101Fmm9F4myehJe67W6Z3JVWYj6JfzkrHjo00hy93gqzu';

  /// Base URL based on current environment.
  static String get baseUrl {
    switch (currentEnv) {
      case Environment.local:
        return ApiConstants.baseUrl;
      case Environment.production:
        return ApiConstants.prodBaseUrl;
    }
  }

  /// Whether to show debug information.
  static bool get isDebug => currentEnv == Environment.local;
}
