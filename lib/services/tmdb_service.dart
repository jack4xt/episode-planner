import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_entry.dart';
import 'storage_service.dart';

const String _base = 'https://api.themoviedb.org/3';

class TmdbService {
  static Future<String> _key() => StorageService.loadTmdbApiKey();

  static Future<int?> searchShow(String title) async {
    final key = await _key();
    if (key.isEmpty) return null;
    try {
      final uri = Uri.parse('$_base/search/tv?api_key=$key&query=${Uri.encodeComponent(title)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final results = data['results'] as List;
      if (results.isEmpty) return null;
      return results.first['id'] as int?;
    } catch (_) { return null; }
  }

  static Future<int?> getSeasonCount(int tmdbId) async {
    final key = await _key();
    if (key.isEmpty) return null;
    try {
      final uri = Uri.parse('$_base/tv/$tmdbId?api_key=$key');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      return data['number_of_seasons'] as int?;
    } catch (_) { return null; }
  }

  static Future<List<TmdbAlert>> checkForNewSeasons(List<HistoryEntry> history) async {
    final key = await _key();
    if (key.isEmpty) return [];

    final Map<String, HistoryEntry> best = {};
    for (final h in history) {
      final k = h.showTitle.toLowerCase();
      if (!best.containsKey(k) || h.season > best[k]!.season) best[k] = h;
    }

    final alerts = <TmdbAlert>[];
    for (final entry in best.values) {
      final tmdbId = entry.tmdbId ?? await searchShow(entry.showTitle);
      if (tmdbId == null) continue;
      entry.tmdbId = tmdbId;
      final seasons = await getSeasonCount(tmdbId);
      if (seasons != null && seasons > entry.season) {
        alerts.add(TmdbAlert(showTitle: entry.showTitle, newSeason: seasons, tmdbId: tmdbId));
      }
    }
    return alerts;
  }
}
