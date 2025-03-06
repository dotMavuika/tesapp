// global_vars.dart
import 'dart:collection';

/// Singleton class para almacenar variables globales en la aplicación
/// Permite guardar valores dinámicos con acceso global
class GlobalVars {
  // Instancia privada estática
  static final GlobalVars _instance = GlobalVars._internal();

  // Constructor factory que devuelve la instancia
  factory GlobalVars() {
    return _instance;
  }

  // Constructor privado
  GlobalVars._internal();

  // Mapa para almacenar los valores
  final Map<String, dynamic> _values = HashMap<String, dynamic>();

  /// Obtiene el valor asociado a la llave
  /// Retorna null si la llave no existe
  dynamic get(String key) {
    return _values[key];
  }

  /// Establece un valor dinámico para una llave específica
  void set(String key, dynamic value) {
    _values[key] = value;
  }

  /// Verifica si una llave existe
  bool has(String key) {
    return _values.containsKey(key);
  }

  /// Elimina una llave y su valor asociado
  void remove(String key) {
    _values.remove(key);
  }

  /// Limpia todas las variables almacenadas
  void clear() {
    _values.clear();
  }

  /// Obtiene todas las llaves almacenadas
  Set<String> get keys => _values.keys.toSet();

  /// Obtiene el número de variables almacenadas
  int get count => _values.length;

  /// Devuelve una copia del mapa de valores
  Map<String, dynamic> getAll() {
    return Map<String, dynamic>.from(_values);
  }
}