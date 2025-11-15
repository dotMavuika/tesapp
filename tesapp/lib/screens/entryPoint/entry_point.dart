import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:tesapp/screens/home/home_screen.dart';
import 'package:tesapp/screens/profile/general_profile.dart';
import 'package:tesapp/screens/finance/finance_vew.dart'; // Importar FinanceView
import 'package:tesapp/screens/onboding/onboding_screen.dart';
import 'package:tesapp/controllers/logout_controller.dart';

import '../../model/menu.dart';
import 'components/menu_btn.dart';
import 'components/side_bar.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;
  final LogoutController _logoutController = LogoutController();

  Menu selectedBottonNav = bottomNavItems.first;
  Menu selectedSideMenu = sidebarMenus.first;

  // Identificador para la pantalla actualmente mostrada
  String currentScreen = "home";

  late SMIBool isMenuOpenInput;

  void updateSelectedBtmNav(Menu menu) {
    if (selectedBottonNav != menu) {
      setState(() {
        selectedBottonNav = menu;
      });
    }
  }

  // Método para cambiar la pantalla actual
  void changeScreen(String screenName) {
    print('Cambiando a pantalla: $screenName'); // Debug
    setState(() {
      currentScreen = screenName;
      // Cerrar el menú lateral al cambiar de pantalla
      if (isSideBarOpen) {
        isMenuOpenInput.value =
            true; // ✅ INVERTIDO: Ahora true cierra (hamburguesa)
        _animationController.reverse();
        isSideBarOpen = false;
      }
    });
  }

  // Método para manejar el logout
  void handleLogout() async {
    // Cerrar el sidebar primero
    if (isSideBarOpen) {
      isMenuOpenInput.value =
          true; // ✅ INVERTIDO: Ahora true cierra (hamburguesa)
      _animationController.reverse();
      setState(() {
        isSideBarOpen = false;
      });
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Realizar el proceso de logout
    final result = await _logoutController.logout();

    // Cerrar el diálogo de carga
    if (mounted) {
      Navigator.of(context).pop();

      // Navegar a la pantalla de onboarding
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnbodingScreen()),
        (route) => false,
      );

      // Opcionalmente mostrar mensaje de error si ocurrió alguno
      if (!result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nota: ${result['message']}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Método para obtener la pantalla actual basada en currentScreen
  Widget _getCurrentScreen() {
    print('Pantalla actual: $currentScreen'); // Debug
    switch (currentScreen) {
      case "profile":
        return const GeneralProfile();
      case "finance": // ✅ NUEVA OPCIÓN - Finanzas
        return const FinanceView();
      case "home":
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF7C3E8E),
      body: Stack(
        children: [
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(
              onProfileTap: () {
                print('Tap en Perfil'); // Debug
                changeScreen("profile");
              },
              onHomeTap: () {
                print('Tap en Inicio'); // Debug
                changeScreen("home");
              },
              onFinanceTap: () {
                // ✅ NUEVO CALLBACK - Finanzas
                print('Tap en Finanzas'); // Debug
                changeScreen("finance");
              },
              onLogoutTap: () {
                print('Tap en Logout'); // Debug
                handleLogout();
              },
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                  1 * animation.value - 30 * (animation.value) * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(24),
                  ),
                  child:
                      _getCurrentScreen(), // ← Aquí se muestra FinanceView con animaciones
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 16,
            child: MenuBtn(
              press: () {
                // ✅ INVERTIDO: Ahora false abre (X) y true cierra (hamburguesa)
                isMenuOpenInput.value = !isMenuOpenInput.value;

                if (_animationController.value == 0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                setState(() {
                  isSideBarOpen = !isSideBarOpen;
                });
              },
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine");

                artboard.addController(controller!);

                isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;

                isMenuOpenInput.value = true;
              },
            ),
          ),
        ],
      ),
    );
  }
}
