// lib/model/finance_data.dart
class FinanceData {
  final String result;
  final List<Rubro> rubros;
  final double totalRubros;
  final double totalPagado;
  final double totalAdeudado;

  FinanceData({
    required this.result,
    required this.rubros,
    required this.totalRubros,
    required this.totalPagado,
    required this.totalAdeudado,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) {
    return FinanceData(
      result: json['result'] ?? '',
      rubros: json['rubros'] != null
          ? (json['rubros'] as List)
          .map((item) => Rubro.fromJson(item))
          .toList()
          : [],
      totalRubros: _parseDouble(json['total_rubros']),
      totalPagado: _parseDouble(json['total_pagado']),
      totalAdeudado: _parseDouble(json['total_adeudado']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'rubros': rubros.map((item) => item.toJson()).toList(),
      'total_rubros': totalRubros,
      'total_pagado': totalPagado,
      'total_adeudado': totalAdeudado,
    };
  }

  // ---- Helpers de negocio ----
  List<Rubro> get rubrosPendientes =>
      rubros.where((r) => !r.cancelado).toList();

  List<Rubro> get rubrosCancelados =>
      rubros.where((r) => r.cancelado).toList();

  List<Rubro> get matriculas =>
      rubros.where((r) => r.tipo == 'MATRICULA').toList();

  List<Rubro> get cuotas =>
      rubros.where((r) => r.tipo == 'CUOTA').toList();

  double get porcentajePagado =>
      totalRubros > 0 ? (totalPagado / totalRubros) * 100 : 0;
}

class Rubro {
  final String nombre;
  final String tipo;
  final double valor;
  final double valorPendiente;
  final String fechaVence;
  final bool cancelado;
  final double deuda;

  Rubro({
    required this.nombre,
    required this.tipo,
    required this.valor,
    required this.valorPendiente,
    required this.fechaVence,
    required this.cancelado,
    required this.deuda,
  });

  factory Rubro.fromJson(Map<String, dynamic> json) {
    return Rubro(
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      valor: _parseDouble(json['valor']),
      valorPendiente: _parseDouble(json['valor_pendiente']),
      fechaVence: json['fecha_vence'] ?? '',
      cancelado: _parseBool(json['cancelado']),
      deuda: _parseDouble(json['deuda']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      return v == '1' || v == 'true' || v == 't' || v == 'yes' || v == 'y';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'valor': valor.toString(),
      'valor_pendiente': valorPendiente.toString(),
      'fecha_vence': fechaVence,
      'cancelado': cancelado,
      'deuda': deuda.toString(),
    };
  }

  // Getters útiles
  bool get isPaid => cancelado;
  bool get isPending => !cancelado && deuda > 0;
  String get statusText => cancelado ? 'Pagado' : 'Pendiente';

  DateTime? get parsedDate {
    try {
      final parts = fechaVence.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  bool get isOverdue {
    final date = parsedDate;
    if (date == null || cancelado) return false;
    return date.isBefore(DateTime.now());
  }
}
