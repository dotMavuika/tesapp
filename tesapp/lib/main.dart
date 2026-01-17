// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';



import 'controllers/dashboard_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/login_controller.dart';

import 'screens/onboding/onboding_screen.dart';
import 'screens/profile/general_profile.dart';
import 'screens/finance/finance_vew.dart';
import 'screens/entryPoint/entry_point.dart';

import 'services/session_manager.dart';
import 'services/credential_storage.dart';
import 'services/notification_news.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('tesapp');

  // 🔔 Inicializar notificaciones (DEMO PUSH)
  await NewsNotificationService.init();

  // 🔹 AuthController: reconstruye sesión desde Hive + SessionManager
  final authController = AuthController.instance;
  await authController.init();

  // 🔹 Revalidar sesión
  await _ensureValidSession(authController);

  runApp(MyApp(
    authController: authController,
  ));
}


/// Noticias


/// Intenta garantizar que al arrancar tengas una sesión coherente:
/// - Usa SessionManager para validar el token si existe.
/// - Si hace falta, intenta login silencioso con credenciales guardadas.
/// - OJO: LoginController.login() ya llama internamente a
///   AuthController.persistCurrentSession(rememberSession: ...),
///   así que aquí NO volvemos a llamarlo.
Future<void> _ensureValidSession(AuthController authController) async {
  final sessionManager = SessionManager();
  final loginController = LoginController();

  // Caso 1: hay token en SessionManager → validar contra la API
  if (sessionManager.authToken != null &&
      sessionManager.authToken!.isNotEmpty) {
    final stillValid = await sessionManager.validateSession();
    if (stillValid && authController.isLoggedIn) {
      // Sesión válida y AuthController ya tiene estado consistente
      return;
    }
    // Si el token es válido pero AuthController NO está logueado,
    // dejamos que el flujo continúe al login silencioso para
    // reconstruir profile/userData/etc si hace falta.
  }

  // Caso 2: intentar re-login silencioso si hay credenciales guardadas
  final creds = await CredentialsStorage.load();
  if (creds == null) {
    return;
  }

  final result = await loginController.login(
    creds['user']!,
    creds['pass']!,
    rememberSession: true, // tiene sentido: si guardaste credenciales, quieres sesión recordada
  );

  final success = result['success'] == true;

  // No llamamos a authController.persistCurrentSession() aquí,
  // porque LoginController.login() ya lo hace internamente en caso de éxito.
}

class MyApp extends StatelessWidget {
  final AuthController authController;

  const MyApp({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DashboardController()),
        ChangeNotifierProvider<AuthController>.value(value: authController),
      ],
      child: Consumer<AuthController>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'TESApp',
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFFEEF1F8),
              primarySwatch: Colors.blue,
              fontFamily: "Intel",
              visualDensity: VisualDensity.adaptivePlatformDensity,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(height: 0),
                border: defaultInputBorder,
                enabledBorder: defaultInputBorder,
                focusedBorder: defaultInputBorder,
                errorBorder: defaultInputBorder,
              ),
            ),
            // 🔹 Pantalla inicial depende SOLO de AuthController
            home: _buildHome(auth),
            routes: {
              '/profile': (context) => const GeneralProfile(),
              '/finance': (context) => const FinanceView(),
              '/home': (context) => const EntryPoint(),
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthController auth) {
    // Mientras AuthController termina su init
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si AuthController dice “logueado” → vamos directo al home
    if (auth.isLoggedIn) {
      return const EntryPoint();
    }

    // Si no, mostramos la pantalla de login
    return const OnbodingScreen();
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
