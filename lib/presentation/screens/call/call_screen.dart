import 'package:flutter/material.dart';

/// Заглушка экрана звонка.
/// Навигация готова, UI готов — реализация после бэкенда (WebRTC/Matrix).
class CallScreen extends StatelessWidget {
  final String contactName;
  final String? contactAvatar;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.contactName,
    this.contactAvatar,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
                Text(
                  isVideo ? 'Videoanruf' : 'Anruf',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 40), // balance
              ],
            ),
          ),

          // ── Contact info ─────────────────────────────────────────────
          const Spacer(),
          _ContactAvatar(
              name: contactName, avatarUrl: contactAvatar),
          const SizedBox(height: 16),
          Text(contactName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Verbinde…', // TODO: real call status
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14),
            ),
          ),

          // ── Coming soon banner ───────────────────────────────────────
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6B800).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFE6B800).withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.construction_rounded,
                  color: Color(0xFFE6B800), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Anrufe werden nach der Backend-Integration verfügbar sein.',
                  style: TextStyle(
                      color: Color(0xFFE6B800),
                      fontSize: 13),
                ),
              ),
            ]),
          ),
          const Spacer(),

          // ── Call controls ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallButton(
                  icon: Icons.mic_off_rounded,
                  label: 'Stumm',
                  onTap: () {}, // TODO
                ),
                // Hang up
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
                _CallButton(
                  icon: isVideo
                      ? Icons.videocam_rounded
                      : Icons.volume_up_rounded,
                  label: isVideo ? 'Video' : 'Lautspr.',
                  onTap: () {}, // TODO
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  const _ContactAvatar({required this.name, this.avatarUrl});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 100, height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFE6B800),
      border: Border.all(
          color: Colors.white.withOpacity(0.2), width: 3),
    ),
    child: avatarUrl != null
        ? ClipOval(child: Image.network(avatarUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials_widget))
        : _initials_widget,
  );

  Widget get _initials_widget => Center(
    child: Text(_initials,
        style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white)),
  );
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CallButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      const SizedBox(height: 8),
      Text(label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12)),
    ]),
  );
}
