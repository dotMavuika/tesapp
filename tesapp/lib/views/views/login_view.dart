import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_menu.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

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
        'action': 'login'
      };

      // Usar logger para registrar la petición
      logger.i(body);

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      
     // if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Usar logger para registrar la respuesta
      logger.i(response.body);

      final data = json.decode(response.body);

  logger.i(data);
  logger.i(response.statusCode);
      if (response.statusCode == 200) {
        
        if (data["result"]== "ok") {
          // Log in exitoso
          logger.i('Login exitoso');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
        } else {
          _showSnackBar('Login fallido: ${data['message'] ?? 'Error desconocido'}');
        }
      } else {
        _showSnackBar('Error de conexión: ${response.statusCode}');
      }
    } catch (e) {
     // if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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