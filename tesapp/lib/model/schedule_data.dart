class ScheduleItem {
  final String dia;
  final String materia;
  final String aula;
  final String profesor;
  final String horaInicio;
  final String horaFin;
  final String color;
  final String colorTexto;

  ScheduleItem({
    required this.dia,
    required this.materia,
    required this.aula,
    required this.profesor,
    required this.horaInicio,
    required this.horaFin,
    required this.color,
    required this.colorTexto,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    // Extraer el día de la semana
    final String dia = json['diasemana'] as String? ?? 'Sin día';

    // Extraer la hora de inicio y fin del objeto turno
    String horaInicio = '';
    String horaFin = '';

    if (json['turno'] is Map) {
      final turno = json['turno'] as Map<String, dynamic>;
      horaInicio = turno['inicio'] as String? ?? '';
      horaFin = turno['termina'] as String? ?? '';
    }

    return ScheduleItem(
      dia: dia,
      materia: json['materia'] as String? ?? 'Sin nombre',
      aula: json['aula'] as String? ?? 'Sin aula',
      profesor: json['profesor'] as String? ?? 'Sin profesor',
      horaInicio: horaInicio,
      horaFin: horaFin,
      color: '#3498db', // Color predeterminado azul
      colorTexto: '#FFFFFF', // Color de texto predeterminado blanco
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dia': dia,
      'materia': materia,
      'aula': aula,
      'profesor': profesor,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'color': color,
      'colorTexto': colorTexto,
    };
  }
}

class ScheduleData {
  final List<ScheduleItem> horario;
  final String result;

  ScheduleData({
    required this.horario,
    required this.result,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    // Lista para almacenar todos los items de horario
    List<ScheduleItem> allItems = [];

    try {
      if (json['clases'] is List) {
        final clasesList = json['clases'] as List<dynamic>;

        // Iterar a través de la lista mixta (strings y objetos)
        for (var item in clasesList) {
          // Verificar si es un objeto (clase) y no un string (nombre del día)
          if (item is Map<String, dynamic>) {
            try {
              allItems.add(ScheduleItem.fromJson(item));
            } catch (e) {
              // Continuar con la siguiente clase en lugar de fallar
            }
          }
        }
      }
    } catch (e) {
      // No lanzar excepción, devolver lista vacía
    }

    return ScheduleData(
      horario: allItems,
      result: json['result'] as String? ?? 'error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horario': horario.map((e) => e.toJson()).toList(),
      'result': result,
    };
  }
}
