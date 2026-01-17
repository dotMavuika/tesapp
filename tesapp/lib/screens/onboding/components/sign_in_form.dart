// lib/screens/onboding/components/sign_in_form.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;
import 'package:provider/provider.dart';
import 'package:tesapp/controllers/login_controller.dart';
import 'package:tesapp/controllers/auth_controller.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger error;
  late SMITrigger success;
  late SMITrigger reset;
  late SMITrigger confetti;

  // Controladores de texto
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controlador de login
  final LoginController _loginController = LoginController();

  // Checkbox "Guardar sesión"
  bool _rememberSession = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCheckRiveInit(Artboard artboard) {
    StateMachineController? controller =
    StateMachineController.fromArtboard(artboard, 'State Machine 1');

    artboard.addController(controller!);
    error = controller.findInput<bool>('Error') as SMITrigger;
    success = controller.findInput<bool>('Check') as SMITrigger;
    reset = controller.findInput<bool>('Reset') as SMITrigger;
  }

  void _onConfettiRiveInit(Artboard artboard) {
    StateMachineController? controller =
    StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);

    confetti = controller.findInput<bool>("Trigger explosion") as SMITrigger;

    // Si isShowConfetti es true, disparar la animación de confeti inmediatamente
    if (isShowConfetti) {
      confetti.fire();
    }
  }

  Future<void> signIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isShowLoading = true;
    });

    final user = _userController.text;
    final password = _passwordController.text;

    try {
      // 1) Llamar a la API a través del LoginController
      final result = await _loginController.login(
        user,
        password,
        rememberSession: _rememberSession,
      );

      if (result['success'] == true) {
        // 2) Animación de éxito
        success.fire();

        // 3) Esperar a que termine la animación de check (éxito)
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        // 4) Refrescar perfil en segundo plano (no bloqueante)
        try {
          final authController = context.read<AuthController>();
          authController.refreshProfile(); // Sin await para no bloquear
        } catch (e) {
          debugPrint('No se pudo refrescar el perfil tras login: $e');
        }

        // 5) Ocultar la animación de carga
        setState(() {
          isShowLoading = false;
        });

        // 6) Mostrar el confeti
        setState(() {
          isShowConfetti = true;
        });

        // 7) Dar tiempo para que el widget de confeti se inicialice y dispare
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          confetti.fire();
        }

        // 8) Esperar a que se vea bien el confeti antes de navegar
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        // 9) Cerrar el dialog y pasar un indicador de éxito
        Navigator.of(context).pop(true); // Pasamos true para indicar login exitoso

        // La navegación al home se hará desde OnbodingScreen
        // al recibir el resultado del dialog
      } else {
        // ❌ Error de autenticación
        error.fire();

        // Esperar a que termine la animación de error
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        // Ocultar la animación de carga
        setState(() {
          isShowLoading = false;
        });

        reset.fire();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error de autenticación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ❌ Error en conexión/proceso
      error.fire();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        isShowLoading = false;
      });

      reset.fire();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Usuario",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _userController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa tu nombre de usuario";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: SvgPicture.asset(
                          "assets/icons/icon_login.svg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                      ),
                      ),
                  ),
              const Text(
                "Contraseña",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa tu contraseña";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset("assets/icons/password.svg"),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _rememberSession,
                    onChanged: (value) {
                      setState(() {
                        _rememberSession = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      "Guardar sesión en este dispositivo",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: () => signIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3E8E),
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                  icon: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Color(0xFFE6B420),
                  ),
                  label: const Text("Aceptar"),
                ),
              ),
            ],
          ),
        ),
        isShowLoading
            ? CustomPositioned(
          child: RiveAnimation.asset(
            'assets/RiveAssets/check.riv',
            fit: BoxFit.cover,
            onInit: _onCheckRiveInit, // ✅ Esta línea faltaba
          ),
        )
            : const SizedBox(),
        isShowConfetti
            ? CustomPositioned(
          scale: 6,
          child: RiveAnimation.asset(
            "assets/RiveAssets/confetti.riv",
            onInit: _onConfettiRiveInit,
            fit: BoxFit.cover,
          ),
        )
            : const SizedBox(),
      ],
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, this.scale = 1, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 100,
            width: 100,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}