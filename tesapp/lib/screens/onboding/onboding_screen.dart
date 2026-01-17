import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image;

import 'components/animated_btn.dart';
import 'components/sign_in_dialog.dart';

class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({super.key});

  @override
  State<OnbodingScreen> createState() => _OnbodingScreenState();
}

class _OnbodingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo blanco sólido
          Container(
            color: Colors.white,
          ),

          // Contenido principal
          AnimatedPositioned(
            top: isShowSignInDialog ? -50 : 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 260),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Logo
                    SizedBox(
                      width: 260,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/tesa_main_logo.png',
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Spacer(flex: 2),

                    AnimatedBtn(
                      btnAnimationController: _btnAnimationController,
                      press: () {
                        _btnAnimationController.isActive = true;

                        Future.delayed(
                          const Duration(milliseconds: 800),
                              () async {
                            setState(() {
                              isShowSignInDialog = true;
                            });
                            if (!context.mounted) return;

                            // ✅ Ahora sí podemos usar await
                            final result = await showCustomDialog(
                              context,
                              onValue: (_) {},
                            );

                            // Si el login fue exitoso (result == true), navegar al home
                            if (result == true && context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home',
                                    (route) => false,
                              );
                            } else {
                              // Si no fue exitoso, resetear el estado
                              setState(() {
                                isShowSignInDialog = false;
                              });
                            }
                          },
                        );
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text("Presione el botón para iniciar sesión."),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}