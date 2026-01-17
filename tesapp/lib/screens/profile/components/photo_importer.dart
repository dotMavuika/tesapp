import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Controlador para manejar la importación y procesamiento de imágenes
class PhotoImporter {
  // Instancia privada estática para Singleton
  static final PhotoImporter _instance = PhotoImporter._internal();

  // Cache en memoria: url -> bytes
  final Map<String, Uint8List> _memoryCache = {};

  // Constructor factory que devuelve la instancia
  factory PhotoImporter() {
    return _instance;
  }

  // Constructor privado
  PhotoImporter._internal();

  /// Limpia el caché en memoria (por si alguna vez lo necesitas)
  void clearCache() {
    _memoryCache.clear();
  }

  /// Obtiene una imagen con headers específicos.
  ///
  /// Usa caché en memoria para no repetir la descarga
  /// mientras la app esté viva.
  Future<Uint8List?> fetchImageWithHeaders(
      String imageUrl, {
        String? referer,
        bool forceRefresh = false,
      }) async {
    try {
      // Si tenemos la imagen en caché y no se fuerza refresh, devolverla
      if (!forceRefresh && _memoryCache.containsKey(imageUrl)) {
        return _memoryCache[imageUrl];
      }

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
        final bytes = response.bodyBytes;
        // Guardar en caché
        _memoryCache[imageUrl] = bytes;
        return bytes;
      }
      return null;
    } catch (e) {

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
  /// [forceRefresh] Si es true, ignora el caché en memoria y vuelve a descargar
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
    bool forceRefresh = false,
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
      future: fetchImageWithHeaders(
        imageUrl,
        referer: referer,
        forceRefresh: forceRefresh,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !(_memoryCache.containsKey(imageUrl))) {
          // Sólo mostramos el loader si NO tenemos ya la imagen en caché
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
        } else if (_memoryCache.containsKey(imageUrl)) {
          // Por si falla la future pero tenemos caché
          final bytes = _memoryCache[imageUrl]!;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: ClipOval(
              child: Image.memory(
                bytes,
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
