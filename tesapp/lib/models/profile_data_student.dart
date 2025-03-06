// Modelo Perfile
class Perfile {
  final int idpu;
  final String carrera;
  final String opcionregistro;
  final String nivel;
  final String sesion;
  final String carrerarep;
  final double promedio;
  final String periodo;
  final int principal;
  final String fondocarnet;
  final String archivador;
  final String qrimage;
  final int inscripcionid;
  final String activo;
  final bool matriculado;
  final String logocoordinacion;
  final String backgroundapp;
  final String colortextosobrecolor;

  Perfile({
    required this.idpu,
    required this.carrera,
    required this.opcionregistro,
    required this.nivel,
    required this.sesion,
    required this.carrerarep,
    required this.promedio,
    required this.periodo,
    required this.principal,
    required this.fondocarnet,
    required this.archivador,
    required this.qrimage,
    required this.inscripcionid,
    required this.activo,
    required this.matriculado,
    required this.logocoordinacion,
    required this.backgroundapp,
    required this.colortextosobrecolor,
  });

  factory Perfile.fromJson(Map<String, dynamic> json) {
    return Perfile(
      idpu: json['idpu'] as int,
      carrera: json['carrera'] as String,
      opcionregistro: json['opcionregistro'] as String,
      nivel: json['nivel'] as String,
      sesion: json['sesion'] as String,
      carrerarep: json['carrerarep'] as String,
      promedio: json['promedio'] as double,
      periodo: json['periodo'] as String,
      principal: json['principal'] as int,
      fondocarnet: json['fondocarnet'] as String,
      archivador: json['archivador'] as String,
      qrimage: json['qrimage'] as String,
      inscripcionid: json['inscripcionid'] as int,
      activo: json['activo'] as String,
      matriculado: json['matriculado'] as bool,
      logocoordinacion: json['logocoordinacion'] as String,
      backgroundapp: json['backgroundapp'] as String,
      colortextosobrecolor: json['colortextosobrecolor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpu': idpu,
      'carrera': carrera,
      'opcionregistro': opcionregistro,
      'nivel': nivel,
      'sesion': sesion,
      'carrerarep': carrerarep,
      'promedio': promedio,
      'periodo': periodo,
      'principal': principal,
      'fondocarnet': fondocarnet,
      'archivador': archivador,
      'qrimage': qrimage,
      'inscripcionid': inscripcionid,
      'activo': activo,
      'matriculado': matriculado,
      'logocoordinacion': logocoordinacion,
      'backgroundapp': backgroundapp,
      'colortextosobrecolor': colortextosobrecolor,
    };
  }
}

// Modelo Resumen
class Resumen {
  final int idpu;
  final int materiasaprobadas;
  final double promedio;
  final int materiasmalla;
  final double horaspasantias;
  final int horaspracticas;
  final int talleres;
  final int viajes;
  final double vinculacion;
  final double deudavigente;
  final double deudavencida;
  final String ultimamatricula;
  final int graduado;
  final String fondocarnet;
  final String qrimage;
  final int idinscripcion;
  final String logocoordinacion;
  final String backgroundapp;
  final String colortextosobrecolor;

  Resumen({
    required this.idpu,
    required this.materiasaprobadas,
    required this.promedio,
    required this.materiasmalla,
    required this.horaspasantias,
    required this.horaspracticas,
    required this.talleres,
    required this.viajes,
    required this.vinculacion,
    required this.deudavigente,
    required this.deudavencida,
    required this.ultimamatricula,
    required this.graduado,
    required this.fondocarnet,
    required this.qrimage,
    required this.idinscripcion,
    required this.logocoordinacion,
    required this.backgroundapp,
    required this.colortextosobrecolor,
  });

  factory Resumen.fromJson(Map<String, dynamic> json) {
    return Resumen(
      idpu: json['idpu'] as int,
      materiasaprobadas: json['materiasaprobadas'] as int,
      promedio: json['promedio'] as double,
      materiasmalla: json['materiasmalla'] as int,
      horaspasantias: json['horaspasantias'] as double,
      horaspracticas: json['horaspracticas'] as int,
      talleres: json['talleres'] as int,
      viajes: json['viajes'] as int,
      vinculacion: json['vinculacion'] as double,
      deudavigente: json['deudavigente'] as double,
      deudavencida: json['deudavencida'] as double,
      ultimamatricula: json['ultimamatricula'] as String,
      graduado: json['graduado'] as int,
      fondocarnet: json['fondocarnet'] as String,
      qrimage: json['qrimage'] as String,
      idinscripcion: json['idinscripcion'] as int,
      logocoordinacion: json['logocoordinacion'] as String,
      backgroundapp: json['backgroundapp'] as String,
      colortextosobrecolor: json['colortextosobrecolor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpu': idpu,
      'materiasaprobadas': materiasaprobadas,
      'promedio': promedio,
      'materiasmalla': materiasmalla,
      'horaspasantias': horaspasantias,
      'horaspracticas': horaspracticas,
      'talleres': talleres,
      'viajes': viajes,
      'vinculacion': vinculacion,
      'deudavigente': deudavigente,
      'deudavencida': deudavencida,
      'ultimamatricula': ultimamatricula,
      'graduado': graduado,
      'fondocarnet': fondocarnet,
      'qrimage': qrimage,
      'idinscripcion': idinscripcion,
      'logocoordinacion': logocoordinacion,
      'backgroundapp': backgroundapp,
      'colortextosobrecolor': colortextosobrecolor,
    };
  }
}

// Modelo ProfileDataStudent
class ProfileDataStudent {
  final String auth;
  final int perfilactivoid;
  final String persona;
  final String genero;
  final String email;
  final String foto;
  final List<Perfile> perfiles;
  final Resumen resumen;
  final String usuario;
  final String urlradio;
  final String identificacion;
  final String nacimiento;
  final String backgroundapp;
  final String colortextosobrecolor;
  final String result;

  ProfileDataStudent({
    required this.auth,
    required this.perfilactivoid,
    required this.persona,
    required this.genero,
    required this.email,
    required this.foto,
    required this.perfiles,
    required this.resumen,
    required this.usuario,
    required this.urlradio,
    required this.identificacion,
    required this.nacimiento,
    required this.backgroundapp,
    required this.colortextosobrecolor,
    required this.result,
  });

  factory ProfileDataStudent.fromJson(Map<String, dynamic> json) {
    return ProfileDataStudent(
      auth: json['auth'] as String,
      perfilactivoid: json['perfilactivoid'] as int,
      persona: json['persona'] as String,
      genero: json['genero'] as String,
      email: json['email'] as String,
      foto: json['foto'] as String,
      perfiles: (json['perfiles'] as List<dynamic>)
          .map((e) => Perfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumen: Resumen.fromJson(json['resumen'] as Map<String, dynamic>),
      usuario: json['usuario'] as String,
      urlradio: json['urlradio'] as String,
      identificacion: json['identificacion'] as String,
      nacimiento: json['nacimiento'] as String,
      backgroundapp: json['backgroundapp'] as String,
      colortextosobrecolor: json['colortextosobrecolor'] as String,
      result: json['result'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth': auth,
      'perfilactivoid': perfilactivoid,
      'persona': persona,
      'genero': genero,
      'email': email,
      'foto': foto,
      'perfiles': perfiles.map((e) => e.toJson()).toList(),
      'resumen': resumen.toJson(),
      'usuario': usuario,
      'urlradio': urlradio,
      'identificacion': identificacion,
      'nacimiento': nacimiento,
      'backgroundapp': backgroundapp,
      'colortextosobrecolor': colortextosobrecolor,
      'result': result,
    };
  }
}