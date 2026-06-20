import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!PushNotificationService.isFirebaseConfiguredForCurrentPlatform) {
    return;
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: PushNotificationService.firebaseOptionsForCurrentPlatform,
    );
  }
}

class PushRegistrationResult {
  final bool registered;
  final String? message;

  const PushRegistrationResult({
    required this.registered,
    this.message,
  });
}

class PushNotificationService {
  PushNotificationService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificaciones operativas',
    description: 'Alertas del taller y eventos operativos relevantes.',
    importance: Importance.high,
  );

  bool _initialized = false;

  static bool get isFirebaseConfiguredForCurrentPlatform {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return EnvConfig.firebaseAndroidAppId.isNotEmpty;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return EnvConfig.firebaseIosAppId.isNotEmpty;
    }
    return false;
  }

  static FirebaseOptions get firebaseOptionsForCurrentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAndroidAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: EnvConfig.firebaseStorageBucket,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseIosAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: EnvConfig.firebaseStorageBucket,
      );
    }

    throw UnsupportedError('Push nativo solo está soportado en Android/iOS.');
  }

  String get _slug {
    final userData = _sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  Future<void> initialize() async {
    if (_initialized || !isFirebaseConfiguredForCurrentPlatform) {
      if (!isFirebaseConfiguredForCurrentPlatform) {
        debugPrint(
          'Push móvil desactivado: faltan app IDs Firebase de Android/iOS en EnvConfig.',
        );
      }
      return;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: firebaseOptionsForCurrentPlatform,
      );
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Push abierto desde background: ${message.data}');
    });

    _messaging.onTokenRefresh.listen((token) async {
      if (!_sessionStorage.isLoggedIn) {
        return;
      }
      await _registerBackendToken(token);
    });

    _initialized = true;
  }

  Future<void> syncIfPermissionGranted() async {
    if (!_sessionStorage.isLoggedIn || !isFirebaseConfiguredForCurrentPlatform) {
      return;
    }

    final settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerBackendToken(token);
      }
    }
  }

  Future<PushRegistrationResult> requestPermissionAndRegisterToken() async {
    if (!_sessionStorage.isLoggedIn) {
      return const PushRegistrationResult(
        registered: false,
        message: 'No hay una sesión activa para registrar este dispositivo.',
      );
    }

    if (kIsWeb) {
      return const PushRegistrationResult(
        registered: false,
        message:
            'El registro push nativo no estÃ¡ disponible cuando esta app mÃ³vil corre como Flutter web.',
      );
    }

    if (!isFirebaseConfiguredForCurrentPlatform) {
      return const PushRegistrationResult(
        registered: false,
        message:
            'Firebase móvil no está configurado todavía. Completa los app IDs y archivos nativos del proyecto.',
      );
    }

    try {
      await initialize();
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final status = settings.authorizationStatus;
      if (status != AuthorizationStatus.authorized &&
          status != AuthorizationStatus.provisional) {
        return const PushRegistrationResult(
          registered: false,
          message:
              'Debes permitir notificaciones del sistema para registrar este dispositivo móvil.',
        );
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return const PushRegistrationResult(
          registered: false,
          message: 'No se pudo obtener el token push del dispositivo.',
        );
      }

      await _registerBackendToken(token);
      return const PushRegistrationResult(registered: true);
    } catch (error) {
      return PushRegistrationResult(
        registered: false,
        message: 'No se pudo registrar el dispositivo push: $error',
      );
    }
  }

  Future<void> deactivateCurrentDevice() async {
    final token = _sessionStorage.pushToken;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _apiClient.post(
        ApiConstants.desactivarTokenPush(_slug),
        data: {'token': token},
      );
    } catch (error) {
      debugPrint('No se pudo desactivar token push en backend: $error');
    } finally {
      await _sessionStorage.clearPushToken();
    }
  }

  Future<void> _registerBackendToken(String token) async {
    final payload = await _buildPayload(token);
    await _apiClient.post(
      ApiConstants.registrarTokenPush(_slug),
      data: payload,
    );
    await _sessionStorage.savePushToken(token);
  }

  Future<Map<String, dynamic>> _buildPayload(String token) async {
    final platform =
        defaultTargetPlatform == TargetPlatform.android ? 'ANDROID' : 'IOS';
    final label = await _resolveDeviceLabel();
    final userAgent = await _resolveUserAgent();

    return {
      'token': token,
      'plataforma': platform,
      'device_label': label,
      'user_agent': userAgent,
    };
  }

  Future<String> _resolveDeviceLabel() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfo.androidInfo;
        return '${info.brand} ${info.model}'.trim();
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfo.iosInfo;
        return '${info.name} ${info.model}'.trim();
      }
    } catch (_) {
      // fallback below
    }
    return 'Dispositivo móvil';
  }

  Future<String> _resolveUserAgent() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfo.androidInfo;
        return 'Android ${info.version.release}; ${info.brand} ${info.model}';
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfo.iosInfo;
        return 'iOS ${info.systemVersion}; ${info.name} ${info.model}';
      }
    } catch (_) {
      // fallback below
    }
    return 'Mobile App';
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Push local seleccionado: ${response.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
