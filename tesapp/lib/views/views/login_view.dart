import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tesapp/models/profile_data_student.dart';
import 'dart:convert';
import 'main_menu.dart'; // Importa MainMenuScreen
import 'package:logger/logger.dart';
import '../../models/profile_data_student.dart'; // Asegúrate de importar el modelo

var logger = Logger(printer: PrettyPrinter());

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://tesa.academicok.com/apimobile/login');

    try {
      final body = {
        'user': userController.text,
        'pass': passController.text,
        'action': 'login',
      };

      // Log de la petición
      logger.i('Enviando petición de login con datos: $body');

      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      // if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Log de la respuesta completa
      logger.i('Respuesta del servidor - Status Code: ${response.statusCode}');
      logger.i('Respuesta del servidor - Body: ${response.body}');

      try {
        // Intentar decodificar el JSON
        final data = json.decode(response.body);
        logger.i('JSON decodificado correctamente:');
        logger.i(data);

        // Verificar campos clave que debería tener el JSON para ProfileDataStudent
        logger.i('Verificando campos esenciales:');
        logger.i('result existe: ${data.containsKey("result")}');
        logger.i('auth existe: ${data.containsKey("auth")}');
        logger.i(
          'perfilactivoid existe: ${data.containsKey("perfilactivoid")}',
        );
        logger.i('persona existe: ${data.containsKey("persona")}');
        logger.i('perfiles existe: ${data.containsKey("perfiles")}');

        // Intentar crear un objeto ProfileDataStudent
        if (data["result"] == "ok") {
          try {
            logger.i('Intentando crear objeto ProfileDataStudent...');
            final userData = ProfileDataStudent.fromJson(data);
            logger.i('ProfileDataStudent creado exitosamente:');
            logger.i('Nombre: ${userData.persona}');
            logger.i('Email: ${userData.email}');
            logger.i('Perfiles: ${userData.perfiles.length}');

            // Si llegamos aquí, el objeto se creó correctamente
            logger.i('Login exitoso con datos correctamente mapeados');

            // Navegación a la pantalla principal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainMenuScreen()),
            );
          } catch (e) {
            logger.e('Error al crear ProfileDataStudent: $e');
            _showSnackBar('Error al procesar datos de usuario: $e');
          }
        } else {
          logger.w('Login fallido: ${data['message'] ?? 'Error desconocido'}');
          _showSnackBar(
            'Login fallido: ${data['message'] ?? 'Error desconocido'}',
          );
        }
      } catch (e) {
        logger.e('Error al decodificar JSON: $e');
        _showSnackBar('Error al procesar respuesta: $e');
      }
    } catch (e) {
      // if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      logger.e('Error en la petición: $e');
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // El resto del código permanece igual...
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'App TESA',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            _isLoading
                ? CircularProgressIndicator(color: Colors.purple)
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text('Login'),
                ),
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }
}
