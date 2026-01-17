// lib/model/user_panel_data.dart

/// Parser robusto para booleanos que pueden venir como:
/// - bool (true/false)
/// - int (0/1)
/// - String ("0","1","true","false","yes","no"...)
bool _parseBoolPanel(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    return v == '1' || v == 'true' || v == 't' || v == 'yes' || v == 'y';
  }
  return false;
}

class UserPanelProgress {
  final double? creditosMalla;
  final int? materiasMalla;
  final int? materiasAprobadas;
  final double? creditosAprobados;

  UserPanelProgress({
    this.creditosMalla,
    this.materiasMalla,
    this.materiasAprobadas,
    this.creditosAprobados,
  });

  factory UserPanelProgress.fromJson(Map<String, dynamic> json) {
    return UserPanelProgress(
      creditosMalla: (json['creditos_malla'] as num?)?.toDouble(),
      materiasMalla: json['materias_malla'] as int?,
      materiasAprobadas: json['materias_aprobadas'] as int?,
      creditosAprobados: (json['creditos_aprobados'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (creditosMalla != null) map['creditos_malla'] = creditosMalla;
    if (materiasMalla != null) map['materias_malla'] = materiasMalla;
    if (materiasAprobadas != null) {
      map['materias_aprobadas'] = materiasAprobadas;
    }
    if (creditosAprobados != null) {
      map['creditos_aprobados'] = creditosAprobados;
    }
    return map;
  }

  bool get hasData =>
      creditosMalla != null ||
          materiasMalla != null ||
          materiasAprobadas != null ||
          creditosAprobados != null;
}

class UserPanelPeriod {
  final bool? matriculado;
  final String? nombre;
  final String? tipo;
  final String? inicia;  // "25-08-2025"
  final String? termina; // "28-12-2025"

  UserPanelPeriod({
    this.matriculado,
    this.nombre,
    this.tipo,
    this.inicia,
    this.termina,
  });

  factory UserPanelPeriod.fromJson(Map<String, dynamic> json) {
    return UserPanelPeriod(
      matriculado: json['matriculado'] != null
          ? _parseBoolPanel(json['matriculado'])
          : null,
      nombre: json['nombre'] as String?,
      tipo: json['tipo'] as String?,
      inicia: json['inicia'] as String?,
      termina: json['termina'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (matriculado != null) map['matriculado'] = matriculado;
    if (nombre != null) map['nombre'] = nombre;
    if (tipo != null) map['tipo'] = tipo;
    if (inicia != null) map['inicia'] = inicia;
    if (termina != null) map['termina'] = termina;
    return map;
  }

  bool get hasData =>
      matriculado != null ||
          (nombre?.isNotEmpty ?? false) ||
          (tipo?.isNotEmpty ?? false) ||
          (inicia?.isNotEmpty ?? false) ||
          (termina?.isNotEmpty ?? false);
}

class UserPanelData {
  final UserPanelProgress? progreso;
  final UserPanelPeriod? periodo;
  final List<dynamic>? clasesHoy;
  final String? dia;
  final List<dynamic>? deuda;
  final String? pagoPendientes;
  final List<dynamic>? prestamosBiblioteca;
  final String? result;

  UserPanelData({
    this.progreso,
    this.periodo,
    this.clasesHoy,
    this.dia,
    this.deuda,
    this.pagoPendientes,
    this.prestamosBiblioteca,
    this.result,
  });

  factory UserPanelData.fromJson(Map<String, dynamic> json) {
    return UserPanelData(
      progreso: json['progreso'] != null
          ? UserPanelProgress.fromJson(
        json['progreso'] as Map<String, dynamic>,
      )
          : null,
      periodo: json['periodo'] != null
          ? UserPanelPeriod.fromJson(
        json['periodo'] as Map<String, dynamic>,
      )
          : null,
      clasesHoy: json['clases_hoy'] as List<dynamic>?,
      dia: json['dia'] as String?,
      deuda: json['deuda'] as List<dynamic>?,
      pagoPendientes: json['pago_pendientes'] as String?,
      prestamosBiblioteca: json['prestamos_biblioteca'] as List<dynamic>?,
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (progreso != null) map['progreso'] = progreso!.toJson();
    if (periodo != null) map['periodo'] = periodo!.toJson();
    if (clasesHoy != null) map['clases_hoy'] = clasesHoy;
    if (dia != null) map['dia'] = dia;
    if (deuda != null) map['deuda'] = deuda;
    if (pagoPendientes != null) map['pago_pendientes'] = pagoPendientes;
    if (prestamosBiblioteca != null) {
      map['prestamos_biblioteca'] = prestamosBiblioteca;
    }
    if (result != null) map['result'] = result;
    return map;
  }

  bool get hasClasesHoy => (clasesHoy?.isNotEmpty ?? false);
  bool get hasDeuda => (deuda?.isNotEmpty ?? false);
  bool get hasPrestamos => (prestamosBiblioteca?.isNotEmpty ?? false);
}
