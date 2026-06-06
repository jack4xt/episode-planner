import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<String> _items = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('watchlist');
    if (data != null) {
      setState(() => _items = List<String>.from(jsonDecode(data)));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('watchlist', jsonEncode(_items));
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _items.add(text));
    _controller.clear();
    _save();
  }

  void _delete(int index) {
    setState(() => _items.removeAt(index));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFF2D78), Color(0xFF00CFFF)]).createShader(b),
            child: Text(l.watchlist,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: 1.5)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l.watchlistHint,
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF13131A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2A2A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2A2A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF2D78)),
                    ),
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _add,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF2D78), width: 2),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFFFF2D78), size: 22),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.bookmark_border, size: 64, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Text(l.watchlistEmpty,
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A3A)),
                    ),
                    child: ListTile(
                      title: Text(_items[i],
                          style: const TextStyle(color: Colors.white, fontSize: 15)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFFF2D78), size: 20),
                        onPressed: () => _delete(i),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
