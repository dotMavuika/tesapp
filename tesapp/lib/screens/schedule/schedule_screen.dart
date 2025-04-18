import 'package:flutter/material.dart';
import '../../controllers/schedule_controller.dart';
import '../../model/schedule_data.dart';
import 'components/loading_indicator.dart';
import 'components/error_message.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleController _scheduleController = ScheduleController();
  bool _isLoading = true;
  String _errorMessage = '';
  List<ScheduleItem> _scheduleItems = [];
  Map<String, List<ScheduleItem>> _scheduleByDay = {};

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _scheduleController.refreshScheduleData();

    if (result['success']) {
      final scheduleData = _scheduleController.getScheduleData();

      if (scheduleData != null) {
        _scheduleItems = scheduleData.horario;

        // Organizar por día
        _scheduleByDay = {};
        for (var item in _scheduleItems) {
          if (!_scheduleByDay.containsKey(item.dia)) {
            _scheduleByDay[item.dia] = [];
          }
          _scheduleByDay[item.dia]!.add(item);
        }

        // Ordenar las clases por hora de inicio para cada día
        _scheduleByDay.forEach((day, items) {
          items.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
        });
      }
    } else {
      _errorMessage = result['message'];
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Horario de Clases'),
        ),
        body: const LoadingIndicator(message: 'Cargando horario...'),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Horario de Clases'),
        ),
        body: ErrorMessage(
          message: _errorMessage,
          onRetry: _loadScheduleData,
        ),
      );
    }

    // Orden de los días
    final List<String> orderedDays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    // Filtramos para mostrar solo los días que tienen clases
    final List<String> daysWithClasses = orderedDays
        .where((day) =>
            _scheduleByDay.containsKey(day) && _scheduleByDay[day]!.isNotEmpty)
        .toList();

    // Si no hay clases, mostrar mensaje
    if (daysWithClasses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Horario de Clases'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadScheduleData,
              tooltip: 'Actualizar horario',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay clases programadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No se encontraron horarios de clase para mostrar',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadScheduleData,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: daysWithClasses.length,
      initialIndex: _getCurrentDayIndex(daysWithClasses),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Horario de Clases'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadScheduleData,
              tooltip: 'Actualizar horario',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: daysWithClasses.map((day) => Tab(text: day)).toList(),
          ),
        ),
        body: TabBarView(
          children: daysWithClasses.map((day) {
            final classes = _scheduleByDay[day] ?? [];

            return RefreshIndicator(
              onRefresh: _loadScheduleData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final scheduleItem = classes[index];

                  // Determinar color de la tarjeta basada en el color de la materia si está disponible
                  Color cardColor = Colors.white;
                  if (scheduleItem.color.isNotEmpty) {
                    try {
                      // Convertir color en hexadecimal a Color
                      final colorHex = scheduleItem.color.replaceFirst('#', '');
                      cardColor = Color(int.parse('FF$colorHex', radix: 16));
                    } catch (e) {
                      // Si hay error al parsear el color, usar el predeterminado
                      cardColor = Colors.white;
                    }
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    color: cardColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: cardColor.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${scheduleItem.horaInicio} - ${scheduleItem.horaFin}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  scheduleItem.aula,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            scheduleItem.materia,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  scheduleItem.profesor,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Obtiene el índice del día actual para posicionar la pestaña inicial
  int _getCurrentDayIndex(List<String> days) {
    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);

    final index = days.indexOf(currentDay);
    // Si no encuentra el día actual o es fin de semana, devolver 0 (primer día)
    return index != -1 ? index : 0;
  }

  /// Convierte el número de día de la semana a nombre
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }
}
