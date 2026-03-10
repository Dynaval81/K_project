import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/controllers/tab_visibility_controller.dart';
import 'package:knoty/data/models/user_model.dart';
import 'package:knoty/providers/user_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knoty/core/utils/app_logger.dart';
import 'package:knoty/theme_provider.dart';
import 'package:knoty/l10n/app_localizations.dart';
import 'package:knoty/presentation/widgets/knoty_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  bool _showAiTab = true;
  bool _showSchoolTab = true;
  bool _showChatsTab = true;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTabVisibility();
  }

  Future<void> _loadTabVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showAiTab = prefs.getBool('dashboard_show_ai_tab') ?? true;
      _showChatsTab = prefs.getBool('dashboard_show_chats_tab') ?? true;
    });
  }

  Future<void> _saveTabVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboard_show_ai_tab', _showAiTab);
    await prefs.setBool('dashboard_show_chats_tab', _showChatsTab);
    final ctrl = context.read<TabVisibilityController>();
    ctrl.setShowAiTab(_showAiTab);
    ctrl.setShowChatsTab(_showChatsTab);
    // school tab reuses schedule slot
    if (ctrl.runtimeType.toString().contains('TabVisibility')) {
      try { (ctrl as dynamic).setShowScheduleTab(_showSchoolTab); } catch (_) {}
    }
  }


  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>(title),
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        backgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Icon(icon, color: const Color(0xFFE6B800), size: 24),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        ],
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    final auth = context.read<AuthController>();
    final up = context.read<UserProvider>();
    final user = auth.currentUser ?? up.user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => _ReportSheet(
        onSend: (text) => _sendReport(user, text),
      ),
    );
  }

  Future<void> _sendReport(User? user, String text) async {
    if (text.isEmpty) return;

    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      final now = DateTime.now().toIso8601String();

      final body = {
        'description': text,
        'appVersion': '1.0.0',
        'platform': 'android',
        'logs': '=== USER INFO ===\n'
            'user=${user?.username ?? "unknown"}\n'
            'email=${user?.email ?? "unknown"}\n'
            'vt=VT-${user?.knotyNumber ?? ""}\n'
            'vpn=${user?.hasVpnAccess ?? false}\n'
            'premium=${user?.isPremium ?? false}\n'
            'timestamp=$now\n'
            '=== APP LOGS ===\n'
            '${AppLogger.instance.getLogs()}',
      };

      final response = await http.post(
        Uri.parse('https://hypermax.duckdns.org/api/v1/bug-report'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('[REPORT] Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[REPORT] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      restorationId: 'dashboard_scaffold',
      appBar: KnotyAppBar(title: AppLocalizations.of(context)!.dashboardTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildCard(
                icon: Icons.tune_rounded,
                title: 'Store',
                initiallyExpanded: true,
                children: [
                  Builder(builder: (context) {
                    // Считаем сколько вкладок сейчас включено
                    final enabledCount = [_showChatsTab, _showAiTab, _showSchoolTab]
                        .where((v) => v).length;
                    // Последнюю включённую вкладку нельзя выключить
                    return Column(children: [
                      SwitchListTile(
                        value: _showChatsTab,
                        onChanged: (_showChatsTab && enabledCount <= 1) ? null
                            : (v) { setState(() => _showChatsTab = v); _saveTabVisibility(); },
                        title: Text('Chats',
                            style: const TextStyle(fontSize: 16, color: Colors.black)),
                        activeColor: const Color(0xFFE6B800),
                      ),
                      SwitchListTile(
                        value: _showAiTab,
                        onChanged: (_showAiTab && enabledCount <= 1) ? null
                            : (v) { setState(() => _showAiTab = v); _saveTabVisibility(); },
                        title: Text('KI',
                            style: const TextStyle(fontSize: 16, color: Colors.black)),
                        activeColor: const Color(0xFFE6B800),
                      ),
                      SwitchListTile(
                        value: _showSchoolTab,
                        onChanged: (_showSchoolTab && enabledCount <= 1) ? null
                            : (v) { setState(() => _showSchoolTab = v); _saveTabVisibility(); },
                        title: Text('Schule',
                            style: const TextStyle(fontSize: 16, color: Colors.black)),
                        activeColor: const Color(0xFFE6B800),
                      ),
                    ]);
                  }),
                ],
              ),

              _buildCard(
                icon: Icons.info_outline_rounded,
                title: AppLocalizations.of(context)!.dashboardAppInfo,
                children: [
                  _infoRow('App', 'V-Talk'),
                  _infoRow('Version', '1.0.0 (1)'),
                ],
              ),

              _buildCard(
                icon: Icons.memory_rounded,
                title: AppLocalizations.of(context)!.dashboardVersionDetails,
                children: [
                  _infoRow('Build', '1'),
                  _infoRow('API', 'v1.0'),
                ],
              ),

              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _showReportSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.bug_report_outlined,
                              color: Colors.redAccent, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Fehler melden',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Overlay
// ─────────────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;

  const _Badge({required this.label, required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Toggle
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeToggle extends StatefulWidget {
  final ThemeProvider provider;
  const _ThemeToggle({required this.provider});

  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.provider.isDarkMode;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.light_mode_rounded,
            active: !isDark,
            onTap: () { widget.provider.setTheme(false); setState(() {}); },
          ),
          _Btn(
            icon: Icons.dark_mode_rounded,
            active: isDark,
            onTap: () { widget.provider.setTheme(true); setState(() {}); },
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : null,
        ),
        child: Icon(icon,
            size: 16,
            color: active ? const Color(0xFFE6B800) : Colors.grey.shade500),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Gradient Avatar — первая буква ника на градиентном фоне
// ─────────────────────────────────────────────────────────────────────────────
class _ReportSheet extends StatefulWidget {
  final Future<void> Function(String text) onSend;
  const _ReportSheet({required this.onSend});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await widget.onSend(text);
    if (!mounted) return;
    setState(() { _sending = false; _sent = true; });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.dashboardReport,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Beschreibe was nicht funktioniert — wir kümmern uns darum.',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_sent)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Bericht gesendet',
                      style: const TextStyle(color: Colors.green, fontSize: 15)),
                ],
              ),
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: 5,
                autofocus: true,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Was ist passiert?',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6B800),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Senden',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}