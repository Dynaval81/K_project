import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/controllers/tab_visibility_controller.dart';
import 'package:knoty/core/enums/user_role.dart';
import 'package:knoty/data/models/user_model.dart';
import 'package:knoty/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:knoty/presentation/screens/chats_screen.dart';
import 'package:knoty/presentation/screens/school/school_screen.dart';
import 'package:knoty/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:knoty/presentation/screens/parent/parent_control_screen.dart';
import 'package:knoty/presentation/screens/teacher/my_classes_screen.dart';
import 'package:knoty/presentation/screens/admin/verwaltung_screen.dart';

// ── Tab registry ──────────────────────────────────────────────────────────────

class _TabDef {
  final String id;
  final IconData icon;
  final String label;
  final Widget screen;

  const _TabDef({
    required this.id,
    required this.icon,
    required this.label,
    required this.screen,
  });
}

// Все возможные вкладки — порядок фиксирован для PageView
final _allTabs = <_TabDef>[
  _TabDef(
    id: 'chats', icon: Icons.chat_bubble_outline_rounded, label: 'Chats',
    screen: const ChatsScreen(key: PageStorageKey('chats')),
  ),
  _TabDef(
    id: 'ai', icon: Icons.psychology_rounded, label: 'KI',
    screen: const AiAssistantScreen(key: PageStorageKey('ai')),
  ),
  _TabDef(
    id: 'school', icon: Icons.school_rounded, label: 'Schule',
    screen: const SchoolScreen(key: PageStorageKey('school')),
  ),
  _TabDef(
    id: 'kind', icon: Icons.child_care_rounded, label: 'Kind',
    screen: const ParentControlScreen(key: PageStorageKey('kind')),
  ),
  _TabDef(
    id: 'classes', icon: Icons.class_rounded, label: 'Klassen',
    screen: const MyClassesScreen(key: PageStorageKey('classes')),
  ),
  _TabDef(
    id: 'verwaltung', icon: Icons.admin_panel_settings_rounded, label: 'Verwaltung',
    screen: const VerwaltungScreen(key: PageStorageKey('verwaltung')),
  ),
  _TabDef(
    id: 'dashboard', icon: Icons.dashboard_rounded, label: 'Dashboard',
    screen: const DashboardScreen(key: PageStorageKey('dashboard')),
  ),
];

/// Возвращает список id вкладок для данной роли и настроек видимости.
List<String> _tabIdsForRole(
  UserRole role,
  TabVisibilityController visibility,
) {
  final ids = <String>[];

  // Chats — у всех, но можно отключить в настройках
  if (visibility.showChatsTab) ids.add('chats');

  // KI — у всех, можно отключить
  if (visibility.showAiTab) ids.add('ai');

  // Schule — у всех кроме... (по таблице — у всех)
  if (visibility.showScheduleTab) ids.add('school');

  // Kind — только у родителя
  if (role.hasChildTab && visibility.showKindTab) ids.add('kind');

  // Meine Klassen — только у учителя
  if (role.hasMyClassesTab && visibility.showClassesTab) ids.add('classes');

  // Verwaltung — SchoolAdmin и SuperAdmin
  if (role.hasManagementTab && visibility.showVerwaltungTab) ids.add('verwaltung');

  // Dashboard — всегда последним
  ids.add('dashboard');

  return ids;
}

// ── Shell ─────────────────────────────────────────────────────────────────────

class MainNavShell extends StatefulWidget {
  final int initialIndex;
  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late PageController _pageController;
  String _activeTabId = 'chats';
  List<String> _currentTabIds = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(String tabId, List<String> tabIds) {
    if (_activeTabId == tabId) return;
    final pageIdx = _allTabs.indexWhere((t) => t.id == tabId);
    if (pageIdx < 0) return;
    setState(() => _activeTabId = tabId);
    _pageController.animateToPage(
      pageIdx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page, List<String> tabIds) {
    final tabId = _allTabs[page].id;
    if (tabIds.contains(tabId) && _activeTabId != tabId) {
      setState(() => _activeTabId = tabId);
    }
  }

  // Если активная вкладка исчезла из-за смены роли — переходим на dashboard
  void _ensureActiveTabVisible(List<String> tabIds) {
    if (!tabIds.contains(_activeTabId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _onTabTapped('dashboard', tabIds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final role = user?.role ?? UserRole.student;
    final visibility = context.watch<TabVisibilityController>();

    final tabIds = _tabIdsForRole(role, visibility);
    final activeTabs = _allTabs.where((t) => tabIds.contains(t.id)).toList();

    // Сохраняем для свайп-детектора
    _currentTabIds = tabIds;

    // Проверяем что активная вкладка видима
    _ensureActiveTabVisible(tabIds);

    // Сбрасываем флаг изменения настроек
    if (visibility.hasChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) visibility.resetChangedFlag();
      });
    }

    final currentNavIndex = activeTabs
        .indexWhere((t) => t.id == _activeTabId)
        .clamp(0, activeTabs.length - 1);

    return Scaffold(
      body: _SwipeTabDetector(
        activeTabs: activeTabs,
        activeTabId: _activeTabId,
        onSwipe: (id) => _onTabTapped(id, tabIds),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => _onPageChanged(page, tabIds),
          children: _allTabs.map((t) => t.screen).toList(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.12)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentNavIndex,
          onTap: (i) => _onTabTapped(activeTabs[i].id, tabIds),
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

// ── Swipe detector ────────────────────────────────────────────────────────────

class _SwipeTabDetector extends StatefulWidget {
  final List<_TabDef> activeTabs;
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
  static const double _threshold = 60.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (d) => _dragStart = d.globalPosition.dx,
      onHorizontalDragEnd: (d) {
        final dx = d.globalPosition.dx - _dragStart;
        if (dx.abs() < _threshold) return;
        final tabs = widget.activeTabs;
        final idx = tabs.indexWhere((t) => t.id == widget.activeTabId);
        if (idx < 0) return;
        if (dx < 0 && idx < tabs.length - 1) {
          widget.onSwipe(tabs[idx + 1].id);
        } else if (dx > 0 && idx > 0) {
          widget.onSwipe(tabs[idx - 1].id);
        }
      },
      child: widget.child,
    );
  }
}