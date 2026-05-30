import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/show_provider.dart';
import '../models/history_entry.dart';
import '../models/show_entry.dart';

class HistoryScreen extends StatefulWidget {
  final ShowProvider provider;
  const HistoryScreen({super.key, required this.provider});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Which groups are expanded
  final Set<String> _expanded = {};

  ShowProvider get _provider => widget.provider;

  /// Groups history by show title, sorted by most recently watched
  Map<String, List<HistoryEntry>> _grouped() {
    final map = <String, List<HistoryEntry>>{};
    for (final h in _provider.history.reversed) {
      final key = h.showTitle;
      map.putIfAbsent(key, () => []).add(h);
    }
    return map;
  }

  void _confirmDelete(BuildContext context, String showTitle) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.deleteShow, style: const TextStyle(color: Colors.white)),
        content: Text(
          '${l.deleteConfirm} "$showTitle" z historie?',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _provider.deleteHistoryGroup(showTitle)
                  .then((_) => setState(() {}));
            },
            child: Text(l.delete, style: const TextStyle(color: Color(0xFFFF2D78))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final grouped = _grouped();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Row(children: [
          Container(width: 3, height: 20,
              decoration: BoxDecoration(color: const Color(0xFFFF2D78),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(l.watchHistory, style: const TextStyle(
              color: Color(0xFFFF2D78), fontSize: 16,
              fontWeight: FontWeight.w800, letterSpacing: 2)),
        ]),
      ),
      Expanded(
        child: grouped.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history, size: 64, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(l.noHistory, style: TextStyle(color: Colors.white.withOpacity(0.3))),
            ]))
          : ListView(
              children: grouped.entries.map((entry) {
                final title = entry.key;
                final entries = entry.value;
                final isExpanded = _expanded.contains(title);
                final latest = entries.first;
                final s = latest.season.toString().padLeft(2, '0');
                final e = latest.episode.toString().padLeft(2, '0');

                return _GroupCard(
                  title: title,
                  service: latest.service,
                  episodeCode: 'S${s}E$e',
                  count: entries.length,
                  isExpanded: isExpanded,
                  entries: entries,
                  onToggle: () => setState(() {
                    if (isExpanded) _expanded.remove(title);
                    else _expanded.add(title);
                  }),
                  onDelete: () => _confirmDelete(context, title),
                );
              }).toList(),
            ),
      ),
    ]);
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final StreamingService service;
  final String episodeCode;
  final int count;
  final bool isExpanded;
  final List<HistoryEntry> entries;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.title, required this.service, required this.episodeCode,
    required this.count, required this.isExpanded, required this.entries,
    required this.onToggle, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('history_$title'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFF2D78).withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF2D78), size: 28),
      ),
      child: GestureDetector(
        onLongPress: onDelete,
        child: Column(children: [
          // Group header
          GestureDetector(
            onTap: onToggle,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 5, 16, 0),
              decoration: BoxDecoration(
                color: service.bgColor,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(14),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(14),
                ),
                border: Border.all(color: service.color.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  // Logo
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: service.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: service.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: service.logoAsset != null
                      ? Padding(padding: const EdgeInsets.all(6),
                          child: Image.asset(service.logoAsset!, fit: BoxFit.contain))
                      : Icon(service.icon, color: service.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  // Title + count
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: TextStyle(color: service.color,
                        fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('$count epizod sledováno',
                        style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
                  ])),
                  // Latest episode
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(episodeCode,
                        style: TextStyle(color: Colors.white.withOpacity(0.5),
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  // Expand arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.4), size: 22),
                  ),
                ]),
              ),
            ),
          ),

          // Expanded entries
          if (isExpanded)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 5),
              decoration: BoxDecoration(
                color: service.bgColor.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                border: Border.all(color: service.color.withOpacity(0.1)),
              ),
              child: Column(
                children: entries.map((e) {
                  final sv = e.season.toString().padLeft(2, '0');
                  final ep = e.episode.toString().padLeft(2, '0');
                  final date = '${e.watchedAt.day}.${e.watchedAt.month}.${e.watchedAt.year}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline,
                          color: service.color.withOpacity(0.5), size: 16),
                      const SizedBox(width: 10),
                      Expanded(child: Text(date,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))),
                      Text('S${sv}E$ep',
                          style: TextStyle(color: Colors.white.withOpacity(0.4),
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  );
                }).toList(),
              ),
            ),
        ]),
      ),
    );
  }
}
