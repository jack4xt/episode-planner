import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/show_entry.dart';
import '../providers/show_provider.dart';

class AddEditShowDialog extends StatefulWidget {
  final ShowProvider provider;
  final int initialDay;
  final ShowEntry? existingShow;
  final Function(ShowEntry) onSave;

  const AddEditShowDialog({super.key, required this.provider,
      required this.initialDay, this.existingShow, required this.onSave});

  @override
  State<AddEditShowDialog> createState() => _AddEditShowDialogState();
}

class _AddEditShowDialogState extends State<AddEditShowDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _customNameCtrl;
  late StreamingService _service;
  late String _customServiceName;
  late Color _customColor;
  late int _season;
  late int _episode;
  late int _day;
  late bool _trackEpisodes;

  // Předvolené barvy pro vlastní platformu
  static const _palette = [
    Color(0xFFFF2D78), Color(0xFF00CFFF), Color(0xFF01D277),
    Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFAA44FF),
    Color(0xFF00BCD4), Color(0xFFFF4444), Color(0xFF888888),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existingShow;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _service = e?.service ?? StreamingService.netflix;
    _customServiceName = e?.customServiceName ?? '';
    _customColor = e?.customColor ?? _palette[0];
    _customNameCtrl = TextEditingController(text: _customServiceName);
    _season = e?.season ?? 1;
    _episode = e?.episode ?? 1;
    _day = e?.dayOfWeek ?? widget.initialDay;
    // Pokud seriál nemá epizody (season=0, episode=0), přepínač je vypnutý
    _trackEpisodes = e == null || (e.season > 0 && e.episode > 0);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    widget.onSave(ShowEntry(
      id: widget.existingShow?.id ?? widget.provider.generateId(),
      title: title, service: _service,
      customServiceName: _customServiceName,
      customColor: _service == StreamingService.other ? _customColor : null,
      season: _trackEpisodes ? _season : 0,
      episode: _trackEpisodes ? _episode : 0,
      dayOfWeek: _day,
      watched: widget.existingShow?.watched ?? false,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEdit = widget.existingShow != null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFF2D78), Color(0xFF00CFFF)]).createShader(b),
            child: Text(isEdit ? l.editShow : l.addShow,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          _label(l.showName),
          const SizedBox(height: 8),
          TextField(controller: _titleCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: _inputDeco(l.showNameHint)),
          const SizedBox(height: 16),
          _label(l.platform),
          const SizedBox(height: 8),
          _ServicePicker(
            selected: _service,
            customName: _customServiceName,
            onChanged: (s) => setState(() {
              _service = s;
              if (s != StreamingService.other) _customServiceName = '';
            }),
            onCustomName: (name) => setState(() => _customServiceName = name),
          ),
          // Zobraz pole pro vlastní název pokud je vybrána "other"
          if (_service == StreamingService.other) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customNameCtrl,
              maxLength: 12,
              onChanged: (v) => setState(() => _customServiceName = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Název platformy (max 12 znaků)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E1E2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFFF2D78), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                counterStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
              ),
            ),
            const SizedBox(height: 8),
            // Výběr barvy
            Text('Barva platformy', style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 12,
                fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _palette.map((color) {
                final isSelected = _customColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _customColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected ? [BoxShadow(
                          color: color.withOpacity(0.6), blurRadius: 8)] : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          _label(l.dayOfWeek),
          const SizedBox(height: 8),
          _DayPicker(selected: _day, labels: l.dayLabels,
              onChanged: (d) => setState(() => _day = d)),
          // Přepínač sledování epizod
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Icon(Icons.format_list_numbered,
                  color: _trackEpisodes
                      ? const Color(0xFFFF2D78)
                      : Colors.white24,
                  size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sledovat epizody', style: TextStyle(
                      color: _trackEpisodes ? Colors.white : Colors.white38,
                      fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Vypni pro přehled bez číslování',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 11)),
                ],
              )),
              Switch(
                value: _trackEpisodes,
                onChanged: (v) => setState(() => _trackEpisodes = v),
                activeColor: const Color(0xFFFF2D78),
                inactiveThumbColor: Colors.white24,
                inactiveTrackColor: Colors.white10,
              ),
            ]),
          ),
          // Sezóna a epizoda – zobrazí se jen když je přepínač zapnutý
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _trackEpisodes
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label(l.season), const SizedBox(height: 8),
                  _NumberStepper(value: _season, min: 1, max: 50,
                      onChanged: (v) => setState(() => _season = v)),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label(l.episode), const SizedBox(height: 8),
                  _NumberStepper(value: _episode, min: 1, max: 200,
                      onChanged: (v) => setState(() => _episode = v)),
                ])),
              ]),
            ),
            secondChild: const SizedBox(height: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: GestureDetector(onTap: _save,
              child: Container(height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF2D78), Color(0xFFFF6BA8)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF2D78).withOpacity(0.4),
                      blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Center(child: Text(isEdit ? l.saveChanges : l.addShow,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: TextStyle(
      color: Colors.white.withOpacity(0.5), fontSize: 12,
      fontWeight: FontWeight.w600, letterSpacing: 0.8));

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
    filled: true, fillColor: const Color(0xFF1E1E2A),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF2D78), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _ServicePicker extends StatelessWidget {
  final StreamingService selected;
  final String customName;
  final Function(StreamingService) onChanged;
  final Function(String) onCustomName;

  const _ServicePicker({
    required this.selected,
    required this.customName,
    required this.onChanged,
    required this.onCustomName,
  });

  @override
  Widget build(BuildContext context) {
    // Všechny služby kromě "other"
    final services = StreamingService.values
        .where((s) => s != StreamingService.other)
        .toList();

    return Wrap(spacing: 8, runSpacing: 8, children: [
      // Normální platformy
      ...services.map((s) {
        final isSel = s == selected;
        final asset = s.logoAsset;
        return GestureDetector(
          onTap: () => onChanged(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 80, height: 52,
            decoration: BoxDecoration(
              color: isSel ? s.color.withOpacity(0.18) : const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSel ? s.color : Colors.white12, width: 1.5),
            ),
            child: asset != null
              ? Padding(padding: const EdgeInsets.all(8),
                  child: Image.asset(asset, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(s.label, style: TextStyle(
                            color: isSel ? s.color : Colors.white38,
                            fontSize: 10, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center))))
              : Center(child: Text(s.label, style: TextStyle(
                  color: isSel ? s.color : Colors.white38,
                  fontSize: 11, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center)),
          ),
        );
      }),

      // "+" tlačítko pro vlastní platformu
      GestureDetector(
        onTap: () => onChanged(StreamingService.other),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80, height: 52,
          decoration: BoxDecoration(
            color: selected == StreamingService.other
                ? const Color(0xFFFF2D78).withOpacity(0.18)
                : const Color(0xFF1E1E2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected == StreamingService.other
                  ? const Color(0xFFFF2D78)
                  : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Center(
            child: selected == StreamingService.other && customName.isNotEmpty
              ? Text(customName,
                  style: const TextStyle(color: Color(0xFFFF2D78),
                      fontSize: 10, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 2, overflow: TextOverflow.ellipsis)
              : Icon(Icons.add,
                  color: selected == StreamingService.other
                      ? const Color(0xFFFF2D78)
                      : Colors.white38,
                  size: 26),
          ),
        ),
      ),
    ]);
  }
}

class _DayPicker extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final Function(int) onChanged;
  const _DayPicker({required this.selected, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(7, (i) {
      final isSel = i == selected;
      return Expanded(child: GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(right: i < 6 ? 4 : 0),
          height: 38,
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFFF2D78).withOpacity(0.2) : const Color(0xFF1E1E2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSel ? const Color(0xFFFF2D78) : Colors.white12, width: 1.5),
          ),
          child: Center(child: Text(labels[i], style: TextStyle(
              color: isSel ? const Color(0xFFFF2D78) : Colors.white38,
              fontSize: 11, fontWeight: FontWeight.w800))),
        ),
      ));
    }));
  }
}

class _NumberStepper extends StatelessWidget {
  final int value; final int min; final int max;
  final Function(int) onChanged;
  const _NumberStepper({required this.value, required this.min,
      required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(height: 46,
      decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        _btn(Icons.remove, () { if (value > min) onChanged(value - 1); }),
        Expanded(child: Center(child: Text(value.toString().padLeft(2, '0'),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)))),
        _btn(Icons.add, () { if (value < max) onChanged(value + 1); }),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 42, height: 46,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: const Color(0xFFFF2D78), size: 18)),
  );
}
