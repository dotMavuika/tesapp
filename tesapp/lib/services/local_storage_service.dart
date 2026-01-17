// lib/services/local_storage_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/profile_data.dart';
import '../model/user_data.dart';
import '../model/user_panel_data.dart';
import '../model/schedule_data.dart';
import '../model/grades_data.dart';
import '../model/finance_data.dart';
import '../model/record_academico_data.dart';

class LocalStorageService {
  LocalStorageService._internal();
  static final LocalStorageService _instance = LocalStorageService._internal();
  static LocalStorageService get instance => _instance;

  Box<dynamic>? _box;

  // Keys
  static const String _kAuthToken = 'authToken';
  static const String _kSessionCookie = 'sessionCookie';
  static const String _kIsLoggedIn = 'isLoggedIn';

  static const String _kProfileData = 'profileData';
  static const String _kUserData = 'userData';
  static const String _kUserPanelData = 'userPanelData';
  static const String _kScheduleData = 'scheduleData';
  static const String _kGradesData = 'gradesData';
  static const String _kFinanceData = 'financeData';
  static const String _kRecordAcademicoData = 'recordAcademicoData';

  // Asegura la box en métodos async
  Future<void> _ensureBox() async {
    _box ??= Hive.box('tesapp');
  }

  // Asegura la box en métodos sync (como _getJsonSync)
  void _ensureBoxSync() {
    _box ??= Hive.box('tesapp');
  }

  // ----------- FLAGS DE SESIÓN -----------

  Future<void> setIsLoggedIn(bool value) async {
    await _ensureBox();
    await _box!.put(_kIsLoggedIn, value);
  }

  Future<bool> getIsLoggedIn() async {
    await _ensureBox();
    return (_box!.get(_kIsLoggedIn) as bool?) ?? false;
  }

  // ----------- AUTH TOKEN & COOKIE -----------

  Future<void> saveAuthToken(String token) async {
    await _ensureBox();
    await _box!.put(_kAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    await _ensureBox();
    return _box!.get(_kAuthToken) as String?;
  }

  Future<void> saveSessionCookie(String cookie) async {
    await _ensureBox();
    await _box!.put(_kSessionCookie, cookie);
  }

  Future<String?> getSessionCookie() async {
    await _ensureBox();
    return _box!.get(_kSessionCookie) as String?;
  }

  // ----------- HELPERS GENÉRICOS JSON -----------

  Future<void> _saveJson(String key, Map<String, dynamic> json) async {
    await _ensureBox();
    final raw = jsonEncode(json);
    await _box!.put(key, raw);
  }

  Map<String, dynamic>? _getJsonSync(String key) {
    try {
      _ensureBoxSync();
    } catch (_) {
      // Si por alguna razón la box no está disponible, devolvemos null sin romper
      return null;
    }

    final raw = _box!.get(key) as String?;
    if (raw == null) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ----------- PROFILE DATA -----------

  Future<void> saveProfileData(ProfileDataStudent data) async {
    await _saveJson(_kProfileData, data.toJson());
  }

  ProfileDataStudent? getProfileDataSync() {
    final json = _getJsonSync(_kProfileData);
    if (json == null) return null;
    return ProfileDataStudent.fromJson(json);
  }

  // ----------- USER DATA -----------

  Future<void> saveUserData(UserData data) async {
    await _saveJson(_kUserData, data.toJson());
  }

  UserData? getUserDataSync() {
    final json = _getJsonSync(_kUserData);
    if (json == null) return null;
    return UserData.fromJson(json);
  }

  // ----------- USER PANEL DATA -----------

  Future<void> saveUserPanelData(UserPanelData data) async {
    await _saveJson(_kUserPanelData, data.toJson());
  }

  UserPanelData? getUserPanelDataSync() {
    final json = _getJsonSync(_kUserPanelData);
    if (json == null) return null;
    return UserPanelData.fromJson(json);
  }

  // ----------- SCHEDULE DATA -----------

  Future<void> saveScheduleData(ScheduleData data) async {
    await _saveJson(_kScheduleData, data.toJson());
  }

  ScheduleData? getScheduleDataSync() {
    final json = _getJsonSync(_kScheduleData);
    if (json == null) return null;
    return ScheduleData.fromJson(json);
  }

  // ----------- GRADES DATA -----------

  Future<void> saveGradesData(GradesData data) async {
    await _saveJson(_kGradesData, data.toJson());
  }

  GradesData? getGradesDataSync() {
    final json = _getJsonSync(_kGradesData);
    if (json == null) return null;
    return GradesData.fromJson(json);
  }

  // ----------- FINANCE DATA -----------

  Future<void> saveFinanceData(FinanceData data) async {
    await _saveJson(_kFinanceData, data.toJson());
  }

  FinanceData? getFinanceDataSync() {
    final json = _getJsonSync(_kFinanceData);
    if (json == null) return null;
    return FinanceData.fromJson(json);
  }

  // ----------- RECORD ACADÉMICO DATA -----------

  Future<void> saveRecordAcademicoData(RecordAcademicoData data) async {
    await _saveJson(_kRecordAcademicoData, data.toJson());
  }

  RecordAcademicoData? getRecordAcademicoDataSync() {
    final json = _getJsonSync(_kRecordAcademicoData);
    if (json == null) return null;
    return RecordAcademicoData.fromJson(json);
  }

  // ----------- LIMPIEZA -----------

  Future<void> clearSessionData() async {
    await _ensureBox();
    await _box!.delete(_kAuthToken);
    await _box!.delete(_kSessionCookie);
    await _box!.delete(_kIsLoggedIn);

    await _box!.delete(_kProfileData);
    await _box!.delete(_kUserData);
    await _box!.delete(_kUserPanelData);
    await _box!.delete(_kScheduleData);
    await _box!.delete(_kGradesData);
    await _box!.delete(_kFinanceData);
    await _box!.delete(_kRecordAcademicoData);
  }
}
