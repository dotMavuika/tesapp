// lib/model/user_data.dart
class UserData {
  final String? nombre;
  final String? carrera;
  final String? modalidad;
  final String? sesion;
  final String? foto;   // ruta relativa
  final int? genero;    // 1, 2, etc
  final String? result; // "ok"

  UserData({
    this.nombre,
    this.carrera,
    this.modalidad,
    this.sesion,
    this.foto,
    this.genero,
    this.result,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nombre: json['nombre'] as String?,
      carrera: json['carrera'] as String?,
      modalidad: json['modalidad'] as String?,
      sesion: json['sesion'] as String?,
      foto: json['foto'] as String?,
      genero: json['genero'] as int?,
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nombre != null) map['nombre'] = nombre;
    if (carrera != null) map['carrera'] = carrera;
    if (modalidad != null) map['modalidad'] = modalidad;
    if (sesion != null) map['sesion'] = sesion;
    if (foto != null) map['foto'] = foto;
    if (genero != null) map['genero'] = genero;
    if (result != null) map['result'] = result;
    return map;
  }

  bool get hasAcademicInfo =>
      (carrera?.isNotEmpty ?? false) ||
          (modalidad?.isNotEmpty ?? false) ||
          (sesion?.isNotEmpty ?? false);
}
