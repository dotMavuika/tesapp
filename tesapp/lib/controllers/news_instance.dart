import 'package:flutter/material.dart';
import '../controllers/dashboard_controller.dart';
import '../screens/home/components/course_card.dart';

class NewsInstance {
  // Singleton pattern
  static final NewsInstance _instance = NewsInstance._internal();
  
  // Cache de noticias para comparación
  List<String> _cachedNewsTitles = [];
  
  factory NewsInstance() {
    return _instance;
  }
  
  NewsInstance._internal();
  
  // Método para obtener widgets de noticias y verificar cambios
  Widget getNewsSection(BuildContext context, DashboardController controller) {
    // Verificar si hay nuevas noticias o cambios
    List<String> currentNewsTitles = controller.news.map((item) => item.title).toList();
    bool hasChanges = _checkForChanges(currentNewsTitles);
    
    // Si hay cambios, actualizar el caché
    if (hasChanges) {
      _cachedNewsTitles = List.from(currentNewsTitles);
    }
    
    // Si no hay noticias, mostrar mensaje informativo
    if (controller.news.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: controller.isLoading
              ? const CircularProgressIndicator()
              : const Text(
                  "No hay noticias disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
      );
    }
    
    // Mostrar las noticias en un scroll horizontal
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicador de nuevas noticias si hay cambios
        if (hasChanges && controller.news.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "¡Nuevas noticias disponibles!",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        
        // Lista horizontal de noticias
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
  
  // Método para verificar si hay cambios en los títulos de las noticias
  bool _checkForChanges(List<String> newTitles) {
    // Si no hay noticias en caché, es la primera carga
    if (_cachedNewsTitles.isEmpty) {
      return newTitles.isNotEmpty;
    }
    
    // Si el tamaño es diferente, definitivamente hay cambios
    if (_cachedNewsTitles.length != newTitles.length) {
      return true;
    }
    
    // Verificar si algún título ha cambiado
    for (final title in newTitles) {
      if (!_cachedNewsTitles.contains(title)) {
        return true;
      }
    }
    
    return false;
  }
}