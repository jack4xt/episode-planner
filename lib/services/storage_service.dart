import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/show_entry.dart';
import '../models/history_entry.dart';

class StorageService {
  static const _showsKey = 'episode_planner_shows';
  static const _historyKey = 'episode_planner_history';
  static const _alertsKey = 'episode_planner_alerts';
  static const _langKey = 'episode_planner_lang';
  static const _tmdbCheckKey = 'episode_planner_tmdb_check';
  static const _tmdbApiKeyKey = 'episode_planner_tmdb_api_key';
  static const _weekResetKey = 'episode_planner_week_reset';
  static const _firstDayKey = 'episode_planner_first_day'; // 'monday' or 'sunday'

  // ── First day of week ──────────────────────────────────────────────────────
  static Future<String> loadFirstDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstDayKey) ?? 'monday';
  }

  static Future<void> saveFirstDay(String day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstDayKey, day);
  }

  // ── Week reset ─────────────────────────────────────────────────────────────
  static Future<DateTime?> loadLastWeekReset() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_weekResetKey);
    return s != null ? DateTime.tryParse(s) : null;
  }

  static Future<void> saveLastWeekReset(DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weekResetKey, dt.toIso8601String());
  }

  // ── TMDB API Key ───────────────────────────────────────────────────────────
  static Future<String> loadTmdbApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tmdbApiKeyKey) ?? '';
  }

  static Future<void> saveTmdbApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tmdbApiKeyKey, key);
  }

  // ── Shows ──────────────────────────────────────────────────────────────────
  static Future<List<ShowEntry>> loadShows() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_showsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ShowEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveShows(List<ShowEntry> shows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_showsKey, jsonEncode(shows.map((s) => s.toMap()).toList()));
  }

  // ── History ────────────────────────────────────────────────────────────────
  static Future<List<HistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => HistoryEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveHistory(List<HistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history.map((h) => h.toMap()).toList()));
  }

  // ── TMDB Alerts ────────────────────────────────────────────────────────────
  static Future<List<TmdbAlert>> loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alertsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => TmdbAlert.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveAlerts(List<TmdbAlert> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alertsKey, jsonEncode(alerts.map((a) => a.toMap()).toList()));
  }

  // ── Language ───────────────────────────────────────────────────────────────
  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'cs';
  }

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  // ── TMDB last check ────────────────────────────────────────────────────────
  static Future<DateTime?> loadLastTmdbCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_tmdbCheckKey);
    return s != null ? DateTime.tryParse(s) : null;
  }

  static Future<void> saveLastTmdbCheck(DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tmdbCheckKey, dt.toIso8601String());
  }

  // ── Full export / import ───────────────────────────────────────────────────
  static Future<String> exportAll(List<ShowEntry> shows, List<HistoryEntry> history) async {
    return jsonEncode({
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'shows': shows.map((s) => s.toMap()).toList(),
      'history': history.map((h) => h.toMap()).toList(),
    });
  }

  static Future<Map<String, dynamic>> importAll(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final showsList = (data['shows'] as List)
        .map((e) => ShowEntry.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final historyList = (data['history'] as List? ?? [])
        .map((e) => HistoryEntry.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return {'shows': showsList, 'history': historyList};
  }
}
