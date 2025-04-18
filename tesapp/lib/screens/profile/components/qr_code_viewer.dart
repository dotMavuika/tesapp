import 'package:flutter/material.dart';

class QRCodeViewer extends StatelessWidget {
  final String? qrImageUrl;
  final String title;
  
  const QRCodeViewer({
    super.key, 
    required this.qrImageUrl,
    this.title = 'Código QR del Carnet',
  });

  void showQRDialog(BuildContext context) {
    if (qrImageUrl == null || qrImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay código QR disponible')),
      );
      return;
    }

    // Asegurar que la URL tenga el esquema correcto
    String imageUrl = qrImageUrl!;
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://tesa.academicok.com${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
    }

    print('Mostrando QR: $imageUrl');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Indicador de carga mientras se carga la imagen
                      const CircularProgressIndicator(),
                      
                      // Imagen QR
                      Image.network(
                        imageUrl,
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error al cargar QR: $error');
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Error al cargar QR',
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Puedes devolver el botón directamente en el build para usar este widget como botón
    return ElevatedButton.icon(
      icon: const Icon(Icons.qr_code),
      label: const Text('Ver QR del Carnet'),
      onPressed: () => showQRDialog(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  // Método alternativo para usar como IconButton (para AppBar)
  static IconButton asIconButton(BuildContext context, String? qrImageUrl) {
    return IconButton(
      icon: const Icon(Icons.qr_code),
      onPressed: () => QRCodeViewer(qrImageUrl: qrImageUrl).showQRDialog(context),
      tooltip: 'Mostrar QR del Carnet',
    );
  }
}