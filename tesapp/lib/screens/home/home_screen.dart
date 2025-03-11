import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import 'components/course_card.dart';

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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Noticias",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => controller.fetchNews(),
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
    return SizedBox(
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
    );
  }
}