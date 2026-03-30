import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2_mobile/data/services/auth_service.dart';
import 'package:si2_mobile/data/services/storage_service.dart';
import 'package:si2_mobile/presentation/viewmodels/auth_viewmodel.dart';
import 'package:si2_mobile/presentation/pages/auth/login_page.dart';
import 'package:si2_mobile/presentation/pages/auth/register_page.dart';
import 'package:si2_mobile/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Storage
  final storageService = StorageService();
  await storageService.init();
  
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({Key? key, required this.storageService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => storageService),
        
        // ViewModels
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authService: context.read<AuthService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SI2 Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

/// Widget que controla qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoggedIn) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
