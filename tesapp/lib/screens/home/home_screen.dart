import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive_animation/controllers/dashboard_controller.dart';
import 'package:rive_animation/screens/home/components/course_card.dart';
import 'package:rive_animation/screens/schedule/schedule_screen.dart'; // Importar la pantalla de horarios
import 'package:rive_animation/screens/grades/grades_screen.dart'; // Importar la pantalla de calificaciones

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar noticias cuando se inicia la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DashboardController>(context, listen: false).fetchNews();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Acceder al controlador
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
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
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          // Botón de calificaciones
                          IconButton(
                            icon: const Icon(Icons.school),
                            tooltip: 'Calificaciones',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GradesScreen(),
                                ),
                              );
                            },
                          ),
                          // Botón de horarios
                          IconButton(
                            icon: const Icon(Icons.schedule),
                            tooltip: 'Horario de clases',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScheduleScreen(),
                                ),
                              );
                            },
                          ),
                          // Botón de actualizar
                          controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => controller.fetchNews(),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sección de accesos rápidos
                _buildQuickAccessSection(context),

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
                ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAccessButton(
                context,
                icon: Icons.schedule,
                label: "Horario",
                color: Colors.blue,
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
                icon: Icons.assignment,
                label: "Tareas",
                color: Colors.green,
                onTap: () {
                  // Navegar a la pantalla de tareas cuando esté disponible
                },
              ),
              _buildAccessButton(
                context,
                icon: Icons.school,
                label: "Calificaciones",
                color: Colors.purple,
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
                icon: Icons.calendar_today,
                label: "Calendario",
                color: Colors.orange,
                onTap: () {
                  // Navegar a la pantalla de calendario cuando esté disponible
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
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection(DashboardController controller) {
    if (controller.isLoading && controller.news.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.news.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No hay noticias disponibles",
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
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
      ],
    );
  }
}
