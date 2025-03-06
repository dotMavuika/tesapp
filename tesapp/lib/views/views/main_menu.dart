// Ejemplo de cómo usar el LoginController en tu pantalla de login
import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';
import 'package:flutter/material.dart';
import '../../models/global_vars.dart';
import '../../models/profile_data_student.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Usuario'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Iniciar Sesión'),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa usuario y contraseña';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtener instancia del controlador de login
      final loginController = LoginController();
      
      // Intentar iniciar sesión
      bool success = await loginController.login(
        _usernameController.text, 
        _passwordController.text
      );

      // Verificar estado de GlobalVars
      loginController.printGlobalVarsState();

      if (success) {
        // Navegación a la pantalla principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainMenuScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Credenciales incorrectas o error de conexión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Ejemplo de cómo acceder a los datos en tu pantalla principal


class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // Variables para almacenar la información del usuario
  String? _nombre;
  String? _email;
  String? _carrera;
  double? _promedio;
  int? _materiasAprobadas;
  String? _fotoUrl;
  
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    try {
      print('Cargando datos de usuario en MainMenuScreen...');
      
      // Verificamos el estado de las variables globales
      LoginController().printGlobalVarsState();
      
      // Obtenemos la instancia de GlobalVars
          final globals = GlobalVars._instance;      
      // Verificamos que el usuario esté autenticado
      if (!LoginController().isAuthenticated()) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
        // Redirigir al login después de un breve retraso
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        });
        return;
      }
      
      // Obtener datos básicos
      setState(() {
        _nombre = globals.get('persona');
        _email = globals.get('email');
        _fotoUrl = globals.get('foto');
        
        // Obtener datos del perfil activo
        Perfile? perfilActivo = globals.get('perfilActivo');
        if (perfilActivo != null) {
          _carrera = perfilActivo.carrera;
        }
        
        // Obtener datos del resumen
        Resumen? resumen = globals.get('resumen');
        if (resumen != null) {
          _promedio = resumen.promedio;
          _materiasAprobadas = resumen.materiasaprobadas;
        }
        
        _isLoading = false;
      });
      
      print('Datos cargados: Nombre=$_nombre, Email=$_email, Carrera=$_carrera');
      
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              LoginController().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _buildUserInfoPanel(),
    );
  }

  Widget _buildUserInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _fotoUrl != null && _fotoUrl!.isNotEmpty
                  ? NetworkImage(_fotoUrl!)
                  : null,
              child: _fotoUrl == null || _fotoUrl!.isEmpty
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
          ),
          SizedBox(height: 24),
          _buildInfoTile('Nombre', _nombre ?? 'No disponible'),
          _buildInfoTile('Email', _email ?? 'No disponible'),
          _buildInfoTile('Carrera', _carrera ?? 'No disponible'),
          _buildInfoTile('Promedio', _promedio?.toStringAsFixed(2) ?? 'No disponible'),
          _buildInfoTile('Materias Aprobadas', _materiasAprobadas?.toString() ?? 'No disponible'),
          SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: _cargarDatosUsuario,
              child: Text('Actualizar Datos'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16)),
          Divider(),
        ],
      ),
    );
  }
}