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
  static const String tenantSlug = 'transformers';

  /// ─── STRIPE ─────────────────────────────────────────
  static const String stripePublishableKey =
      'pk_test_51T75yKLq4p0YDKntvZ339U5Tpglyn9fuxuKGSOmDBgAh2wQhAHuxf101Fmm9F4myehJe67W6Z3JVWYj6JfzkrHjo00hy93gqzu';

  /// Firebase móvil:
  /// Completa los app IDs reales al registrar Android/iOS en Firebase.
  /// Mientras estén vacíos, la app seguirá funcionando pero el push nativo
  /// quedará desactivado y solo estará disponible el centro de notificaciones.
  static const String firebaseApiKey = 'AIzaSyDNQNPQM6iToHBOREm2de8SrZ7kzgANse0';
  static const String firebaseProjectId = 'si2-taller-88be4';
  static const String firebaseMessagingSenderId = '447057788953';
  static const String firebaseStorageBucket = 'si2-taller-88be4.firebasestorage.app';
  static const String firebaseAndroidAppId = '1:447057788953:android:0917422825a0f92f252a88';
  static const String firebaseIosAppId = '';

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
