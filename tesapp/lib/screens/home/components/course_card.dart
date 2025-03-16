import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../controllers/dashboard_controller.dart';

class CourseCard extends StatelessWidget {
  final NewsItem newsItem;

  const CourseCard({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePopup(context, newsItem.image),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        height: 280,
        width: 260,
        decoration: BoxDecoration(
          color: _getColorByType(newsItem.type),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            // Este es el contenedor de la imagen principal (miniatura)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildImageWidget(newsItem.image),
              ),
            ),
            if (newsItem.body.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                newsItem.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _fetchImage(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Referer': 'https://tesa.academicok.com/',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print("Error loading image: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _fetchImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        }

        // Usando Container con color de fondo y la imagen con BoxFit.contain
        // para mantener la proporción sin recortar mientras se ven los bordes redondeados
        return Container(
          color: const Color.fromARGB(255, 255, 255, 255), // Color de fondo para que se vean los bordes
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
    );
  }

  // Método para mostrar la imagen en un popup cuando se toca la tarjeta
  void _showImagePopup(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera del popup con título y botón de cerrar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        newsItem.title.length > 25 
                            ? '${newsItem.title.substring(0, 25)}...' 
                            : newsItem.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                // Contenedor para la imagen ampliada con capacidad de zoom
                // No necesita bordes redondeados como la miniatura
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<Uint8List?>(
                      future: _fetchImage(imageUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || snapshot.data == null) {
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                            ),
                          );
                        }

                        // Usar InteractiveViewer para permitir zoom y paneos
                        return InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Botón de descargar o compartir (opcional)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Compartir"),
                    onPressed: () {
                      // Aquí se podría implementar la función para compartir
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compartiendo imagen...')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorByType(int type) {
    switch (type) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.red;
      default:
        return Colors.blueAccent;
    }
  }
}