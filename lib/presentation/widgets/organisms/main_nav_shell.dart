import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/tab_visibility_controller.dart';
import 'package:knoty/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:knoty/presentation/screens/chats_screen.dart';
import 'package:knoty/presentation/screens/school/school_screen.dart';
import 'package:knoty/presentation/screens/dashboard/dashboard_screen.dart';

class MainNavShell extends StatefulWidget {
  final int initialIndex;
  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late final PageController _pageController;
  String _activeTabId = 'chats';

  // Фиксированный порядок всех вкладок — не меняется
  static const _allTabIds = ['chats', 'ai', 'school', 'dashboard'];
  static const _allScreens = <Widget>[
    ChatsScreen(key: PageStorageKey<String>('chats')),
    AiAssistantScreen(key: PageStorageKey<String>('ai')),
    SchoolScreen(key: PageStorageKey<String>('school')),
    DashboardScreen(key: PageStorageKey<String>('dashboard')),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indexOf('chats'));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _indexOf(String tabId) {
    final i = _allTabIds.indexOf(tabId);
    return i < 0 ? 0 : i;
  }

  void _onTabTapped(String tabId) {
    if (_activeTabId == tabId) return;
    setState(() => _activeTabId = tabId);
    _pageController.animateToPage(
      _indexOf(tabId),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // PageView свайп завершён — синхронизируем activeTabId
  void _onPageChanged(int page, List<_TabItem> activeTabs) {
    // page — это индекс в _allScreens, ищем ближайшую видимую вкладку
    final tabId = _allTabIds[page];
    final isVisible = activeTabs.any((t) => t.id == tabId);
    if (isVisible && _activeTabId != tabId) {
      setState(() => _activeTabId = tabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabVisibility = context.watch<TabVisibilityController>();
    final showChats  = tabVisibility.showChatsTab;
    final showAi     = tabVisibility.showAiTab;
    final showSchool = tabVisibility.showScheduleTab;

    final activeTabs = <_TabItem>[
      if (showChats)
        const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats', id: 'chats'),
      if (showAi)
        const _TabItem(icon: Icons.psychology_rounded, label: 'KI', id: 'ai'),
      if (showSchool)
        const _TabItem(icon: Icons.school_rounded, label: 'Schule', id: 'school'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard', id: 'dashboard'),
    ];

    if (tabVisibility.hasChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        tabVisibility.resetChangedFlag();
        // Если активная вкладка скрыта — уходим на dashboard
        final visible = activeTabs.any((t) => t.id == _activeTabId);
        if (!visible) _onTabTapped('dashboard');
      });
    }

    final currentNavIndex = activeTabs
        .indexWhere((t) => t.id == _activeTabId)
        .clamp(0, activeTabs.length - 1);

    return Scaffold(
      body: _SwipeTabDetector(
        activeTabs: activeTabs,
        activeTabId: _activeTabId,
        onSwipe: _onTabTapped,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => _onPageChanged(page, activeTabs),
          children: _allScreens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),
        ),
        child: BottomNavigationBar(
          currentIndex: currentNavIndex,
          onTap: (i) => _onTabTapped(activeTabs[i].id),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFE6B800),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: activeTabs.map((t) => BottomNavigationBarItem(
            key: ValueKey(t.id),
            icon: Icon(t.icon),
            label: t.label,
          )).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String id;
  const _TabItem({required this.icon, required this.label, required this.id});
}

/// Детектор горизонтального свайпа для переключения вкладок.
/// Работает только с видимыми вкладками — скрытые пропускает.
class _SwipeTabDetector extends StatefulWidget {
  final List<_TabItem> activeTabs;
  final String activeTabId;
  final ValueChanged<String> onSwipe;
  final Widget child;
  const _SwipeTabDetector({
    required this.activeTabs,
    required this.activeTabId,
    required this.onSwipe,
    required this.child,
  });

  @override
  State<_SwipeTabDetector> createState() => _SwipeTabDetectorState();
}

class _SwipeTabDetectorState extends State<_SwipeTabDetector> {
  double _dragStart = 0;
  static const double _threshold = 60.0; // минимальная дистанция свайпа

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (d) => _dragStart = d.globalPosition.dx,
      onHorizontalDragEnd: (d) {
        final dx = d.globalPosition.dx - _dragStart;
        if (dx.abs() < _threshold) return;

        final tabs = widget.activeTabs;
        final currentIdx = tabs.indexWhere((t) => t.id == widget.activeTabId);
        if (currentIdx < 0) return;

        if (dx < 0 && currentIdx < tabs.length - 1) {
          // свайп влево → следующая вкладка
          widget.onSwipe(tabs[currentIdx + 1].id);
        } else if (dx > 0 && currentIdx > 0) {
          // свайп вправо → предыдущая вкладка
          widget.onSwipe(tabs[currentIdx - 1].id);
        }
      },
      child: widget.child,
    );
  }
}
