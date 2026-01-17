class GradePartial {
  final String name;
  final double grade;

  GradePartial({
    required this.name,
    required this.grade,
  });

  factory GradePartial.fromJson(List<dynamic> json) {
    return GradePartial(
      name: json[0] as String? ?? 'PARCIAL',
      grade: (json[1] is num) ? (json[1] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
    };
  }
}

class SubjectGrade {
  final String materia;
  final List<String> profesores;
  final List<GradePartial> parciales;
  final double notaFinal;
  final String estado;
  final double asistencia;

  SubjectGrade({
    required this.materia,
    required this.profesores,
    required this.parciales,
    required this.notaFinal,
    required this.estado,
    required this.asistencia,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    // Procesar la lista de profesores
    List<String> profesoresList = [];
    if (json['profesores'] is List) {
      profesoresList = (json['profesores'] as List)
          .map((e) => e as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Procesar la lista de parciales
    List<GradePartial> parcialesList = [];
    if (json['parciales'] is List) {
      parcialesList = (json['parciales'] as List)
          .map((e) => e is List
              ? GradePartial.fromJson(e)
              : GradePartial(name: 'PARCIAL', grade: 0.0))
          .toList();
    }

    return SubjectGrade(
      materia: json['materia'] as String? ?? 'Sin nombre',
      profesores: profesoresList,
      parciales: parcialesList,
      notaFinal: (json['notafinal'] is num)
          ? (json['notafinal'] as num).toDouble()
          : 0.0,
      estado: json['estado'] as String? ?? 'DESCONOCIDO',
      asistencia: (json['asistencia'] is num)
          ? (json['asistencia'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materia': materia,
      'profesores': profesores,
      'parciales': parciales.map((e) => e.toJson()).toList(),
      'notaFinal': notaFinal,
      'estado': estado,
      'asistencia': asistencia,
    };
  }

  // Obtener solo el nombre corto de la materia sin los códigos
  String get nombreCorto {
    // Si tiene formato "NOMBRE - [CÓDIGO] - [CÓDIGO]"
    if (materia.contains(' - [')) {
      return materia.split(' - [')[0].trim();
    }
    return materia;
  }

  // Verificar si la materia está aprobada
  bool get isAprobada {
    return estado == 'APROBADO';
  }

  // Verificar si la materia está en curso
  bool get isEnCurso {
    return estado == 'EN CURSO';
  }

  // Obtener el color según el estado
  String get colorEstado {
    switch (estado) {
      case 'APROBADO':
        return '#4CAF50'; // Verde
      case 'EN CURSO':
        return '#2196F3'; // Azul
      case 'REPROBADO':
        return '#F44336'; // Rojo
      default:
        return '#9E9E9E'; // Gris
    }
  }
}

class GradesData {
  final List<SubjectGrade> materias;
  final String result;

  GradesData({
    required this.materias,
    required this.result,
  });

  factory GradesData.fromJson(Map<String, dynamic> json) {
    List<SubjectGrade> materiasList = [];

    try {
      if (json['materiasasignadas'] is List) {
        materiasList = (json['materiasasignadas'] as List)
            .map((e) => e is Map<String, dynamic>
                ? SubjectGrade.fromJson(e)
                : SubjectGrade(
                    materia: 'Error',
                    profesores: [],
                    parciales: [],
                    notaFinal: 0.0,
                    estado: 'ERROR',
                    asistencia: 0.0))
            .toList();
      }
    } catch (e) {
    }

    return GradesData(
      materias: materiasList,
      result: json['result'] as String? ?? 'error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materias': materias.map((e) => e.toJson()).toList(),
      'result': result,
    };
  }

  // Calcular promedio general de todas las materias aprobadas
  double get promedioGeneral {
    if (materias.isEmpty) return 0.0;

    final materiasAprobadas = materias.where((m) => m.isAprobada).toList();
    if (materiasAprobadas.isEmpty) return 0.0;

    final suma = materiasAprobadas.fold(
        0.0, (total, materia) => total + materia.notaFinal);
    return suma / materiasAprobadas.length;
  }

  // Obtener materias en curso
  List<SubjectGrade> get materiasEnCurso {
    return materias.where((m) => m.isEnCurso).toList();
  }

  // Obtener materias aprobadas
  List<SubjectGrade> get materiasAprobadas {
    return materias.where((m) => m.isAprobada).toList();
  }
}
