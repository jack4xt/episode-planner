import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _cs = {
    'appTitle': 'Episode PLANNER',
    'monday': 'PONDĚLÍ', 'tuesday': 'ÚTERÝ', 'wednesday': 'STŘEDA',
    'thursday': 'ČTVRTEK', 'friday': 'PÁTEK', 'saturday': 'SOBOTA', 'sunday': 'NEDĚLE',
    'mon': 'PO', 'tue': 'ÚT', 'wed': 'ST', 'thu': 'ČT', 'fri': 'PÁ', 'sat': 'SO', 'sun': 'NE',
    'noShows': 'Žádné seriály', 'addFirst': 'Přidej první seriál pomocí +',
    'items1': 'položka', 'items2': 'položky', 'itemsN': 'položek',
    'addShow': 'Přidat seriál', 'editShow': 'Upravit seriál',
    'showName': 'Název seriálu', 'showNameHint': 'Např. Breaking Bad',
    'platform': 'Platforma', 'dayOfWeek': 'Den v týdnu',
    'season': 'Sezóna', 'episode': 'Epizoda', 'saveChanges': 'Uložit změny',
    'deleteShow': 'Smazat seriál?', 'deleteConfirm': 'Opravdu chceš smazat',
    'cancel': 'Zrušit', 'delete': 'Smazat', 'history': 'HISTORIE',
    'settings': 'Nastavení', 'language': 'Jazyk', 'czech': 'Čeština', 'english': 'English',
    'exportJson': 'Exportovat zálohu (JSON)', 'importJson': 'Importovat zálohu (JSON)',
    'exportSuccess': 'Záloha exportována', 'importSuccess': 'Záloha importována',
    'importError': 'Chyba při importu souboru',
    'tmdbNewSeason': 'Nová série dostupná:', 'tmdbDismiss': 'Zavřít',
    'other': 'Jiná', 'watchHistory': 'Historie sledování', 'noHistory': 'Žádná historie sledování',
    'week': 'týden', 'noForDay': 'Žádné seriály na',
    'tmdbApiKey': 'TMDB API klíč',
    'firstDayOfWeek': 'První den týdne',
    'startMonday': 'Pondělí',
    'startSunday': 'Neděle',
    'tmdbApiKeyHint': 'Volitelné – pro zjištění nových sérií',
    'tmdbApiKeyDesc': 'Zadej svůj bezplatný API klíč z themoviedb.org. Aplikace jej jednou týdně použije ke kontrole, zda nevyšla nová série seriálu z tvé historie. Není povinné.',
    'tmdbApiKeySaved': 'API klíč uložen',
    'tmdbApiKeyEmpty': 'API klíč byl odstraněn',
    'save': 'Uložit',
    'aboutApp': 'O aplikaci',
    'aboutDesc': 'Episode Planner – přehled seriálů, které sleduješ.\nVytvořeno s ❤️ pro všechny fanoušky seriálů.',
    'supportDev': 'Podpořit autora ☕',
    'supportDesc': 'Pokud tě aplikace baví, můžeš mi koupit kafe přes Ko-fi.',
    'tmdbCredit': 'Data o seriálech poskytuje',
    'version': 'Verze',
  };

  static const _en = {
    'appTitle': 'Episode PLANNER',
    'monday': 'MONDAY', 'tuesday': 'TUESDAY', 'wednesday': 'WEDNESDAY',
    'thursday': 'THURSDAY', 'friday': 'FRIDAY', 'saturday': 'SATURDAY', 'sunday': 'SUNDAY',
    'mon': 'MO', 'tue': 'TU', 'wed': 'WE', 'thu': 'TH', 'fri': 'FR', 'sat': 'SA', 'sun': 'SU',
    'noShows': 'No shows', 'addFirst': 'Add your first show using +',
    'items1': 'item', 'items2': 'items', 'itemsN': 'items',
    'addShow': 'Add show', 'editShow': 'Edit show',
    'showName': 'Show name', 'showNameHint': 'e.g. Breaking Bad',
    'platform': 'Platform', 'dayOfWeek': 'Day of week',
    'season': 'Season', 'episode': 'Episode', 'saveChanges': 'Save changes',
    'deleteShow': 'Delete show?', 'deleteConfirm': 'Do you really want to delete',
    'cancel': 'Cancel', 'delete': 'Delete', 'history': 'HISTORY',
    'settings': 'Settings', 'language': 'Language', 'czech': 'Čeština', 'english': 'English',
    'exportJson': 'Export backup (JSON)', 'importJson': 'Import backup (JSON)',
    'exportSuccess': 'Backup exported', 'importSuccess': 'Backup imported',
    'importError': 'Error importing file',
    'tmdbNewSeason': 'New season available:', 'tmdbDismiss': 'Dismiss',
    'other': 'Other', 'watchHistory': 'Watch history', 'noHistory': 'No watch history yet',
    'week': 'week', 'noForDay': 'No shows on',
    'tmdbApiKey': 'TMDB API key',
    'firstDayOfWeek': 'First day of week',
    'startMonday': 'Monday',
    'startSunday': 'Sunday',
    'tmdbApiKeyHint': 'Optional – to detect new seasons',
    'tmdbApiKeyDesc': 'Enter your free API key from themoviedb.org. The app will use it once a week to check if a new season of a show from your history is available. Not required.',
    'tmdbApiKeySaved': 'API key saved',
    'tmdbApiKeyEmpty': 'API key removed',
    'save': 'Save',
    'aboutApp': 'About',
    'aboutDesc': 'Episode Planner – keep track of the shows you watch.\nMade with ❤️ for all TV show fans.',
    'supportDev': 'Buy me a coffee ☕',
    'supportDesc': 'If you enjoy the app, you can support the developer via Ko-fi.',
    'tmdbCredit': 'Show data provided by',
    'version': 'Version',
  };

  Map<String, String> get _s => locale.languageCode == 'cs' ? _cs : _en;

  String get appTitle => _s['appTitle']!;
  List<String> get dayLabels => [_s['mon']!, _s['tue']!, _s['wed']!, _s['thu']!, _s['fri']!, _s['sat']!, _s['sun']!];
  List<String> get dayNames => [_s['monday']!, _s['tuesday']!, _s['wednesday']!, _s['thursday']!, _s['friday']!, _s['saturday']!, _s['sunday']!];
  String get noShows => _s['noShows']!;
  String get addFirst => _s['addFirst']!;
  String itemsLabel(int count) {
    if (locale.languageCode == 'cs') {
      if (count == 1) return _s['items1']!;
      if (count >= 2 && count <= 4) return _s['items2']!;
      return _s['itemsN']!;
    }
    return count == 1 ? _s['items1']! : _s['itemsN']!;
  }
  String get addShow => _s['addShow']!;
  String get editShow => _s['editShow']!;
  String get showName => _s['showName']!;
  String get showNameHint => _s['showNameHint']!;
  String get platform => _s['platform']!;
  String get dayOfWeek => _s['dayOfWeek']!;
  String get season => _s['season']!;
  String get episode => _s['episode']!;
  String get saveChanges => _s['saveChanges']!;
  String get deleteShow => _s['deleteShow']!;
  String get deleteConfirm => _s['deleteConfirm']!;
  String get cancel => _s['cancel']!;
  String get delete => _s['delete']!;
  String get history => _s['history']!;
  String get settings => _s['settings']!;
  String get language => _s['language']!;
  String get czech => _s['czech']!;
  String get english => _s['english']!;
  String get exportJson => _s['exportJson']!;
  String get importJson => _s['importJson']!;
  String get exportSuccess => _s['exportSuccess']!;
  String get importSuccess => _s['importSuccess']!;
  String get importError => _s['importError']!;
  String get tmdbNewSeason => _s['tmdbNewSeason']!;
  String get tmdbDismiss => _s['tmdbDismiss']!;
  String get other => _s['other']!;
  String get watchHistory => _s['watchHistory']!;
  String get noHistory => _s['noHistory']!;
  String get noForDay => _s['noForDay']!;
  String get firstDayOfWeek => _s['firstDayOfWeek']!;
  String get startMonday => _s['startMonday']!;
  String get startSunday => _s['startSunday']!;
  String get tmdbApiKey => _s['tmdbApiKey']!;
  String get tmdbApiKeyHint => _s['tmdbApiKeyHint']!;
  String get tmdbApiKeyDesc => _s['tmdbApiKeyDesc']!;
  String get tmdbApiKeySaved => _s['tmdbApiKeySaved']!;
  String get tmdbApiKeyEmpty => _s['tmdbApiKeyEmpty']!;
  String get save => _s['save']!;
  String get aboutApp => _s['aboutApp']!;
  String get aboutDesc => _s['aboutDesc']!;
  String get supportDev => _s['supportDev']!;
  String get supportDesc => _s['supportDesc']!;
  String get tmdbCredit => _s['tmdbCredit']!;
  String get version => _s['version']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override bool isSupported(Locale l) => ['cs', 'en'].contains(l.languageCode);
  @override Future<AppLocalizations> load(Locale l) async => AppLocalizations(l);
  @override bool shouldReload(_) => false;
}
