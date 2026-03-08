import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

/// Local cache using Hive for offline support.
/// TODO: Phase 2 — Add typed Hive adapters for Field and Chemical models.
class CacheService {
  CacheService._();

  static Future<void> init() async {
    await Hive.openBox(AppConstants.fieldsBox);
    await Hive.openBox(AppConstants.chemicalsBox);
    await Hive.openBox(AppConstants.userPrefsBox);
  }

  // ── User prefs ────────────────────────────────────────────────────────────

  static Box get _prefs => Hive.box(AppConstants.userPrefsBox);

  static T? getPref<T>(String key) => _prefs.get(key) as T?;
  static Future<void> setPref<T>(String key, T value) =>
      _prefs.put(key, value);

  // ── Field cache ───────────────────────────────────────────────────────────

  static Box get _fields => Hive.box(AppConstants.fieldsBox);

  /// Cache raw JSON list of fields for a farmer.
  static Future<void> cacheFields(
      String farmerId, List<Map<String, dynamic>> fields) async {
    await _fields.put(farmerId, fields);
  }

  static List<Map<String, dynamic>>? getCachedFields(String farmerId) {
    final raw = _fields.get(farmerId);
    if (raw == null) return null;
    return List<Map<String, dynamic>>.from(raw);
  }

  // ── Chemical cache ────────────────────────────────────────────────────────

  static Box get _chemicals => Hive.box(AppConstants.chemicalsBox);

  static Future<void> cacheChemicals(
      List<Map<String, dynamic>> chemicals) async {
    await _chemicals.put('all', chemicals);
  }

  static List<Map<String, dynamic>>? getCachedChemicals() {
    final raw = _chemicals.get('all');
    if (raw == null) return null;
    return List<Map<String, dynamic>>.from(raw);
  }
}
