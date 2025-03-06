import 'package:flutter/material.dart';
import 'views/views/loading_view.dart'; // Importa la vista de carga

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Puedes personalizar más el tema aquí
      ),
      home: const LoadingView(), // Usa LoadingView como pantalla inicial
    );
  }
}