import 'package:flutter/material.dart';
import '../models/show_entry.dart';

class ShowCard extends StatelessWidget {
  final ShowEntry show;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleWatched;
  final bool showDragHandle;

  const ShowCard({
    super.key,
    required this.show,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleWatched,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final service = show.service;

    return Dismissible(
      key: Key(show.id),
      direction: DismissDirection.endToStart,
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
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: GestureDetector(
        onLongPress: onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: show.watched
                ? show.displayBgColor
                : show.displayBgColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: show.watched
                  ? show.displayColor.withOpacity(0.15)
                  : show.displayColor.withOpacity(0.6),
              width: show.watched ? 1 : 1.5,
            ),
            boxShadow: show.watched
                ? []
                : [
                    // Vnější glow
                    BoxShadow(
                      color: show.displayColor.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                    // Vnitřní jemnější glow
                    BoxShadow(
                      color: show.displayColor.withOpacity(0.15),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Drag handle – pouze pokud je povoleno
                if (showDragHandle) ...[
                  Icon(Icons.drag_handle,
                      color: Colors.white.withOpacity(0.2), size: 20),
                  const SizedBox(width: 8),
                ],
                // Service logo badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: show.displayColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: show.displayColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: _ServiceLogo(service: service),
                ),
                const SizedBox(width: 14),
                // Title + service name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        show.title,
                        style: TextStyle(
                          color: show.watched
                              ? Colors.white38
                              : show.displayColor == const Color(0xFF555555)
                                  ? Colors.white
                                  : show.displayColor == Colors.white
                                      ? Colors.white
                                      : HSLColor.fromColor(show.displayColor)
                                          .withLightness(0.75)
                                          .toColor(),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: show.watched
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        show.serviceDisplayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Episode code
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    show.episodeCode,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Watched checkbox
                GestureDetector(
                  onTap: onToggleWatched,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: show.watched
                          ? const Color(0xFFFF2D78)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: show.watched
                            ? const Color(0xFFFF2D78)
                            : Colors.white24,
                        width: 1.5,
                      ),
                      boxShadow: show.watched
                          ? [BoxShadow(
                              color: const Color(0xFFFF2D78).withOpacity(0.4),
                              blurRadius: 8,
                            )]
                          : [],
                    ),
                    child: show.watched
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                // Edit button
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.25),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceLogo extends StatelessWidget {
  final StreamingService service;
  const _ServiceLogo({required this.service});

  @override
  Widget build(BuildContext context) {
    final asset = service.logoAsset;

    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          ),
        ),
      );
    }

    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Center(
      child: Icon(service.icon, color: service.color, size: 24),
    );
  }
}
