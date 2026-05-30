import 'dart:math';
import 'package:flutter/material.dart';
import '../models/show_entry.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import '../services/tmdb_service.dart';

class ShowProvider extends ChangeNotifier {
  final List<ShowEntry> _shows = [];
  final List<HistoryEntry> _history = [];
  final List<TmdbAlert> _alerts = [];
  bool _loaded = false;
  String _lang = 'cs';
  String _firstDay = 'monday'; // 'monday' or 'sunday'

  bool get isLoaded => _loaded;
  String get lang => _lang;
  String get firstDay => _firstDay;
  bool get weekStartsOnSunday => _firstDay == 'sunday';
  List<ShowEntry> get shows => List.unmodifiable(_shows);
  List<HistoryEntry> get history => List.unmodifiable(_history);

  /// Active (non-dismissed) TMDB alerts
  List<TmdbAlert> get activeAlerts => _alerts.where((a) => !a.dismissed).toList();

  List<ShowEntry> showsForDay(int dayOfWeek) =>
      _shows.where((s) => s.dayOfWeek == dayOfWeek).toList();

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> load() async {
    final saved = await StorageService.loadShows();
    final hist = await StorageService.loadHistory();
    final alerts = await StorageService.loadAlerts();
    _lang = await StorageService.loadLanguage();
    _firstDay = await StorageService.loadFirstDay();

    _shows..clear()..addAll(saved);
    _history..clear()..addAll(hist);
    _alerts..clear()..addAll(alerts);
    _loaded = true;
    notifyListeners();

    _maybeCheckTmdb();
  }

  // ── Language ───────────────────────────────────────────────────────────────
  Future<void> setLanguage(String lang) async {
    _lang = lang;
    await StorageService.saveLanguage(lang);
    notifyListeners();
  }

  // ── First day of week ──────────────────────────────────────────────────────
  Future<void> setFirstDay(String day) async {
    _firstDay = day;
    await StorageService.saveFirstDay(day);
    notifyListeners();
  }

  // ── Shows ──────────────────────────────────────────────────────────────────
  Future<void> addShow(ShowEntry show) async {
    _shows.add(show);
    notifyListeners();
    await StorageService.saveShows(_shows);
  }

  Future<void> updateShow(ShowEntry updated) async {
    final idx = _shows.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _shows[idx] = updated;
      notifyListeners();
      await StorageService.saveShows(_shows);
    }
  }

  Future<void> deleteShow(String id) async {
    _shows.removeWhere((s) => s.id == id);
    notifyListeners();
    await StorageService.saveShows(_shows);
  }

  /// Reorder shows within a day
  Future<void> reorderShows(int dayOfWeek, int oldIndex, int newIndex) async {
    final dayShows = _shows.where((s) => s.dayOfWeek == dayOfWeek).toList();
    if (newIndex > oldIndex) newIndex--;
    final item = dayShows.removeAt(oldIndex);
    dayShows.insert(newIndex, item);

    // Rebuild full list: keep other days intact, replace this day's shows in order
    final otherShows = _shows.where((s) => s.dayOfWeek != dayOfWeek).toList();
    _shows..clear()..addAll(otherShows)..addAll(dayShows);
    notifyListeners();
    await StorageService.saveShows(_shows);
  }

  /// Delete all history entries for a given show title
  Future<void> deleteHistoryGroup(String showTitle) async {
    _history.removeWhere((h) => h.showTitle.toLowerCase() == showTitle.toLowerCase());
    await StorageService.saveHistory(_history);
    notifyListeners();
  }

  /// Marks watched: saves to history, increments episode by +1, keeps checkmark.
  /// Also syncs the new episode number to ALL other entries with the same title.
  /// Checkmark resets at the start of each new week (handled in UI).
  Future<void> toggleWatched(String id) async {
    final idx = _shows.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final show = _shows[idx];

    if (!show.watched) {
      // Mark as watched → add to history + increment episode
      final histEntry = HistoryEntry.fromShow(show);
      _history.add(histEntry);
      // Přičti +1 jen pokud seriál má číslování (season>0 && episode>0)
      final tracked = show.season > 0 && show.episode > 0;
      final newEpisode = tracked ? show.episode + 1 : show.episode;

      _shows[idx] = show.copyWith(watched: true, episode: newEpisode);

      // Sync jen pokud má číslování
      if (tracked) {
        for (int i = 0; i < _shows.length; i++) {
          if (i != idx &&
              _shows[i].title.toLowerCase() == show.title.toLowerCase() &&
              _shows[i].season == show.season) {
            _shows[i] = _shows[i].copyWith(episode: newEpisode);
          }
        }
      }

      await StorageService.saveHistory(_history);
    } else {
      // Unmark (manual undo) – also revert episode on all same-title entries
      final revertEpisode = show.episode - 1;
      _shows[idx] = show.copyWith(watched: false, episode: revertEpisode);

      for (int i = 0; i < _shows.length; i++) {
        if (i != idx &&
            _shows[i].title.toLowerCase() == show.title.toLowerCase() &&
            _shows[i].season == show.season) {
          _shows[i] = _shows[i].copyWith(episode: revertEpisode);
        }
      }
    }

    notifyListeners();
    await StorageService.saveShows(_shows);
  }

  /// Called at app start – resets watched flags if it's a new week (Monday)
  Future<void> resetWatchedIfNewWeek() async {
    final now = DateTime.now();
    // Datum začátku tohoto týdne (pondělí)
    final mondayThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisMonday = DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day);

    // Načti datum posledního resetu
    final lastReset = await StorageService.loadLastWeekReset();

    // Reset provést jen pokud jsme ještě nerestartovali tento týden
    if (lastReset == null || lastReset.isBefore(thisMonday)) {
      bool changed = false;
      for (int i = 0; i < _shows.length; i++) {
        if (_shows[i].watched) {
          _shows[i] = _shows[i].copyWith(watched: false);
          changed = true;
        }
      }
      await StorageService.saveLastWeekReset(thisMonday);
      if (changed) {
        notifyListeners();
        await StorageService.saveShows(_shows);
      }
    }
  }

  // ── TMDB ───────────────────────────────────────────────────────────────────
  Future<void> _maybeCheckTmdb() async {
    final last = await StorageService.loadLastTmdbCheck();
    final now = DateTime.now();
    if (last != null && now.difference(last).inDays < 7) return;

    final newAlerts = await TmdbService.checkForNewSeasons(_history);
    for (final alert in newAlerts) {
      final exists = _alerts.any((a) =>
          a.showTitle == alert.showTitle && a.newSeason == alert.newSeason);
      if (!exists) _alerts.add(alert);
    }
    await StorageService.saveAlerts(_alerts);
    await StorageService.saveLastTmdbCheck(now);
    notifyListeners();
  }

  Future<void> dismissAlert(TmdbAlert alert) async {
    alert.dismissed = true;
    await StorageService.saveAlerts(_alerts);
    notifyListeners();
  }

  // ── Export / Import ────────────────────────────────────────────────────────
  Future<String> exportJson() async {
    return StorageService.exportAll(_shows, _history);
  }

  Future<void> importJson(String json) async {
    final data = await StorageService.importAll(json);
    _shows..clear()..addAll(data['shows'] as List<ShowEntry>);
    _history..clear()..addAll(data['history'] as List<HistoryEntry>);
    await StorageService.saveShows(_shows);
    await StorageService.saveHistory(_history);
    notifyListeners();
  }

  String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}
