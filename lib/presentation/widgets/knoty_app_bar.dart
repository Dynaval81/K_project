import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/providers/user_provider.dart';
import 'package:knoty/theme_provider.dart';
import 'package:knoty/data/models/user_model.dart';

/// Единая шапка для всех экранов Knoty.
/// Использование:
///   appBar: KnotyAppBar(title: 'Chats')
///   — или в SliverAppBar через KnotyAppBar.sliver(...)
class KnotyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showAvatar;
  final Widget? leading;

  const KnotyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showAvatar = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  void _showProfileOverlay(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showProfileOverlay(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6B800).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFE6B800),
                  size: 20,
                ),
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.black.withOpacity(0.06),
        ),
      ),
    );
  }
}

// ── Profile Overlay ───────────────────────────────────────────────────────────
class _ProfileOverlay extends StatelessWidget {
  final User? user;
  final ThemeProvider themeProvider;

  const _ProfileOverlay({this.user, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
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
                          child: _GradientAvatar(user?.username ?? '?'),
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

                  // Settings
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.settings_outlined,
                        size: 18, color: Colors.grey.shade600),
                    title: const Text('Einstellungen',
                        style: TextStyle(fontSize: 14)),
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
                    title: const Text('Abmelden',
                        style: TextStyle(
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

// ── Gradient Avatar ───────────────────────────────────────────────────────────
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
