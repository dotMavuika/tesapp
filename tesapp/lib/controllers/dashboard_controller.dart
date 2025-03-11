import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardController with ChangeNotifier {
  List<NewsItem> _news = [];
  bool _isLoading = false;

  List<NewsItem> get news => _news;
  bool get isLoading => _isLoading;

  Future<void> fetchNews() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Solicitud POST sin cuerpo
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/noticias'),
        headers: {
          'Content-Type': 'application/json', // Asegúrate de que el servidor espere JSON
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Verifica que la respuesta tenga el formato esperado
        if (data['result'] == 'ok' && data['noticias'] is List) {
          _news = (data['noticias'] as List)
              .map((item) => NewsItem.fromJson(item))
              .toList();
        } else {
          debugPrint('Formato de respuesta inesperado: $data');
          _news = [];
        }
        
        notifyListeners();
      } else {
        debugPrint('Error en la respuesta: ${response.statusCode}');
        _news = [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      _news = [];
      notifyListeners();
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