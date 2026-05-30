import 'show_entry.dart';

class HistoryEntry {
  final String id;
  final String showTitle;
  final StreamingService service;
  final int season;
  final int episode;
  final DateTime watchedAt;
  int? tmdbId;
  bool tmdbAlertDismissed;

  HistoryEntry({
    required this.id,
    required this.showTitle,
    required this.service,
    required this.season,
    required this.episode,
    required this.watchedAt,
    this.tmdbId,
    this.tmdbAlertDismissed = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'showTitle': showTitle,
        'service': service.storageKey,
        'season': season,
        'episode': episode,
        'watchedAt': watchedAt.toIso8601String(),
        'tmdbId': tmdbId,
        'tmdbAlertDismissed': tmdbAlertDismissed,
      };

  factory HistoryEntry.fromMap(Map<String, dynamic> m) => HistoryEntry(
        id: m['id'] as String,
        showTitle: m['showTitle'] as String,
        service: StreamingServiceExt.fromKey(m['service'] as String),
        season: m['season'] as int,
        episode: m['episode'] as int,
        watchedAt: DateTime.parse(m['watchedAt'] as String),
        tmdbId: m['tmdbId'] as int?,
        tmdbAlertDismissed: m['tmdbAlertDismissed'] as bool? ?? false,
      );

  factory HistoryEntry.fromShow(ShowEntry show) => HistoryEntry(
        id: '${show.id}_${DateTime.now().millisecondsSinceEpoch}',
        showTitle: show.title,
        service: show.service,
        season: show.season,
        episode: show.episode,
        watchedAt: DateTime.now(),
      );
}

class TmdbAlert {
  final String showTitle;
  final int newSeason;
  final int tmdbId;
  bool dismissed;

  TmdbAlert({
    required this.showTitle,
    required this.newSeason,
    required this.tmdbId,
    this.dismissed = false,
  });

  Map<String, dynamic> toMap() => {
        'showTitle': showTitle,
        'newSeason': newSeason,
        'tmdbId': tmdbId,
        'dismissed': dismissed,
      };

  factory TmdbAlert.fromMap(Map<String, dynamic> m) => TmdbAlert(
        showTitle: m['showTitle'] as String,
        newSeason: m['newSeason'] as int,
        tmdbId: m['tmdbId'] as int,
        dismissed: m['dismissed'] as bool? ?? false,
      );
}
