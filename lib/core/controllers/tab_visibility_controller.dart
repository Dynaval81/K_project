import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabVisibilityController extends ChangeNotifier {
  bool _showAiTab = true;
  bool _showVpnTab = true;
  bool _showChatsTab = true;
  bool _hasChanged = false;

  bool get showAiTab => _showAiTab;
  bool get showVpnTab => _showVpnTab;
  bool get showChatsTab => _showChatsTab;
  bool get hasChanged => _hasChanged;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _showAiTab = prefs.getBool('dashboard_show_ai_tab') ?? true;
    _showVpnTab = prefs.getBool('dashboard_show_vpn_tab') ?? true;
    _showChatsTab = prefs.getBool('dashboard_show_chats_tab') ?? true;
    notifyListeners();
  }

  void setShowAiTab(bool value) {
    _showAiTab = value;
    _hasChanged = true;
    notifyListeners();
  }

  void setShowVpnTab(bool value) {
    _showVpnTab = value;
    _hasChanged = true;
    notifyListeners();
  }

  void setShowChatsTab(bool value) {
    _showChatsTab = value;
    _hasChanged = true;
    notifyListeners();
  }

  void resetChangedFlag() {
    _hasChanged = false;
  }
}