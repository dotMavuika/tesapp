import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Controlador para manejar la importación y procesamiento de imágenes
class PhotoImporter {
  // Instancia privada estática para Singleton
  static final PhotoImporter _instance = PhotoImporter._internal();

  // Constructor factory que devuelve la instancia
  factory PhotoImporter() {
    return _instance;
  }

  // Constructor privado
  PhotoImporter._internal();

  /// Obtiene una imagen con headers específicos
  /// 
  /// [imageUrl] URL de la imagen a cargar
  /// [referer] URL de referer para la petición
  Future<Uint8List?> fetchImageWithHeaders(String imageUrl, {String? referer}) async {
    try {
      Map<String, String> headers = {};
      
      // Añadir referer si se proporciona
      if (referer != null && referer.isNotEmpty) {
        headers['Referer'] = referer;
      }
      
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('Error al cargar la imagen: $e');
      return null;
    }
  }

  /// Widget para mostrar imagen de perfil circular
  /// 
  /// [imageUrl] URL de la imagen a mostrar
  /// [referer] URL de referer para la petición
  /// [size] Tamaño del widget (ancho y alto)
  /// [borderColor] Color del borde
  /// [borderWidth] Ancho del borde
  /// [placeholderColor] Color del indicador de carga
  /// [backgroundColor] Color de fondo cuando no hay imagen
  /// [iconColor] Color del icono por defecto
  /// [iconSize] Tamaño del icono por defecto
  Widget buildCircularProfileImage({
    required String imageUrl,
    String referer = 'https://tesa.academicok.com/',
    double size = 100,
    Color borderColor = Colors.white,
    double borderWidth = 2,
    Color placeholderColor = Colors.white70,
    Color backgroundColor = Colors.grey,
    Color iconColor = Colors.white,
    double iconSize = 50,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Icon(
          Icons.person,
          size: iconSize,
          color: iconColor,
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: fetchImageWithHeaders(imageUrl, referer: referer),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(placeholderColor),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: ClipOval(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: size,
                height: size,
              ),
            ),
          );
        } else {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Icon(
              Icons.person,
              size: iconSize,
              color: iconColor,
            ),
          );
        }
      },
    );
  }
}