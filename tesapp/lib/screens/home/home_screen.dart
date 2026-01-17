import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesapp/controllers/dashboard_controller.dart';
import 'package:tesapp/screens/home/components/course_card.dart';
import 'package:tesapp/screens/schedule/schedule_screen.dart';
import 'package:tesapp/screens/grades/grades_screen.dart';
import 'package:tesapp/screens/record_academico/record_academico.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final dashboardController =
      Provider.of<DashboardController>(context, listen: false);

      dashboardController.fetchNews();       // carga inicial
      dashboardController.startNewsClock();  // cada 5 horas
    });
  }


  @override
  Widget build(BuildContext context) {
    // Acceder al controlador
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchNews();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Sección de título y botones de acción
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Noticias",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                          color: _primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Botón de actualizar
                          controller.isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(strokeWidth: 2),
                          )
                              : IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: _primaryPurple,
                            ),
                            onPressed: () => controller.fetchNews(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sección de noticias
                _buildNewsSection(controller),

                // Espacio adicional al final
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSection(DashboardController controller) {
    if (controller.isLoading && controller.news.isEmpty) {
      return Column(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                color: _primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildQuickAccessSection(context),
        ],
      );
    }

    if (controller.news.isEmpty) {
      return Column(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No hay noticias disponibles",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: _primaryPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildQuickAccessSection(context),
        ],
      );
    }

    // Mostrar la lista de noticias
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Últimas Noticias",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 280, // Altura fija para el carrusel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.news.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 15,
                  right: index == controller.news.length - 1 ? 20 : 0,
                ),
                child: CourseCard(newsItem: controller.news[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        _buildQuickAccessSection(context),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Accesos Rápidos",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildAccessButton(
                context,
                icon: Icons.schedule,
                label: "Horario",
                color: _primaryYellow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
                  );
                },
              ),
              _buildAccessButton(
                context,
                icon: Icons.school,
                label: "Calificaciones",
                color: _primaryYellow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GradesScreen(),
                    ),
                  );
                },
              ),
              _buildAccessButton(
                context,
                icon: Icons.history_edu,
                label: "Récord\nAcadémico",
                color: _primaryYellow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const RecordAcademicoScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildAccessButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
