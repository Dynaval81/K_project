import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:knoty/constants/app_colors.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/controllers/tab_visibility_controller.dart';
import 'package:knoty/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:knoty/presentation/screens/chats_screen.dart';
import 'package:knoty/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:knoty/presentation/screens/schedule/schedule_screen.dart';

class MainNavShell extends StatefulWidget {
  final int initialIndex;
  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  String _activeTabId = 'chats';
  int _currentIndex = 0;

  static const List<String> _allTabIds = ['chats', 'ai', 'schedule', 'dashboard'];
  static const List<Widget> _allScreens = [
    ChatsScreen(key: PageStorageKey<String>('chats')),
    AiAssistantScreen(key: PageStorageKey<String>('ai')),
    ScheduleScreen(key: PageStorageKey<String>('schedule')),
    DashboardScreen(key: PageStorageKey<String>('dashboard')),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = _getFixedIndex('chats');
  }

  int _getFixedIndex(String tabId) {
    final idx = _allTabIds.indexOf(tabId);
    return idx < 0 ? 0 : idx;
  }

  void _onTabTapped(String tabId) {
    if (_activeTabId == tabId) return;
    setState(() {
      _activeTabId = tabId;
      _currentIndex = _getFixedIndex(tabId);
    });
  }

  void _handleTabVisibilityChange() {
    final tabVisibility = context.read<TabVisibilityController>();
    setState(() => _currentIndex = _getFixedIndex(_activeTabId));
    tabVisibility.resetChangedFlag();
  }

  @override
  Widget build(BuildContext context) {
    final tabVisibility = context.watch<TabVisibilityController>();
    final showAi = tabVisibility.showAiTab;
    final showChats = tabVisibility.showChatsTab;

    final activeTabs = <_TabItem>[
      if (showChats)
        const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats', id: 'chats'),
      if (showAi)
        const _TabItem(icon: Icons.psychology_rounded, label: 'KI', id: 'ai'),
      const _TabItem(icon: Icons.calendar_today_rounded, label: 'Stundenplan', id: 'schedule'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard', id: 'dashboard'),
    ];

    if (_currentIndex >= _allScreens.length) _currentIndex = 0;

    if (tabVisibility.hasChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleTabVisibilityChange();
      });
    }

    final activeTabVisible = activeTabs.any((t) => t.id == _activeTabId);
    if (!activeTabVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeTabId = 'chats';
            _currentIndex = _getFixedIndex('chats');
          });
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _allScreens,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),
        ),
        child: BottomNavigationBar(
          currentIndex: activeTabs
              .indexWhere((tab) => tab.id == _activeTabId)
              .clamp(0, activeTabs.length - 1),
          onTap: (index) => _onTabTapped(activeTabs[index].id),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFE6B800),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: activeTabs
              .map((t) => BottomNavigationBarItem(
                    key: ValueKey(t.id),
                    icon: Icon(t.icon),
                    label: t.label,
                  ))
              .toList(),
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