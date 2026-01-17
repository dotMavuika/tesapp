// lib/services/credentials_storage.dart
import 'package:hive_flutter/hive_flutter.dart';

class CredentialsStorage {
  static const _boxName = 'tesapp';
  static const _userKey = 'saved_username';
  static const _passKey = 'saved_password';

  /// Guarda usuario y contraseña (sólo si el usuario marca "Guardar sesión")
  static Future<void> save(String username, String password) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_userKey, username);
    await box.put(_passKey, password);

  }

  /// Devuelve {user, pass} o null si no hay credenciales
  static Future<Map<String, String>?> load() async {
    final box = await Hive.openBox(_boxName);
    final user = box.get(_userKey) as String?;
    final pass = box.get(_passKey) as String?;

    if (user == null || pass == null) return null;
    return {'user': user, 'pass': pass};
  }

  /// Borra las credenciales guardadas
  static Future<void> clear() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_userKey);
    await box.delete(_passKey);

  }
}
