import 'package:flutter/material.dart';
import '../models/history_entry.dart';
import '../l10n/app_localizations.dart';

class TmdbAlertBar extends StatelessWidget {
  final TmdbAlert alert;
  final VoidCallback onDismiss;

  const TmdbAlertBar({super.key, required this.alert, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          blurRadius: 10, spreadRadius: 1,
        )],
      ),
      child: Row(children: [
        const Icon(Icons.new_releases_rounded, color: Colors.black87, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${l.tmdbNewSeason} ${alert.showTitle} – Season ${alert.newSeason}',
            style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13,
            ),
          ),
        ),
        GestureDetector(
          onTap: onDismiss,
          child: const Icon(Icons.close, color: Colors.black54, size: 20),
        ),
      ]),
    );
  }
}
