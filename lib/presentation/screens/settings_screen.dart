import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:knoty/constants/app_colors.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/l10n/app_localizations.dart';
import 'package:knoty/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Тема ─────────────────────────────────────────────────
          _SectionCard(
            children: [
              _SettingsRow(
                icon: Icons.palette_outlined,
                title: l10n.settingsTheme,
                trailing: _ThemeToggle(provider: themeProvider),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Аккаунт ──────────────────────────────────────────────
          _SectionCard(
            children: [
              _SettingsRow(
                icon: Icons.workspace_premium_outlined,
                title: l10n.settingsAccount,
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.black26),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── О приложении ─────────────────────────────────────────
          _SectionCard(
            children: [
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                title: l10n.dashboardAppInfo,
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Выйти ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) context.go(AppRoutes.auth);
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(l10n.dashboardLogout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

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
            onTap: () {
              widget.provider.setTheme(false);
              setState(() {});
            },
          ),
          _Btn(
            icon: Icons.dark_mode_rounded,
            active: isDark,
            onTap: () {
              widget.provider.setTheme(true);
              setState(() {});
            },
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
            color: active ? AppColors.primaryBlue : Colors.grey.shade500),
      ),
    );
  }
}