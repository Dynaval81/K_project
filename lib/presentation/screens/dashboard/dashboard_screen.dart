import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knoty/constants/app_colors.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/controllers/tab_visibility_controller.dart';
import 'package:knoty/data/models/user_model.dart';
import 'package:knoty/providers/user_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knoty/core/utils/app_logger.dart';
import 'package:knoty/theme_provider.dart';
import 'package:knoty/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  bool _showAiTab = true;
  bool _showChatsTab = true;
  bool _showScheduleTab = true;

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
      _showScheduleTab = prefs.getBool('dashboard_show_schedule_tab') ?? true;
    });
  }

  Future<void> _saveTabVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboard_show_ai_tab', _showAiTab);
    await prefs.setBool('dashboard_show_chats_tab', _showChatsTab);
    await prefs.setBool('dashboard_show_schedule_tab', _showScheduleTab);
    final ctrl = context.read<TabVisibilityController>();
    ctrl.setShowAiTab(_showAiTab);
    ctrl.setShowChatsTab(_showChatsTab);
  }

  void _showProfileOverlay() {
    final user = context.read<AuthController>().currentUser ??
        context.read<UserProvider>().user;
    final themeProvider = context.read<ThemeProvider>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'profile',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: _ProfileOverlay(user: user, themeProvider: themeProvider),
        );
      },
    );
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
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Icon(icon, color: const Color(0xFFE6B800), size: 24),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
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
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
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
      builder: (sheetCtx) =>
          _ReportSheet(onSend: (text) => _sendReport(user, text)),
    );
  }

  Future<void> _sendReport(User? user, String text) async {
    if (text.isEmpty) return;
    try {
      final token =
          await const FlutterSecureStorage().read(key: 'auth_token');
      final now = DateTime.now().toIso8601String();
      final body = {
        'description': text,
        'appVersion': '1.0.0',
        'platform': 'android',
        'logs': 'timestamp=$now\n${AppLogger.instance.getLogs()}',
      };
      await http.post(
        Uri.parse('https://api.knoty.de/api/v1/bug-report'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[REPORT] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      restorationId: 'dashboard_scaffold',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.dashboardTitle,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  GestureDetector(
                    onTap: _showProfileOverlay,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE6B800).withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          color: Color(0xFFE6B800), size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tabs visibility
              _buildCard(
                icon: Icons.tune_rounded,
                title: 'Elemente',
                initiallyExpanded: true,
                children: [
                  SwitchListTile(
                    value: _showChatsTab,
                    onChanged: (v) {
                      setState(() => _showChatsTab = v);
                      _saveTabVisibility();
                    },
                    title: Text(l10n.tabChats,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black)),
                    activeColor: const Color(0xFFE6B800),
                  ),
                  SwitchListTile(
                    value: _showAiTab,
                    onChanged: (v) {
                      setState(() => _showAiTab = v);
                      _saveTabVisibility();
                    },
                    title: Text(l10n.tabAi,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black)),
                    activeColor: const Color(0xFFE6B800),
                  ),
                  SwitchListTile(
                    value: _showScheduleTab,
                    onChanged: (v) {
                      setState(() => _showScheduleTab = v);
                      _saveTabVisibility();
                    },
                    title: Text(l10n.tabSchedule,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black)),
                    activeColor: const Color(0xFFE6B800),
                  ),
                ],
              ),

              // App info
              _buildCard(
                icon: Icons.info_outline_rounded,
                title: l10n.dashboardAppInfo,
                children: [
                  _infoRow('App', 'Knoty'),
                  _infoRow('Version', '1.0.0 (1)'),
                ],
              ),

              // Report bug
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _showReportSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
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
                        Expanded(
                          child: Text(
                            l10n.dashboardReport,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Overlay
class _ProfileOverlay extends StatelessWidget {
  final User? user;
  final ThemeProvider themeProvider;

  const _ProfileOverlay({this.user, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6B800).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: user?.avatar != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.avatar!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _GradientAvatar(user!.username),
                                  ),
                                )
                              : _GradientAvatar(user?.username ?? '?'),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${user?.username ?? '—'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (user?.email.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user!.email,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (user?.vtNumber.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user!.vtNumber.startsWith('KN-')
                                      ? user!.vtNumber
                                      : 'KN-${user!.vtNumber}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE6B800),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Theme
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined,
                            size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(l10n.settingsTheme,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ),
                        _ThemeToggle(provider: themeProvider),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Settings
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.settings_outlined,
                        size: 18, color: Colors.grey.shade600),
                    title: Text(l10n.dashboardSettings,
                        style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.settings);
                    },
                  ),

                  // Logout
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout_rounded,
                        size: 18, color: Colors.redAccent),
                    title: Text(l10n.dashboardLogout,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.redAccent)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await context.read<AuthController>().logout();
                      if (context.mounted) context.go(AppRoutes.auth);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Gradient Avatar
class _GradientAvatar extends StatelessWidget {
  final String name;
  const _GradientAvatar(this.name);

  static const _palettes = [
    [Color(0xFFE6B800), Color(0xFFCC9900)],
    [Color(0xFF9C27B0), Color(0xFF4A148C)],
    [Color(0xFF00BCD4), Color(0xFF006064)],
    [Color(0xFF4CAF50), Color(0xFF1B5E20)],
    [Color(0xFFFF9800), Color(0xFFE65100)],
    [Color(0xFFE91E63), Color(0xFF880E4F)],
  ];

  List<Color> get _colors {
    if (name.isEmpty) return _palettes[0];
    return _palettes[name.codeUnitAt(0) % _palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// Report Sheet
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
    final l10n = AppLocalizations.of(context)!;
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
          Text(l10n.dashboardReport,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(l10n.dashboardReportHint,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          if (_sent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(l10n.buttonOk,
                      style: const TextStyle(
                          color: Colors.green, fontSize: 15)),
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
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: l10n.dashboardReportHint,
                  hintStyle: const TextStyle(
                      color: Colors.black38, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
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
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.buttonSave,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Theme Toggle
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
              ? [BoxShadow(
                  color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : null,
        ),
        child: Icon(icon,
            size: 16,
            color: active
                ? const Color(0xFFE6B800)
                : Colors.grey.shade500),
      ),
    );
  }
}