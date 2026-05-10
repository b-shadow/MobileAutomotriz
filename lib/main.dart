import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'config/env/env_config.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'injection_container.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb) {
      // Lock orientation to portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // System UI style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }

    // Initialize SharedPreferences before DI
    final prefs = await SharedPreferences.getInstance();

    // Initialize Stripe
    Stripe.publishableKey = EnvConfig.stripePublishableKey;
    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      print('Stripe applySettings error (ignoring on web): $e');
    }

    // Initialize dependency injection
    await initDependencies(prefs);

    // Check auth session
    sl<AuthCubit>().checkAuthStatus();

  } catch (e, stackTrace) {
    print('====================== ERROR IN MAIN ======================');
    print(e);
    print(stackTrace);
    print('===========================================================');
  } finally {
    // Ensure runApp is always called so the app doesn't hang on the splash screen
    runApp(const App());
  }
}
