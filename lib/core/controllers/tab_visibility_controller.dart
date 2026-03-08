import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabVisibilityController extends ChangeNotifier {
  bool _showAiTab = true;
  bool _showChatsTab = true;
  bool _showScheduleTab = true;
  bool _hasChanged = false;

  bool get showAiTab => _showAiTab;
  bool get showChatsTab => _showChatsTab;
  bool get showScheduleTab => _showScheduleTab;
  bool get hasChanged => _hasChanged;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _showAiTab = prefs.getBool('dashboard_show_ai_tab') ?? true;
    _showChatsTab = prefs.getBool('dashboard_show_chats_tab') ?? true;
    _showScheduleTab = prefs.getBool('dashboard_show_schedule_tab') ?? true;
    notifyListeners();
  }

  void setShowAiTab(bool value) {
    _showAiTab = value;
    _hasChanged = true;
    notifyListeners();
  }

  void setShowChatsTab(bool value) {
    _showChatsTab = value;
    _hasChanged = true;
    notifyListeners();
  }

  void setShowScheduleTab(bool value) {
    _showScheduleTab = value;
    _hasChanged = true;
    notifyListeners();
  }

  void resetChangedFlag() {
    _hasChanged = false;
  }
}