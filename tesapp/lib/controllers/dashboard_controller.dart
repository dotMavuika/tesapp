import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 👇 IMPORTA TU SERVICIO DE NOTIFICACIONES
import '../services/notification_news.dart';

class DashboardController with ChangeNotifier {
  List<NewsItem> _news = [];
  bool _isLoading = false;

  // 👇 FLAG PARA QUE SOLO SE MUESTRE UNA VEZ
  bool _notificationShown = false;

  // ⏱ TIMER PARA COMPROBAR NOTICIAS
  Timer? _newsTimer;
  static const Duration _newsInterval = Duration(hours: 5);

  List<NewsItem> get news => _news;
  bool get isLoading => _isLoading;

  /// ⏱ Inicia el reloj interno (llamar UNA sola vez)
  void startNewsClock() {
    _newsTimer ??= Timer.periodic(_newsInterval, (_) {
      fetchNews();
    });
  }

  /// 🛑 Limpieza (por si algún día destruyes el controller)
  @override
  void dispose() {
    _newsTimer?.cancel();
    _newsTimer = null;
    super.dispose();
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/noticias'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == 'ok' && data['noticias'] is List) {
          _news = (data['noticias'] as List)
              .map((item) => NewsItem.fromJson(item))
              .toList();

          // 🔔 NOTIFICACIÓN (solo una vez por sesión)
          if (_news.isNotEmpty && !_notificationShown) {
            _notificationShown = true;

            final latestNews = _news.first;

            NewsNotificationService.showNewsNotification(
              title: 'Nueva noticia',
              body: latestNews.title,
            );
          }
        } else {
          debugPrint('Formato de respuesta inesperado: $data');
          _news = [];
        }
      } else {
        debugPrint('Error en la respuesta: ${response.statusCode}');
        _news = [];
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      _news = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class NewsItem {
  final String title;
  final String image;
  final String body;
  final int type;

  NewsItem({
    required this.title,
    required this.image,
    required this.body,
    required this.type,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['titular'] ?? 'Sin título',
      image: json['imagen'] ?? '',
      body: json['cuerpo'] ?? '',
      type: json['tipo'] ?? 0,
    );
  }
}
