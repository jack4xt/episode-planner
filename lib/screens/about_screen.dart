import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';

const String _kofiUrl = 'https://ko-fi.com/jack4xt';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13131A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFFF2D78), Color(0xFF00CFFF)]).createShader(b),
          child: Text(l.aboutApp,
              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 16),

          // App icon
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset('assets/icon.png', width: 100, height: 100),
          ),
          const SizedBox(height: 16),

          // App name
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFF2D78), Color(0xFF00CFFF)]).createShader(b),
            child: const Text('Episode PLANNER',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 6),

          // Verze – automaticky z build.gradle
          Text(
            _version.isEmpty ? '...' : '${l.version} $_version',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          _Card(child: Text(l.aboutDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6))),
          const SizedBox(height: 16),

          // Ko-fi support
          _Card(child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('☕', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(l.supportDev, style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            Text(l.supportDesc, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, height: 1.5)),
            const SizedBox(height: 16),

            // Ko-fi button
            GestureDetector(
              onTap: () => _openKofi(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF29ABE0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                      color: const Color(0xFF29ABE0).withOpacity(0.4),
                      blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Text('☕', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Ko-fi', style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800, fontSize: 16)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: _kofiUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Odkaz zkopírován',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.white,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
              child: const Text(_kofiUrl,
                  style: TextStyle(color: Color(0xFF29ABE0), fontSize: 11,
                      decoration: TextDecoration.underline)),
            ),
          ])),
          const SizedBox(height: 16),

          // TMDB credit
          _Card(child: Column(children: [
            Text(l.tmdbCredit, style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 8),
            const Text('The Movie Database (TMDb)',
                style: TextStyle(color: Color(0xFF01D277),
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('themoviedb.org',
                style: TextStyle(color: Color(0xFF01D277), fontSize: 12,
                    decoration: TextDecoration.underline)),
          ])),

          const SizedBox(height: 32),
          Text('Episode Planner  •  ${l.version} $_version',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _openKofi(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _kofiUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ko-fi odkaz zkopírován – vlož do prohlížeče',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF13131A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: child,
  );
}
