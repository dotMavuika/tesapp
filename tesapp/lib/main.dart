// main.dart
import 'package:flutter/material.dart';
import 'views/views/login_view.dart'; // Asegúrate de usar la ruta correcta

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Puedes personalizar más el tema aquí
      ),
      home: const LoginView(),
    );
  }
}