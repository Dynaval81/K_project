import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/constants/app_colors.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';
import 'package:vtalk_app/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:vtalk_app/presentation/screens/chats_screen.dart';
import 'package:vtalk_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vtalk_app/presentation/screens/vpn_screen.dart';
import 'package:vtalk_app/presentation/widgets/organisms/vpn_access_overlay.dart';

class MainNavShell extends StatefulWidget {
  final int initialIndex;
  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  String _activeTabId = 'vpn';
  int _currentIndex = 2;

  static const List<String> _allTabIds = ['chats', 'ai', 'vpn', 'dashboard'];
  static const List<Widget> _allScreens = [
    ChatsScreen(key: PageStorageKey<String>('chats')),
    AiAssistantScreen(key: PageStorageKey<String>('ai')),
    VpnScreen(key: PageStorageKey<String>('vpn')),
    DashboardScreen(key: PageStorageKey<String>('dashboard')),
  ];

  static const Set<String> _comingSoonTabs = {'chats', 'ai'};

  @override
  void initState() {
    super.initState();
    _currentIndex = _getFixedIndex('vpn');
  }

  int _getFixedIndex(String tabId) => _allTabIds.indexOf(tabId);

  void _onTabTapped(String tabId) {
    if (_activeTabId == tabId) return;
    // При переходе на VPN — перепроверяем доступ (вдруг юзер только что активировал)

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
    final showVpn = tabVisibility.showVpnTab;
    final showChats = tabVisibility.showChatsTab;

    final activeTabs = <_TabItem>[
      if (showChats)
        const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats', id: 'chats'),
      if (showAi)
        const _TabItem(icon: Icons.psychology_rounded, label: 'AI', id: 'ai'),
      if (showVpn)
        const _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN', id: 'vpn'),
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
            _activeTabId = 'dashboard';
            _currentIndex = _getFixedIndex('dashboard');
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
          if (_comingSoonTabs.contains(_activeTabId))
            _ComingSoonOverlay(tabId: _activeTabId),
          if (_activeTabId == 'vpn' && !(context.watch<AuthController>().currentUser?.canUseVpn ?? false))
            VpnAccessOverlay(
              onAccessGranted: () => setState(() {}),
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
          selectedItemColor: AppColors.primaryBlue,
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

class _ComingSoonOverlay extends StatelessWidget {
  final String tabId;
  const _ComingSoonOverlay({required this.tabId});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: Colors.white.withOpacity(0.7),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        tabId == 'ai'
                            ? Icons.psychology_rounded
                            : Icons.chat_bubble_outline_rounded,
                        size: 40,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Coming soon',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tabId == 'ai'
                          ? 'AI Assistant находится в разработке'
                          : 'Чаты скоро будут доступны',
                      style: const TextStyle(fontSize: 15, color: Colors.black45),
                    ),
                  ],
                ),
              ),
            ),
          ),
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