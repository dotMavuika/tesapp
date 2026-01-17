// lib/model/profile_data.dart

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    return v == '1' || v == 'true' || v == 't' || v == 'yes' || v == 'y';
  }
  return false;
}

// -----------------------------
// Modelo Perfile
// -----------------------------
class Perfile {
  final int? idpu;
  final String? carrera;
  final String? opcionregistro;
  final String? nivel;
  final String? sesion;
  final String? carrerarep;
  final double? promedio;
  final String? periodo;
  final int? principal;
  final String? fondocarnet;
  final String? archivador;
  final String? qrimage;
  final int? inscripcionid;
  final String? activo;
  final bool? matriculado;
  final String? logocoordinacion;
  final String? backgroundapp;
  final String? colortextosobrecolor;

  // Campos opcionales para perfiles administrativos
  final List<dynamic>? periodos;
  final String? sede;
  final String? coordinacion;
  final int? administrativoid;
  final int? profesorid;

  Perfile({
    this.idpu,
    this.carrera,
    this.opcionregistro,
    this.nivel,
    this.sesion,
    this.carrerarep,
    this.promedio,
    this.periodo,
    this.principal,
    this.fondocarnet,
    this.archivador,
    this.qrimage,
    this.inscripcionid,
    this.activo,
    this.matriculado,
    this.logocoordinacion,
    this.backgroundapp,
    this.colortextosobrecolor,
    this.periodos,
    this.sede,
    this.coordinacion,
    this.administrativoid,
    this.profesorid,
  });

