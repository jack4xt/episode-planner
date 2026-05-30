import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/show_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EpisodePlannerApp());
}

class EpisodePlannerApp extends StatefulWidget {
  const EpisodePlannerApp({super.key});

  static _EpisodePlannerAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_EpisodePlannerAppState>();

  @override
  State<EpisodePlannerApp> createState() => _EpisodePlannerAppState();
}

class _EpisodePlannerAppState extends State<EpisodePlannerApp> {
  Locale _locale = const Locale('cs');
  late final ShowProvider provider;

  @override
  void initState() {
    super.initState();
    provider = ShowProvider();
    provider.load().then((_) {
      setState(() {
        _locale = Locale(provider.lang);
      });
      provider.resetWatchedIfNewWeek();
    });
  }

  void setLocale(String lang) {
    setState(() => _locale = Locale(lang));
    provider.setLanguage(lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Episode Planner',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('cs'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2D78),
          secondary: Color(0xFF00CFFF),
          surface: Color(0xFF13131A),
        ),
      ),
      home: HomeScreen(provider: provider),
    );
  }
}
