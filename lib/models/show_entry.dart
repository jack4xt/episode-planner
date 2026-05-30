import 'package:flutter/material.dart';

enum StreamingService {
  netflix,
  disneyPlus,
  appleTvPlus,
  hboMax,
  primevideo,
  oneplay,
  ivysilani,
  skyshowtime,
  other,
}

extension StreamingServiceExt on StreamingService {
  String get label {
    switch (this) {
      case StreamingService.netflix:
        return 'Netflix';
      case StreamingService.disneyPlus:
        return 'Disney+';
      case StreamingService.appleTvPlus:
        return 'Apple TV+';
      case StreamingService.hboMax:
        return 'Max';
      case StreamingService.primevideo:
        return 'Prime Video';
      case StreamingService.oneplay:
        return 'Oneplay';
      case StreamingService.ivysilani:
        return 'iVysílání';
      case StreamingService.skyshowtime:
        return 'SkyShowtime';
      case StreamingService.other:
        return 'Jiná';
    }
  }

  Color get color {
    switch (this) {
      case StreamingService.netflix:
        return const Color(0xFFE50914);
      case StreamingService.disneyPlus:
        return const Color(0xFF1A78C2);
      case StreamingService.appleTvPlus:
        return const Color(0xFFAAAAAA);
      case StreamingService.hboMax:
        return const Color(0xFF6B2FBB);
      case StreamingService.primevideo:
        return const Color(0xFF00A8E1);
      case StreamingService.oneplay:
        return const Color(0xFFE8C020);
      case StreamingService.ivysilani:
        return const Color(0xFFCCCCCC);
      case StreamingService.skyshowtime:
        return const Color(0xFF00BFFF);
      case StreamingService.other:
        return const Color(0xFF888888);
    }
  }

  Color get bgColor {
    switch (this) {
      case StreamingService.netflix:
        return const Color(0xFF1A0000);
      case StreamingService.disneyPlus:
        return const Color(0xFF001B3A);
      case StreamingService.appleTvPlus:
        return const Color(0xFF1A1A1A);
      case StreamingService.hboMax:
        return const Color(0xFF1A0A2E);
      case StreamingService.primevideo:
        return const Color(0xFF001828);
      case StreamingService.oneplay:
        return const Color(0xFF1A1800);
      case StreamingService.ivysilani:
        return const Color(0xFF1A1A1A);
      case StreamingService.skyshowtime:
        return const Color(0xFF001A2E);
      case StreamingService.other:
        return const Color(0xFF1A1A1A);
    }
  }

  IconData get icon {
    switch (this) {
      case StreamingService.netflix:
        return Icons.live_tv;
      case StreamingService.disneyPlus:
        return Icons.star;
      case StreamingService.appleTvPlus:
        return Icons.apple;
      case StreamingService.hboMax:
        return Icons.movie;
      case StreamingService.primevideo:
        return Icons.local_movies;
      case StreamingService.oneplay:
        return Icons.play_circle;
      case StreamingService.ivysilani:
        return Icons.tv;
      case StreamingService.skyshowtime:
        return Icons.cloud;
      case StreamingService.other:
        return Icons.tv;
    }
  }

  /// Returns the asset path for the logo image, or null if not available.
  String? get logoAsset {
    switch (this) {
      case StreamingService.netflix:
        return 'assets/logos/assets_logos_netflix.png';
      case StreamingService.disneyPlus:
        return 'assets/logos/assets_logos_disney.png';
      case StreamingService.appleTvPlus:
        return 'assets/logos/assets_logos_apple.png';
      case StreamingService.hboMax:
        return 'assets/logos/assets_logos_max.png';
      case StreamingService.primevideo:
        return 'assets/logos/assets_logos_prime.png';
      case StreamingService.oneplay:
        return 'assets/logos/assets_logos_oneplay.png';
      case StreamingService.ivysilani:
        return 'assets/logos/assets_logos_ivysilani.png';
      case StreamingService.skyshowtime:
        return 'assets/logos/assets_logos_skyshow.png';
      case StreamingService.other:
        return null;
    }
  }

  String get storageKey => name;

  static StreamingService fromKey(String key) {
    return StreamingService.values.firstWhere(
      (s) => s.name == key,
      orElse: () => StreamingService.other,
    );
  }
}

class ShowEntry {
  final String id;
  String title;
  StreamingService service;
  String customServiceName;
  Color? customColor;
  int season;
  int episode;
  bool watched;
  int dayOfWeek;

  ShowEntry({
    required this.id,
    required this.title,
    required this.service,
    this.customServiceName = '',
    this.customColor,
    required this.season,
    required this.episode,
    this.watched = false,
    required this.dayOfWeek,
  });

  /// Zobrazovaný název platformy
  String get serviceDisplayName =>
      service == StreamingService.other && customServiceName.isNotEmpty
          ? customServiceName
          : service.label;

  /// Barva platformy (vlastní nebo výchozí)
  Color get displayColor =>
      service == StreamingService.other && customColor != null
          ? customColor!
          : service.color;

  /// Pozadí platformy – vždy tmavé, barva jen jako jemný nádech
  Color get displayBgColor =>
      service == StreamingService.other && customColor != null
          ? Color.fromARGB(
              255,
              (customColor!.red * 0.08).round().clamp(0, 30),
              (customColor!.green * 0.08).round().clamp(0, 30),
              (customColor!.blue * 0.08).round().clamp(0, 30),
            )
          : service.bgColor;

  ShowEntry copyWith({
    String? title,
    StreamingService? service,
    String? customServiceName,
    Color? customColor,
    int? season,
    int? episode,
    bool? watched,
    int? dayOfWeek,
  }) {
    return ShowEntry(
      id: id,
      title: title ?? this.title,
      service: service ?? this.service,
      customServiceName: customServiceName ?? this.customServiceName,
      customColor: customColor ?? this.customColor,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      watched: watched ?? this.watched,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }

  String get episodeCode {
    if (season == 0 && episode == 0) return '–';
    final s = season.toString().padLeft(2, '0');
    final e = episode.toString().padLeft(2, '0');
    return 'S${s}E$e';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'service': service.storageKey,
        'customServiceName': customServiceName,
        'customColor': customColor?.value,
        'season': season,
        'episode': episode,
        'watched': watched,
        'dayOfWeek': dayOfWeek,
      };

  factory ShowEntry.fromMap(Map<String, dynamic> map) => ShowEntry(
        id: map['id'] as String,
        title: map['title'] as String,
        service: StreamingServiceExt.fromKey(map['service'] as String),
        customServiceName: map['customServiceName'] as String? ?? '',
        customColor: map['customColor'] != null
            ? Color(map['customColor'] as int)
            : null,
        season: map['season'] as int,
        episode: map['episode'] as int,
        watched: map['watched'] as bool? ?? false,
        dayOfWeek: map['dayOfWeek'] as int,
      );
}
