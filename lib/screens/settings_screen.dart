import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../providers/show_provider.dart';
import '../services/storage_service.dart';
import 'about_screen.dart';

// Helper – bílý snackbar s černým textem
SnackBar _snackbar(String message, {bool isError = false}) => SnackBar(
  content: Text(message,
      style: TextStyle(color: isError ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600)),
  backgroundColor: isError ? const Color(0xFFD32F2F) : Colors.white,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  margin: const EdgeInsets.all(16),
  duration: const Duration(seconds: 3),
);

class SettingsScreen extends StatefulWidget {
  final ShowProvider provider;
  const SettingsScreen({super.key, required this.provider});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tmdbCtrl = TextEditingController();
  bool _tmdbObscure = true;

  @override
  void initState() {
    super.initState();
    StorageService.loadTmdbApiKey().then((key) {
      setState(() => _tmdbCtrl.text = key);
    });
  }

  @override
  void dispose() { _tmdbCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = widget.provider;

    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Row(children: [
          Container(width: 3, height: 20,
              decoration: BoxDecoration(color: const Color(0xFFFF2D78),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(l.settings, style: const TextStyle(color: Color(0xFFFF2D78),
              fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ]),
      ),

      // ── První den týdne ────────────────────────────────────────────────────
      _SectionHeader(l.firstDayOfWeek),
      _SettingsTile(
        icon: Icons.calendar_today,
        title: '📅  ${l.startMonday}',
        trailing: provider.firstDay == 'monday'
            ? const Icon(Icons.check_circle, color: Color(0xFFFF2D78), size: 20) : null,
        onTap: () => provider.setFirstDay('monday').then((_) => setState(() {})),
      ),
      _SettingsTile(
        icon: Icons.calendar_today,
        title: '📅  ${l.startSunday}',
        trailing: provider.firstDay == 'sunday'
            ? const Icon(Icons.check_circle, color: Color(0xFFFF2D78), size: 20) : null,
        onTap: () => provider.setFirstDay('sunday').then((_) => setState(() {})),
      ),

      // ── Jazyk ──────────────────────────────────────────────────────────────
      _SectionHeader(l.language),
      _SettingsTile(
        icon: Icons.language,
        title: '🇨🇿  ${l.czech}',
        trailing: provider.lang == 'cs'
            ? const Icon(Icons.check_circle, color: Color(0xFFFF2D78), size: 20) : null,
        onTap: () => EpisodePlannerApp.of(context)?.setLocale('cs'),
      ),
      _SettingsTile(
        icon: Icons.language,
        title: '🇬🇧  ${l.english}',
        trailing: provider.lang == 'en'
            ? const Icon(Icons.check_circle, color: Color(0xFFFF2D78), size: 20) : null,
        onTap: () => EpisodePlannerApp.of(context)?.setLocale('en'),
      ),

      // ── TMDB API klíč ──────────────────────────────────────────────────────
      _SectionHeader('TMDB'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.key, color: Color(0xFFFF2D78), size: 20),
              const SizedBox(width: 10),
              Text(l.tmdbApiKey, style: const TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(l.tmdbApiKeyDesc,
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12, height: 1.5)),
            const SizedBox(height: 12),
            TextField(
              controller: _tmdbCtrl,
              obscureText: _tmdbObscure,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: l.tmdbApiKeyHint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E1E2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFFF2D78), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(_tmdbObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38, size: 18),
                  onPressed: () => setState(() => _tmdbObscure = !_tmdbObscure),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('themoviedb.org →',
                  style: TextStyle(color: Color(0xFF00CFFF), fontSize: 12,
                      decoration: TextDecoration.underline)),
              Row(children: [
                // Test tlačítko
                GestureDetector(
                  onTap: () => _testTmdbKey(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text('Test', style: TextStyle(
                        color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _saveTmdbKey(context, l),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF2D78), Color(0xFFFF6BA8)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l.save, style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ]),
            ]),
          ]),
        ),
      ),

      // ── Záloha ─────────────────────────────────────────────────────────────
      _SectionHeader('Backup'),
      _SettingsTile(
        icon: Icons.upload_file,
        title: l.exportJson,
        onTap: () => _export(context, l),
      ),
      _SettingsTile(
        icon: Icons.download,
        title: l.importJson,
        onTap: () => _import(context, l),
      ),

      // ── Ko-fi ──────────────────────────────────────────────────────────────
      _SectionHeader('Support'),
      _KofiTile(context: context),

      // ── O aplikaci ─────────────────────────────────────────────────────────
      _SectionHeader(l.aboutApp),
      _SettingsTile(
        icon: Icons.info_outline,
        title: l.aboutApp,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AboutScreen())),
      ),

      const SizedBox(height: 32),
    ]);
  }

  Future<void> _testTmdbKey(BuildContext context) async {
    final key = _tmdbCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          _snackbar('Nejdříve zadej API klíč', isError: true));
      return;
    }
    // Zkusí načíst populární seriál – pokud uspěje, klíč je platný
    try {
      final uri = Uri.parse(
          'https://api.themoviedb.org/3/tv/popular?api_key=$key&page=1');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (context.mounted) {
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              _snackbar('✓ API klíč je platný a funkční'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              _snackbar('✗ Neplatný API klíč (chyba ${res.statusCode})',
                  isError: true));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            _snackbar('✗ Nepodařilo se připojit k TMDB', isError: true));
      }
    }
  }

  Future<void> _saveTmdbKey(BuildContext context, AppLocalizations l) async {
    final key = _tmdbCtrl.text.trim();
    await StorageService.saveTmdbApiKey(key);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          _snackbar(key.isEmpty ? l.tmdbApiKeyEmpty : l.tmdbApiKeySaved));
    }
  }

  Future<void> _export(BuildContext context, AppLocalizations l) async {
    try {
      final json = await widget.provider.exportJson();
      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/episode_planner_backup.json');
        await file.writeAsString(json);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/json')],
          subject: 'Episode Planner záloha',
        );
      } else {
        final dir = await FilePicker.platform.getDirectoryPath();
        if (dir == null) return;
        final file = File('$dir/episode_planner_backup.json');
        await file.writeAsString(json);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              _snackbar('${l.exportSuccess}: ${file.path}'));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            _snackbar('Error: $e', isError: true));
      }
    }
  }

  Future<void> _import(BuildContext context, AppLocalizations l) async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.single.path == null) return;
      final json = await File(result.files.single.path!).readAsString();
      await widget.provider.importJson(json);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(_snackbar(l.importSuccess));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            _snackbar(l.importError, isError: true));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
    child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.4),
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  );
}

class _KofiTile extends StatelessWidget {
  final BuildContext context;
  const _KofiTile({required this.context});

  static const _url = 'https://ko-fi.com/jack4xt';

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: _url));
        ScaffoldMessenger.of(context).showSnackBar(_snackbar(
            'Ko-fi odkaz zkopírován – vlož do prohlížeče'));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF29ABE0).withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF29ABE0).withOpacity(0.3)),
        ),
        child: Row(children: [
          const Text('☕', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Koupit kafe (Ko-fi)', style: TextStyle(color: Colors.white,
                fontSize: 15, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Text('ko-fi.com/jack4xt', style: TextStyle(color: Color(0xFF29ABE0), fontSize: 12)),
          ])),
          Icon(Icons.copy, color: Colors.white.withOpacity(0.3), size: 18),
        ]),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title,
      this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF13131A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFFF2D78), size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 15))),
          trailing ?? Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
        ]),
      ),
    );
  }
}
