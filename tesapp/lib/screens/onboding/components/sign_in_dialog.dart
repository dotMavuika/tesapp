import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'sign_in_form.dart';

// ✅ Cambio: void → Future<bool?>
Future<bool?> showCustomDialog(BuildContext context, {required ValueChanged onValue}) {
  return showGeneralDialog<bool>(  // ✅ Agregamos el tipo genérico
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (dialogContext, __, ___) {
      // Usamos dialogContext para el MediaQuery dentro del diálogo
      final viewInsets = MediaQuery.of(dialogContext).viewInsets;

      return GestureDetector(
        // Si tocas fuera, se cierra el teclado
        onTap: () => FocusScope.of(dialogContext).unfocus(),
        child: Center(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            // Esto empuja el diálogo hacia arriba cuando aparece el teclado
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: Container(
              height: 525,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 30),
                    blurRadius: 60,
                  ),
                  const BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 30),
                    blurRadius: 60,
                  ),
                ],
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Column(
                      children: [
                        Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Ingrese su usuario y contraseña",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Formulario tal cual
                        SignInForm(),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -48,
                      child: GestureDetector(
                        onTap: () {
                          // Cierra el diálogo devolviendo false (login cancelado)
                          Navigator.of(dialogContext).pop(false);
                        },
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween =
      Tween(begin: const Offset(0, -1), end: Offset.zero);

      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
  ).then((value) {
    onValue(value);  // ✅ Llamamos el callback con el valor
    return value;     // ✅ Devolvemos el valor para el await
  });
}