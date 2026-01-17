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

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  // 👉 NUEVO: para manejar el inicio del gesto horizontal
  double? _dragStartX;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() {});
    });

    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- helpers para el menú ---

  void updateSelectedBtmNav(Menu menu) {
    if (selectedBottonNav != menu) {
      setState(() {
        selectedBottonNav = menu;
      });
    }
  }

  // pequeño helper para no romper si Rive aún no inicializa
  void _setMenuIcon(bool value) {
    try {
      isMenuOpenInput.value = value;
    } catch (_) {
      // Rive aún no está listo, lo ignoramos
    }
  }

  void _openSidebar() {
    _setMenuIcon(false); // false = icono X (sidebar abierto)
    if (_animationController.value == 0) {
      _animationController.forward();
    }
    setState(() {
      isSideBarOpen = true;
    });
  }

  void _closeSidebar() {
    _setMenuIcon(true); // true = hamburguesa (sidebar cerrado)
    if (_animationController.value > 0) {
      _animationController.reverse();
    }
    setState(() {
      isSideBarOpen = false;
    });
  }

  void _toggleSidebar() {
    if (isSideBarOpen) {
      _closeSidebar();
    } else {
      _openSidebar();
    }
  }

  // Método para cambiar la pantalla actual
  void changeScreen(String screenName) {
    setState(() {
      currentScreen = screenName;
      // Cerrar el menú lateral al cambiar de pantalla
      if (isSideBarOpen) {
        _closeSidebar();
      }
    });
  }

  // Método para manejar el logout
  void handleLogout() async {
    // Cerrar el sidebar primero
    if (isSideBarOpen) {
      _closeSidebar();
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

      // Navegar a la pantalla de onboarding limpiando el stack
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

  // Método para obtener la pantalla actual basada en currentScreen
  Widget _getCurrentScreen() {
    switch (currentScreen) {
      case "profile":
        return const GeneralProfile();
      case "finance": // Finanzas
        return const FinanceView();
      case "home":
      default:
        return const HomePage();
    }
  }

  // 🔙 Interceptar el botón físico de back
  Future<bool> _onWillPop() async {
    // Si el sidebar está cerrado, lo abrimos
    if (!isSideBarOpen) {
      _openSidebar();
      return false; // no hacer pop de la ruta
    }

    // Si el sidebar está abierto, lo cerramos
    _closeSidebar();
    return false; // tampoco hacemos pop de la ruta

    // Resultado: nunca haces pop → no puedes volver al login
    // con el botón de back; sólo con "Cerrar sesión".
  }

  // 👉 NUEVO: lógica de gestos horizontales
  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dragStartX == null) return;

    final currentX = details.globalPosition.dx;
    final deltaX = currentX - _dragStartX!;

    // Abrir: desde el borde izquierdo (< 40 px) y arrastrando > 30 px a la derecha
    if (!isSideBarOpen && _dragStartX! < 40 && deltaX > 30) {
      _openSidebar();
    }

    // Cerrar: si está abierto y arrastra > 30 px hacia la izquierda
    if (isSideBarOpen && deltaX < -30) {
      _closeSidebar();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragStartX = null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // comportamiento del back
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF7C3E8E),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Stack(
            children: [
              // Sidebar
              AnimatedPositioned(
                width: 288,
                height: MediaQuery.of(context).size.height,
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                left: isSideBarOpen ? 0 : -288,
                top: 0,
                child: SideBar(
                  onProfileTap: () {
                    changeScreen("profile");
                  },
                  onHomeTap: () {
                    changeScreen("home");
                  },
                  onFinanceTap: () {
                    changeScreen("finance");
                  },
                  onLogoutTap: () {
                    handleLogout();
                  },
                ),
              ),

              // Contenido principal con animación 3D
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(
                    1 * animation.value -
                        30 * (animation.value) * pi / 180,
                  ),
                child: Transform.translate(
                  offset: Offset(animation.value * 265, 0),
                  child: Transform.scale(
                    scale: scalAnimation.value,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(24),
                      ),
                      // 👇 Seguimos usando directamente la pantalla actual
                      child: _getCurrentScreen(),
                    ),
                  ),
                ),
              ),

              // Botón de menú
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                left: isSideBarOpen ? 220 : 0,
                top: 16,
                child: MenuBtn(
                  press: _toggleSidebar,
                  riveOnInit: (artboard) {
                    final controller = StateMachineController.fromArtboard(
                      artboard,
                      "State Machine",
                    );

                    artboard.addController(controller!);

                    isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;

                    // true = hamburguesa (cerrado)
                    isMenuOpenInput.value = true;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
