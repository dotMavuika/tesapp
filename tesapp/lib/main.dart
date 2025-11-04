import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/dashboard_controller.dart';
import 'package:tesapp/screens/onboding/onboding_screen.dart';
import 'screens/profile/general_profile.dart';
import 'screens/finance/finance_vew.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DashboardController()),
      ],
      child: MaterialApp(
        title: 'The Flutter Way',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFEEF1F8),
          primarySwatch: Colors.blue,
          fontFamily: "Intel",
          visualDensity: VisualDensity.adaptivePlatformDensity,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
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
        // Add routes configuration
        routes: {
          '/': (context) => const OnbodingScreen(),
          '/profile': (context) => const GeneralProfile(),
          '/finance': (context) => const FinanceView(),
        },
        // Change to initialRoute instead of home
        initialRoute: '/',
      ),
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);