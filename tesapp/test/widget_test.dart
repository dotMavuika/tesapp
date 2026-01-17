import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesapp/main.dart';
import 'package:tesapp/controllers/auth_controller.dart';

void main() {
  testWidgets('Smoke test - carga la app sin crashear', (WidgetTester tester) async {
    // Crear instancia fake para pruebas
    final fakeAuth = AuthController.test(
      isInitialized: true,
      isLoggedIn: false,
    );

    // Crear el widget raíz (tu MyApp requiere authController)
    final root = MyApp(authController: fakeAuth);

    // Montar la app
    await tester.pumpWidget(root);

    // Construir el árbol
    await tester.pump();

    // La app debe mostrar un MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verificar que muestra la pantalla de onboarding (porque isLoggedIn: false)
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}