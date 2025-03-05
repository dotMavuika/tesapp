import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de check animado
            const Icon(
              Icons.check_circle_outline,
              color: Colors.purple,
              size: 120.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Inicio de Sesión Exitoso',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Bienvenido a la App TESA',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                // Aquí podrías navegar a otra pantalla o realizar alguna acción
                // Por ahora, dejamos un print para verificar
                print('Continuar presionado');
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}