  factory Perfile.fromJson(Map<String, dynamic> json) {
    return Perfile(
      idpu: json['idpu'] as int?,
      carrera: json['carrera'] as String?,
      opcionregistro: json['opcionregistro'] as String?,
      nivel: json['nivel'] as String?,
      sesion: json['sesion'] as String?,
      carrerarep: json['carrerarep'] as String?,
      promedio: _parseDouble(json['promedio']),
      periodo: json['periodo'] as String?,
      principal: json['principal'] as int?,
      fondocarnet: json['fondocarnet'] as String?,
      archivador: json['archivador'] as String?,
      qrimage: json['qrimage'] as String?,
      inscripcionid: json['inscripcionid'] as int?,
      activo: json['activo'] as String?,
      matriculado: json['matriculado'] != null
          ? _parseBool(json['matriculado'])
          : null,
      logocoordinacion: json['logocoordinacion'] as String?,
      backgroundapp: json['backgroundapp'] as String?,
      colortextosobrecolor: json['colortextosobrecolor'] as String?,
      periodos: json['periodos'] as List<dynamic>?,
      sede: json['sede'] as String?,
      coordinacion: json['coordinacion'] as String?,
      administrativoid: json['administrativoid'] as int?,
      profesorid: json['profesorid'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (idpu != null) map['idpu'] = idpu;
    if (carrera != null) map['carrera'] = carrera;
    if (opcionregistro != null) map['opcionregistro'] = opcionregistro;
    if (nivel != null) map['nivel'] = nivel;
    if (sesion != null) map['sesion'] = sesion;
    if (carrerarep != null) map['carrerarep'] = carrerarep;
    if (promedio != null) map['promedio'] = promedio;
    if (periodo != null) map['periodo'] = periodo;
    if (principal != null) map['principal'] = principal;
    if (fondocarnet != null) map['fondocarnet'] = fondocarnet;
    if (archivador != null) map['archivador'] = archivador;
    if (qrimage != null) map['qrimage'] = qrimage;
    if (inscripcionid != null) map['inscripcionid'] = inscripcionid;
    if (activo != null) map['activo'] = activo;
    if (matriculado != null) map['matriculado'] = matriculado;
    if (logocoordinacion != null) map['logocoordinacion'] = logocoordinacion;
    if (backgroundapp != null) map['backgroundapp'] = backgroundapp;
    if (colortextosobrecolor != null) {
      map['colortextosobrecolor'] = colortextosobrecolor;
    }
    if (periodos != null) map['periodos'] = periodos;
    if (sede != null) map['sede'] = sede;
    if (coordinacion != null) map['coordinacion'] = coordinacion;
    if (administrativoid != null) map['administrativoid'] = administrativoid;
    if (profesorid != null) map['profesorid'] = profesorid;
    return map;
  }

  bool get isStudent =>
      (carrera?.isNotEmpty ?? false) || (carrerarep?.isNotEmpty ?? false);

  bool get isAdministrative =>
      (administrativoid != null && administrativoid! > 0) ||
          (profesorid != null && profesorid! > 0) ||
          (sede?.isNotEmpty ?? false) ||
          (coordinacion?.isNotEmpty ?? false);
}

// -----------------------------
// Modelo Resumen
// -----------------------------
class Resumen {
  final int? idpu;
  final int? materiasaprobadas;
  final double? promedio;
  final int? materiasmalla;
  final double? horaspasantias;
  final int? horaspracticas;
  final int? talleres;
  final int? viajes;
  final double? vinculacion;
  final double? deudavigente;
  final double? deudavencida;
  final String? ultimamatricula;
  final int? graduado;
  final String? fondocarnet;
  final String? qrimage;
  final int? idinscripcion;
  final String? logocoordinacion;
  final String? backgroundapp;
  final String? colortextosobrecolor;

  Resumen({
    this.idpu,
    this.materiasaprobadas,
    this.promedio,
    this.materiasmalla,
    this.horaspasantias,
    this.horaspracticas,
    this.talleres,
    this.viajes,
    this.vinculacion,
    this.deudavigente,
    this.deudavencida,
    this.ultimamatricula,
    this.graduado,
    this.fondocarnet,
    this.qrimage,
    this.idinscripcion,
    this.logocoordinacion,
    this.backgroundapp,
    this.colortextosobrecolor,
  });

  factory Resumen.fromJson(Map<String, dynamic> json) {
    return Resumen(
      idpu: json['idpu'] as int?,
      materiasaprobadas: json['materiasaprobadas'] as int?,
      promedio: _parseDouble(json['promedio']),
      materiasmalla: json['materiasmalla'] as int?,
      horaspasantias: _parseDouble(json['horaspasantias']),
      horaspracticas: json['horaspracticas'] as int?,
      talleres: json['talleres'] as int?,
      viajes: json['viajes'] as int?,
      vinculacion: _parseDouble(json['vinculacion']),
      deudavigente: _parseDouble(json['deudavigente']),
      deudavencida: _parseDouble(json['deudavencida']),
      ultimamatricula: json['ultimamatricula'] as String?,
      graduado: json['graduado'] as int?,
      fondocarnet: json['fondocarnet'] as String?,
      qrimage: json['qrimage'] as String?,
      idinscripcion: json['idinscripcion'] as int?,
      logocoordinacion: json['logocoordinacion'] as String?,
      backgroundapp: json['backgroundapp'] as String?,
      colortextosobrecolor: json['colortextosobrecolor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (idpu != null) map['idpu'] = idpu;
    if (materiasaprobadas != null) map['materiasaprobadas'] = materiasaprobadas;
    if (promedio != null) map['promedio'] = promedio;
    if (materiasmalla != null) map['materiasmalla'] = materiasmalla;
    if (horaspasantias != null) map['horaspasantias'] = horaspasantias;
    if (horaspracticas != null) map['horaspracticas'] = horaspracticas;
    if (talleres != null) map['talleres'] = talleres;
    if (viajes != null) map['viajes'] = viajes;
    if (vinculacion != null) map['vinculacion'] = vinculacion;
    if (deudavigente != null) map['deudavigente'] = deudavigente;
    if (deudavencida != null) map['deudavencida'] = deudavencida;
    if (ultimamatricula != null) map['ultimamatricula'] = ultimamatricula;
    if (graduado != null) map['graduado'] = graduado;
    if (fondocarnet != null) map['fondocarnet'] = fondocarnet;
    if (qrimage != null) map['qrimage'] = qrimage;
    if (idinscripcion != null) map['idinscripcion'] = idinscripcion;
    if (logocoordinacion != null) map['logocoordinacion'] = logocoordinacion;
    if (backgroundapp != null) map['backgroundapp'] = backgroundapp;
    if (colortextosobrecolor != null) {
      map['colortextosobrecolor'] = colortextosobrecolor;
    }
    return map;
  }
}

// ------------------------------------
// Modelo ProfileDataStudent
// ------------------------------------
class ProfileDataStudent {
  final String? auth;
  final int? perfilactivoid;
  final String? persona;
  final String? genero;
  final String? email;
  final String? foto;
  final List<Perfile>? perfiles;
  final Resumen? resumen;
  final String? usuario;
  final String? urlradio;
  final String? identificacion;
  final String? nacimiento;
  final String? backgroundapp;
  final String? colortextosobrecolor;
  final String? result;

  ProfileDataStudent({
    this.auth,
    this.perfilactivoid,
    this.persona,
    this.genero,
    this.email,
    this.foto,
    this.perfiles,
    this.resumen,
    this.usuario,
    this.urlradio,
    this.identificacion,
    this.nacimiento,
    this.backgroundapp,
    this.colortextosobrecolor,
    this.result,
  });

  factory ProfileDataStudent.fromJson(Map<String, dynamic> json) {
    return ProfileDataStudent(
      auth: json['auth'] as String?,
      perfilactivoid: json['perfilactivoid'] as int?,
      persona: json['persona'] as String?,
      genero: json['genero'] as String?,
      email: json['email'] as String?,
      foto: json['foto'] as String?,
      perfiles: json['perfiles'] != null
          ? (json['perfiles'] as List<dynamic>)
          .map((e) => Perfile.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      resumen: json['resumen'] != null
          ? Resumen.fromJson(json['resumen'] as Map<String, dynamic>)
          : null,
      usuario: json['usuario'] as String?,
      urlradio: json['urlradio'] as String?,
      identificacion: json['identificacion'] as String?,
      nacimiento: json['nacimiento'] as String?,
      backgroundapp: json['backgroundapp'] as String?,
      colortextosobrecolor: json['colortextosobrecolor'] as String?,
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (auth != null) map['auth'] = auth;
    if (perfilactivoid != null) map['perfilactivoid'] = perfilactivoid;
    if (persona != null) map['persona'] = persona;
    if (genero != null) map['genero'] = genero;
    if (email != null) map['email'] = email;
    if (foto != null) map['foto'] = foto;
    if (perfiles != null) {
      map['perfiles'] = perfiles!.map((e) => e.toJson()).toList();
    }
    if (resumen != null) map['resumen'] = resumen!.toJson();
    if (usuario != null) map['usuario'] = usuario;
    if (urlradio != null) map['urlradio'] = urlradio;
    if (identificacion != null) map['identificacion'] = identificacion;
    if (nacimiento != null) map['nacimiento'] = nacimiento;
    if (backgroundapp != null) map['backgroundapp'] = backgroundapp;
    if (colortextosobrecolor != null) {
      map['colortextosobrecolor'] = colortextosobrecolor;
    }
    if (result != null) map['result'] = result;
    return map;
  }

  /// Perfil activo: usa `principal == 1`; si no hay, devuelve el primero.
  Perfile? get perfilActivo {
    final list = perfiles;
    if (list == null || list.isEmpty) return null;
    try {
      return list.firstWhere((p) => p.principal == 1);
    } catch (_) {
      return list.first;
    }
  }
}
