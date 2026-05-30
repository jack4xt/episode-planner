import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/history_entry.dart';
import '../models/show_entry.dart';
import '../providers/show_provider.dart';
import '../widgets/show_card.dart';
import '../widgets/add_edit_show_dialog.dart';
import '../widgets/tmdb_alert_bar.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ShowProvider provider;
  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDay = 0;
  int _bottomIndex = 0;

  ShowProvider get _provider => widget.provider;

  @override
  void initState() {
    super.initState();
    _updateSelectedDay();
  }

  /// Vrátí index dnů přeskupený podle firstDay nastavení
  /// Pokud začíná pondělí: [PO, ÚT, ST, ČT, PÁ, SO, NE] = index 0..6
  /// Pokud začíná neděle: [NE, PO, ÚT, ST, ČT, PÁ, SO] = index 0..6
  void _updateSelectedDay() {
    final now = DateTime.now();
    if (_provider.weekStartsOnSunday) {
      // DateTime.weekday: Mon=1..Sun=7, chceme NE=0, PO=1..SO=6
      _selectedDay = now.weekday % 7;
    } else {
      // Mon=0..Sun=6
      _selectedDay = now.weekday - 1;
    }
    _selectedDay = _selectedDay.clamp(0, 6);
  }

  /// Přemapuje interní index dne (0=PO nebo 0=NE) na dayOfWeek (0=PO..6=NE)
  int _tabIndexToDayOfWeek(int tabIndex) {
    if (_provider.weekStartsOnSunday) {
      // tab 0=NE(6), tab 1=PO(0)..tab 6=SO(5)
      return tabIndex == 0 ? 6 : tabIndex - 1;
    }
    return tabIndex; // PO=0..NE=6
  }


  void _openAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditShowDialog(
        provider: _provider,
        initialDay: _tabIndexToDayOfWeek(_selectedDay),
        onSave: (show) => _provider.addShow(show).then((_) => setState(() {})),
      ),
    );
  }

  void _openEditDialog(ShowEntry show) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditShowDialog(
        provider: _provider,
        initialDay: _tabIndexToDayOfWeek(_selectedDay),
        existingShow: show,
        onSave: (updated) => _provider.updateShow(updated).then((_) => setState(() {})),
      ),
    );
  }

  void _deleteShow(ShowEntry show) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.deleteShow, style: const TextStyle(color: Colors.white)),
        content: Text('${l.deleteConfirm} "${show.title}"?',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(l.cancel, style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _provider.deleteShow(show.id).then((_) => setState(() {}));
            },
            child: Text(l.delete, style: const TextStyle(color: Color(0xFFFF2D78))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_provider.isLoaded) return _buildLoading();

    final l = AppLocalizations.of(context);
    final alerts = _provider.activeAlerts;

    Widget body;
    switch (_bottomIndex) {
      case 1:
        body = HistoryScreen(provider: _provider);
        break;
      case 2:
        body = SettingsScreen(provider: _provider);
        break;
      default:
        body = _buildMain(l, alerts);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(child: body),
      bottomNavigationBar: _buildBottomNav(l),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFF2D78), Color(0xFF00CFFF)]).createShader(b),
            child: const Text('Episode PLANNER',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Color(0xFFFF2D78), strokeWidth: 2),
        ]),
      ),
    );
  }

  Widget _buildMain(AppLocalizations l, List<TmdbAlert> alerts) {
    final dayOfWeek = _tabIndexToDayOfWeek(_selectedDay);
    final shows = _provider.showsForDay(dayOfWeek);
    return Column(
      children: [
        _buildHeader(l),
        _buildDaySelector(l),
        ...alerts.map((a) => TmdbAlertBar(
          alert: a,
          onDismiss: () => _provider.dismissAlert(a).then((_) => setState(() {})),
        )),
        Expanded(child: _buildShowList(l, shows, dayOfWeek)),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Flexible(
            child: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFFFF2D78), Color(0xFF00CFFF)]).createShader(b),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l.appTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openAddDialog,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF2D78), width: 2),
              ),
              child: const Icon(Icons.add, color: Color(0xFFFF2D78), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(AppLocalizations l) {
    final allLabels = l.dayLabels; // PO, ÚT, ST, ČT, PÁ, SO, NE
    // Pokud týden začíná nedělí, přesuň NE na začátek
    final labels = _provider.weekStartsOnSunday
        ? [allLabels[6], ...allLabels.sublist(0, 6)]
        : allLabels;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (_, i) {
          final selected = i == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF2D78) : const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? const Color(0xFFFF2D78) : const Color(0xFF2A2A3A),
                  width: 1.5,
                ),
                boxShadow: selected ? [BoxShadow(
                    color: const Color(0xFFFF2D78).withOpacity(0.4),
                    blurRadius: 12, spreadRadius: 1)] : [],
              ),
              child: Center(child: Text(labels[i],
                  style: TextStyle(color: selected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShowList(AppLocalizations l, List<ShowEntry> shows, int dayOfWeek) {
    final allDayNames = l.dayNames;
    final dayName = allDayNames[dayOfWeek]; // vždy správný název dne
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 3, height: 20,
                  decoration: BoxDecoration(color: const Color(0xFFFF2D78),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF2D78).withOpacity(0.6), blurRadius: 8)])),
              const SizedBox(width: 10),
              Text(dayName,
                  style: const TextStyle(color: Color(0xFFFF2D78), fontSize: 16,
                      fontWeight: FontWeight.w800, letterSpacing: 2)),
            ]),
            Row(children: [
              Icon(Icons.calendar_month, size: 16, color: Colors.white.withOpacity(0.4)),
              const SizedBox(width: 6),
              Text('${shows.length} ${l.itemsLabel(shows.length)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
            ]),
          ]),
        ),
      ),
      if (shows.isEmpty)
        SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.tv_off, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(l.noShows, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15)),
          const SizedBox(height: 8),
          Text(l.addFirst, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13)),
        ])))
      else
        SliverFillRemaining(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) => Material(
              color: Colors.transparent,
              child: child,
            ),
            onReorder: (oldIndex, newIndex) {
              _provider.reorderShows(_selectedDay, oldIndex, newIndex)
                  .then((_) => setState(() {}));
            },
            itemCount: shows.length,
            itemBuilder: (ctx, i) {
              return Stack(
                key: ValueKey(shows[i].id),
                children: [
                  ShowCard(
                    show: shows[i],
                    showDragHandle: true,
                    onEdit: () => _openEditDialog(shows[i]),
                    onDelete: () => _deleteShow(shows[i]),
                    onToggleWatched: () =>
                        _provider.toggleWatched(shows[i].id).then((_) => setState(() {})),
                  ),
                  // Drag listener pouze na levé části karty (drag handle oblast)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    width: 40,
                    child: ReorderableDragStartListener(
                      index: i,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    ]);
  }

  Widget _buildBottomNav(AppLocalizations l) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A3A), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFFF2D78),
        unselectedItemColor: Colors.white38,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: l.dayLabels[DateTime.now().weekday - 1]),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: l.history),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l.settings),
        ],
      ),
    );
  }
}
