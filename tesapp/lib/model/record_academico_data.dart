// lib/model/record_academico_data.dart

class RecordAcademicoData {
  final List<SubjectRecord> records;
  final List<PracticaRecord> practicas;
  final VinculacionData? vinculacion;
  final dynamic mecanismotitulacion;
  final String? result;

  RecordAcademicoData({
    required this.records,
    required this.practicas,
    this.vinculacion,
    this.mecanismotitulacion,
    this.result,
  });

  factory RecordAcademicoData.fromJson(Map<String, dynamic> json) {
    return RecordAcademicoData(
      records: (json['records'] as List? ?? [])
          .map((e) => SubjectRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      practicas: (json['practicas'] as List? ?? [])
          .map((e) => PracticaRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      vinculacion: json['vinculacion'] != null
          ? VinculacionData.fromJson(json['vinculacion'])
          : null,
      mecanismotitulacion: json['mecanismotitulacion'],
      result: json['result'] as String?,
    );
  }

  /// 🔹 Necesario para guardar en Hive
  Map<String, dynamic> toJson() {
    return {
      'records': records.map((e) => e.toJson()).toList(),
      'practicas': practicas.map((e) => e.toJson()).toList(),
      'vinculacion': vinculacion?.toJson(),
      'mecanismotitulacion': mecanismotitulacion,
      'result': result,
    };
  }
}

class SubjectRecord {
  final String? asignatura;
  final bool? existeEnMalla;
  final double? nota;
  final double? asistencia;
  final String? fecha;
  final bool? convalidada;
  final bool? homologada;
  final int? nivel;
  final bool? valida;
  final bool? aprobada;

  SubjectRecord({
    this.asignatura,
    this.existeEnMalla,
    this.nota,
    this.asistencia,
    this.fecha,
    this.convalidada,
    this.homologada,
    this.nivel,
    this.valida,
    this.aprobada,
  });

  factory SubjectRecord.fromJson(Map<String, dynamic> json) {
    return SubjectRecord(
      asignatura: json['asignatura'] as String?,
      existeEnMalla: json['existe_en_malla'] as bool?,
      nota: (json['nota'] as num?)?.toDouble(),
      asistencia: (json['asistencia'] as num?)?.toDouble(),
      fecha: json['fecha'] as String?,
      convalidada: json['convalidada'] as bool?,
      homologada: json['homologada'] as bool?,
      nivel: json['nivel'] as int?,
      valida: json['valida'] as bool?,
      aprobada: json['aprobada'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asignatura': asignatura,
      'existe_en_malla': existeEnMalla,
      'nota': nota,
      'asistencia': asistencia,
      'fecha': fecha,
      'convalidada': convalidada,
      'homologada': homologada,
      'nivel': nivel,
      'valida': valida,
      'aprobada': aprobada,
    };
  }
}

class PracticaRecord {
  final String? empresa;
  final double? nota;
  final double? horas;
  final String? fecha;

  PracticaRecord({
    this.empresa,
    this.nota,
    this.horas,
    this.fecha,
  });

  factory PracticaRecord.fromJson(Map<String, dynamic> json) {
    return PracticaRecord(
      empresa: json['empresa'] as String?,
      nota: (json['nota'] as num?)?.toDouble(),
      horas: (json['horas'] as num?)?.toDouble(),
      fecha: json['fecha'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresa': empresa,
      'nota': nota,
      'horas': horas,
      'fecha': fecha,
    };
  }
}

class VinculacionData {
  final List<CumplimientoRecord> cumplimiento;
  final List<dynamic> proyectos;
  final List<dynamic> actvidades;
  final List<dynamic> eventos;

  VinculacionData({
    required this.cumplimiento,
    required this.proyectos,
    required this.actvidades,
    required this.eventos,
  });

  factory VinculacionData.fromJson(Map<String, dynamic> json) {
    return VinculacionData(
      cumplimiento: (json['cumplimiento'] as List? ?? [])
          .map((e) => CumplimientoRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      proyectos: (json['proyectos'] as List? ?? []),
      actvidades: (json['actvidades'] as List? ?? []),
      eventos: (json['eventos'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cumplimiento': cumplimiento.map((e) => e.toJson()).toList(),
      'proyectos': proyectos,
      'actvidades': actvidades,
      'eventos': eventos,
    };
  }
}

class CumplimientoRecord {
  final String? nombre;
  final double? horas;
  final String? fecha;

  CumplimientoRecord({
    this.nombre,
    this.horas,
    this.fecha,
  });

  factory CumplimientoRecord.fromJson(Map<String, dynamic> json) {
    return CumplimientoRecord(
      nombre: json['nombre'] as String?,
      horas: (json['horas'] as num?)?.toDouble(),
      fecha: json['fecha'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'horas': horas,
      'fecha': fecha,
    };
  }
}
