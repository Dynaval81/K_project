import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/data/models/user_model.dart';
import 'package:knoty/presentation/widgets/knoty_app_bar.dart';

class SchoolScreen extends StatelessWidget {
  const SchoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final isVerified = user?.isSchoolVerified ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KnotyAppBar(title: 'Schule'),
      body: isVerified
          ? _SchoolContent(user: user)
          : _NotVerifiedState(user: user),
    );
  }
}

// ── Not verified — blur + code input ─────────────────────────────────────────

class _NotVerifiedState extends StatefulWidget {
  final User? user;
  const _NotVerifiedState({this.user});

  @override
  State<_NotVerifiedState> createState() => _NotVerifiedStateState();
}

class _NotVerifiedStateState extends State<_NotVerifiedState> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Bitte gib den Schulcode ein');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    await Future.delayed(const Duration(seconds: 1)); // TODO: real API call
    if (mounted) {
      setState(() => _isLoading = false);
      // TODO: handle response
      setState(() => _error = 'Ungültiger Code. Bitte prüfe und versuche es erneut.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background hint content (blurred)
        Positioned.fill(
          child: _SchoolContentPreview(),
        ),
        // Blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.white.withOpacity(0.80)),
          ),
        ),
        // Foreground content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFE6B800).withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.school_rounded,
                      size: 40, color: Color(0xFFE6B800)),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Schule noch nicht bestätigt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gib den Code deiner Schule ein oder warte auf die Bestätigung durch deine Schule.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Code input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _error != null
                          ? const Color(0xFFDD0000).withOpacity(0.5)
                          : const Color(0xFFE6B800).withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9\-]')),
                      LengthLimitingTextInputFormatter(12),
                    ],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'SCH-XXXX',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFBDBDBD),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                    onSubmitted: (_) => _submitCode(),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFDD0000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _submitCode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6B800),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Code einlösen',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Waiting status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFE6B800).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded,
                          size: 18, color: Color(0xFFE6B800)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.user?.school != null
                              ? 'Warte auf Bestätigung von\n${widget.user!.school}'
                              : 'Warte auf Schulbestätigung',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE6B800),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Preview behind blur ───────────────────────────────────────────────────────

class _SchoolContentPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: List.generate(6, (i) => Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// ── Verified school content ───────────────────────────────────────────────────

class _SchoolContent extends StatelessWidget {
  final User? user;
  const _SchoolContent({this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user?.school != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFFE6B800).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6B800).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Color(0xFFE6B800), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user!.school!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user?.schoolClass != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Klasse ${user!.schoolClass}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const _SectionLabel('Dienste'),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _ServiceTile(icon: Icons.calendar_today_rounded, label: 'Stundenplan', onTap: () => _soon(context, 'Stundenplan')),
              _ServiceTile(icon: Icons.campaign_rounded, label: 'Mitteilungen', onTap: () => _soon(context, 'Mitteilungen')),
              _ServiceTile(icon: Icons.folder_rounded, label: 'Dokumente', onTap: () => _soon(context, 'Dokumente')),
              _ServiceTile(icon: Icons.assignment_rounded, label: 'Hausaufgaben', onTap: () => _soon(context, 'Hausaufgaben')),
              _ServiceTile(icon: Icons.grade_rounded, label: 'Noten', onTap: () => _soon(context, 'Noten')),
              _ServiceTile(icon: Icons.event_rounded, label: 'Veranstaltungen', onTap: () => _soon(context, 'Veranstaltungen')),
            ],
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$name — kommt bald'),
      backgroundColor: const Color(0xFF1A1A1A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5,
        ),
      );
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ServiceTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFFE6B800), size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}