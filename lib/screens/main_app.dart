import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../providers/user_provider.dart';
import 'tabs/chats_screen.dart';
import 'tabs/vpn_screen.dart';
import 'tabs/ai_screen.dart';
import 'dashboard_screen.dart';

class MainApp extends StatefulWidget {
  final int initialTab;

  MainApp({this.initialTab = 0});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // ПРАВИЛЬНЫЙ ПОРЯДОК ВКЛАДОК
  List<Widget> get _screens => [
    const ChatsScreen(),      // 0. Мессенджер (Первый)
    AIScreen(),         // 1. Vtalk AI - РАЗБЛОКИРОВАНО
    VPNScreen(),        // 2. VPN - РАЗБЛОКИРОВАНО
    DashboardScreen(          // 3. Dashboard (Последний)
      onTabSwitch: (i) => _changeTab(i),
    ),
  ];

  // ⭐ GRACE PERIOD - ПРОВЕРКА ДОСТУПА
  bool _hasAccess() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return false;
    return user.hasAccess();
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: PageView(
  controller: _pageController,
  onPageChanged: (index) {
    setState(() => _currentIndex = index);
  },
  physics: const BouncingScrollPhysics(), // Эффект пружины при свайпе
  children: _screens,
),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => _changeTab(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: themeProvider.isDarkMode ? Color(0xFF252541) : Color(0xFFF5F5F5), // Адаптивный цвет
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: themeProvider.isDarkMode ? Colors.white54 : Colors.black54, // Адаптивный цвет
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Vtalk AI'),
              BottomNavigationBarItem(icon: Icon(Icons.vpn_lock), label: 'VPN'),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
            ],
          ),
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: Text(
            'Search results for: $query',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final suggestions = [
          'Alice Johnson',
          'Bob Smith',
          'Charlie Brown',
          'Settings',
          'VPN Connection',
          'AI Assistant',
        ].where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase())).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.search, color: themeProvider.isDarkMode ? Colors.blue : Colors.blue),
              title: Text(
                suggestions.elementAt(index),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                query = suggestions.elementAt(index);
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
