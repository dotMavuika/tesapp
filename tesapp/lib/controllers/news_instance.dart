import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/dashboard_controller.dart';
import '../screens/home/components/course_card.dart';

class NewsInstance {
  static final NewsInstance _instance = NewsInstance._internal();
  factory NewsInstance() => _instance;
  NewsInstance._internal();

  List<String> _cachedNewsTitles = [];

  Timer? _timer;
  static const Duration _checkInterval = Duration(hours: 5);

  /// ⏱ Inicia el reloj interno (una sola vez)
  void startClock() {
    _timer ??= Timer.periodic(_checkInterval, (_) {
      // Invalidamos cache para forzar nueva comparación
      _cachedNewsTitles.clear();
    });
  }

  /// 🛑 Limpieza opcional
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Widget getNewsSection(
      BuildContext context,
      DashboardController controller,
      ) {
    // Asegura que el reloj esté activo
    startClock();

    final currentNewsTitles =
    controller.news.map((n) => n.title).toList();

    final hasChanges = _checkForChanges(currentNewsTitles);

    if (hasChanges) {
      _cachedNewsTitles = List.from(currentNewsTitles);
    }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasChanges)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "¡Nuevas noticias disponibles!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.news.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 15,
                  right:
                  index == controller.news.length - 1 ? 20 : 0,
                ),
                child: CourseCard(
                  newsItem: controller.news[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _checkForChanges(List<String> newTitles) {
    if (_cachedNewsTitles.isEmpty) {
      return newTitles.isNotEmpty;
    }

    if (_cachedNewsTitles.length != newTitles.length) {
      return true;
    }

    for (final title in newTitles) {
      if (!_cachedNewsTitles.contains(title)) {
        return true;
      }
    }

    return false;
  }
}
