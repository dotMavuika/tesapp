import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../controllers/dashboard_controller.dart';

class CourseCard extends StatelessWidget {
  final NewsItem newsItem;

  const CourseCard({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Container(
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

        return Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity);
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
