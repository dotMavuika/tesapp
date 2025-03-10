import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardController with ChangeNotifier {
  List<NewsItem> _news = [];

  List<NewsItem> get news => _news;

  Future<void> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://tesa.academicok.com/apimobile/noticias'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _news = (data['noticias'] as List)
            .map((item) => NewsItem.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
    }
  }
}

class NewsItem {
  final String title;
  final String image;
  final String body;

  NewsItem({required this.title, required this.image, required this.body});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['titular'] ?? 'Sin título',
      image: json['imagen'] ?? '',
      body: json['cuerpo'] ?? '',
    );
  }
}
