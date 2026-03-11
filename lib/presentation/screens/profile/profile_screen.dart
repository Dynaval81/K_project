import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:knoty/providers/user_provider.dart';
import 'package:knoty/core/enums/user_role.dart';
import 'package:knoty/core/enums/verification_level.dart';
import 'package:knoty/l10n/app_localizations.dart';

/// Экран профиля — показывает KN-номер, роль, школу, статус верификации.
/// KN-номер можно скопировать — нужен для теста связки родитель↔ребёнок.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(
            color: Color(0xFFE6B800))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A))),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar + name ──────────────────────────────────────────
            _AvatarCard(user: user),
            const SizedBox(height: 16),

            // ── KN-номер (главная карточка) ────────────────────────────
            _KnCard(knotyNumber: user.knotyNumber),
            const SizedBox(height: 16),

            // ── Основные данные ────────────────────────────────────────
            _InfoCard(children: [
              _InfoRow(
                icon: Icons.alternate_email_rounded,
                label: 'Benutzername',
                value: '@${user.username}',
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'E-Mail',
                value: user.email,
              ),
              if (user.firstName != null || user.lastName != null) ...[
                _Divider(),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  value: [user.firstName, user.lastName]
                      .whereType<String>()
                      .join(' '),
                ),
              ],
            ]),
            const SizedBox(height: 16),

            // ── Роль + школа ───────────────────────────────────────────
            _InfoCard(children: [
              _InfoRow(
                icon: _roleIcon(user.role),
                label: 'Rolle',
                value: _roleLabel(user.role),
                valueColor: const Color(0xFFE6B800),
              ),
              if (user.school != null) ...[
                _Divider(),
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Schule',
                  value: user.school!,
                ),
              ],
              if (user.schoolClass != null) ...[
                _Divider(),
                _InfoRow(
                  icon: Icons.class_outlined,
                  label: 'Klasse',
                  value: user.schoolClass!,
                ),
              ],
              if (user.isParent && user.linkedChildId != null) ...[
                _Divider(),
                _InfoRow(
                  icon: Icons.child_care_rounded,
                  label: 'Kind (KN)',
                  value: 'KN-${user.linkedChildId}',
                ),
              ],
            ]),
            const SizedBox(height: 16),

            // ── Верификация ────────────────────────────────────────────
            _VerificationCard(level: user.verificationLevel),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:    return Icons.school_rounded;
      case UserRole.parent:     return Icons.family_restroom_rounded;
      case UserRole.teacher:    return Icons.person_rounded;
      case UserRole.schoolAdmin:return Icons.admin_panel_settings_rounded;
      case UserRole.superAdmin: return Icons.shield_rounded;
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:    return 'Schüler';
      case UserRole.parent:     return 'Elternteil';
      case UserRole.teacher:    return 'Lehrer';
      case UserRole.schoolAdmin:return 'Schuladmin';
      case UserRole.superAdmin: return 'Superadmin';
    }
  }
}

// ── Avatar Card ───────────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final dynamic user; // User
  const _AvatarCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.username as String);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12, offset: const Offset(0, 2),
        )],
      ),
      child: Column(children: [
        // Avatar circle
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE6B800),
          ),
          child: user.avatar != null
              ? ClipOval(child: Image.network(
                  user.avatar as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _InitialsAvatar(initials: initials),
                ))
              : _InitialsAvatar(initials: initials),
        ),
        const SizedBox(height: 12),
        Text(
          user.username as String,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 4),
        Text(
          user.email as String,
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF9E9E9E)),
        ),
      ]),
    );
  }

  String _initials(String username) {
    if (username.isEmpty) return '?';
    final parts = username.split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length.clamp(0, 2)).toUpperCase();
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(initials,
        style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white)),
  );
}

// ── KN Card ───────────────────────────────────────────────────────────────────

class _KnCard extends StatelessWidget {
  final String knotyNumber;
  const _KnCard({required this.knotyNumber});

  void _copy(BuildContext context) {
    final full = knotyNumber.startsWith('KN-')
        ? knotyNumber
        : 'KN-$knotyNumber';
    Clipboard.setData(ClipboardData(text: full));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('KN-Nummer kopiert'),
      backgroundColor: const Color(0xFFE6B800),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final display = knotyNumber.startsWith('KN-')
        ? knotyNumber
        : 'KN-$knotyNumber';

    return GestureDetector(
      onTap: () => _copy(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE6B800),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(
            color: const Color(0xFFE6B800).withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Row(children: [
          const Icon(Icons.badge_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meine KN-Nummer',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.copy_rounded, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Kopieren',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Verification Card ─────────────────────────────────────────────────────────

class _VerificationCard extends StatelessWidget {
  final VerificationLevel level;
  const _VerificationCard({required this.level});

  @override
  Widget build(BuildContext context) {
    final (icon, label, desc, color) = switch (level) {
      VerificationLevel.verified => (
        Icons.verified_rounded,
        'Verifiziert',
        'Dein Konto ist von der Schule bestätigt.',
        const Color(0xFF4CAF50),
      ),
      VerificationLevel.sandbox => (
        Icons.hourglass_empty_rounded,
        'Ausstehend',
        'Dein Konto wartet auf Bestätigung durch den Schuladmin.',
        const Color(0xFFFF9800),
      ),
      VerificationLevel.none => (
        Icons.info_outline_rounded,
        'Nicht verifiziert',
        'Schließe die Schulverifizierung ab, um alle Funktionen zu nutzen.',
        const Color(0xFF9E9E9E),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B6B6B))),
          ],
        )),
      ]),
    );
  }
}

// ── Info Card + Row + Divider ─────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8, offset: const Offset(0, 2),
      )],
    ),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(children: [
      Icon(icon, size: 20, color: const Color(0xFFE6B800)),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(
              fontSize: 11, color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1A1A1A))),
        ]),
      ),
    ]),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1, indent: 54, endIndent: 20,
    color: Color(0xFFF0F0F0),
  );
}
