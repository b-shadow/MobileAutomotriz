import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'config/env/env_config.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize SharedPreferences before DI
  final prefs = await SharedPreferences.getInstance();

  // Initialize Stripe
  Stripe.publishableKey = EnvConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  // Initialize dependency injection
  await initDependencies(prefs);

  runApp(const App());
}
