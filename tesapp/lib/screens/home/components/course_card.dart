import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // Imagen miniatura
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

  // =========================
  // 🔹 SHARE NEWS (IMAGEN + TEXTO)
  // =========================
  Future<void> _shareNews(BuildContext context) async {
    try {
      final imageBytes = await _fetchImage(newsItem.image);

      final text = '''
📢 ${newsItem.title}

${newsItem.body}

📱 Compartido desde la app institucional
''';

      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/news_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: text,
          subject: newsItem.title,
        );
      } else {
        // Fallback: solo texto
        await Share.share(
          text,
          subject: newsItem.title,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo compartir la noticia'),
        ),
      );
    }
  }

  // =========================
  // 🔹 FETCH IMAGE
  // =========================
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
      }
    } catch (_) {}
    return null;
  }

  // =========================
  // 🔹 IMAGE WIDGET
  // =========================
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

        return Container(
          color: Colors.white,
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

  // =========================
  // 🔹 IMAGE POPUP
  // =========================
  void _showImagePopup(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) {
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
                // Header
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

                // Imagen ampliada
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<Uint8List?>(
                      future: _fetchImage(imageUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError || snapshot.data == null) {
                          return Container(
                            height: 300,
                            color: Colors.white,
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                            ),
                          );
                        }

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

                // Botón compartir
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Compartir"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _shareNews(context);
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

  // =========================
  // 🔹 COLOR BY TYPE
  // =========================
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
