import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knoty/utils/emoji_text_controller.dart';

/// HAI3 Molecule: Chat Input Field
/// Send всегда виден. Emoji picker: вкладка SVG (emojis_v2) + GIF (emojis).
class ChatInputField extends StatefulWidget {
  final void Function(String text) onSendMessage;

  const ChatInputField({super.key, required this.onSendMessage});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late final EmojiTextEditingController _ctrl;
  final _focus = FocusNode();
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _ctrl = EmojiTextEditingController();
    _focus.addListener(() {
      if (_focus.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    _ctrl.clear();
    setState(() {});
  }

  void _toggleEmoji() {
    if (_showEmoji) {
      _focus.requestFocus();
    } else {
      _focus.unfocus();
    }
    setState(() => _showEmoji = !_showEmoji);
  }

  void _insertText(String value) {
    final text  = _ctrl.text;
    final sel   = _ctrl.selection;
    final start = (sel.isValid && sel.start >= 0) ? sel.start : text.length;
    final end   = (sel.isValid && sel.end   >= 0) ? sel.end   : start;
    final safeStart = start.clamp(0, text.length);
    final safeEnd   = end.clamp(safeStart, text.length);
    final next  = text.replaceRange(safeStart, safeEnd, value);
    _ctrl.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
          offset: (safeStart + value.length).clamp(0, next.length)),
    );
    setState(() {});
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AttachMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Input row ───────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.10))),
          ),
          padding: EdgeInsets.only(
            left: 12, right: 12, top: 8,
            bottom: _showEmoji ? 8 : MediaQuery.of(context).padding.bottom + 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Emoji toggle
              _InputBtn(
                icon: _showEmoji
                    ? Icons.keyboard_rounded
                    : Icons.emoji_emotions_outlined,
                onTap: _toggleEmoji,
                active: _showEmoji,
              ),
              const SizedBox(width: 6),

              // Text field — EmojiTextEditingController renders inline
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF1A1A1A), height: 1.4),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Nachricht...',
                      hintStyle: TextStyle(
                          fontSize: 16, color: Color(0xFFBDBDBD)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Attach
              _InputBtn(
                  icon: Icons.attach_file_rounded,
                  onTap: _showAttachMenu),
              const SizedBox(width: 6),

              // Send — always visible, dims when empty
              GestureDetector(
                onTap: _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ctrl.text.trim().isNotEmpty
                        ? const Color(0xFFE6B800)
                        : const Color(0xFFE6B800).withOpacity(0.35),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),

        // ── Emoji / Sticker picker ──────────────────────────────
        if (_showEmoji)
          _EmojiPicker(
            onSvg:  (name) => _insertText(' [$name] '), // TODO: render inline
            onGif:  (name) => _insertText(' [$name] '), // TODO: render inline
            onText: _insertText,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Emoji Picker — две вкладки: SVG (emojis_v2) и GIF (emojis)
// ─────────────────────────────────────────────────────────────────────────────

class _EmojiPicker extends StatefulWidget {
  final void Function(String name) onSvg;
  final void Function(String name) onGif;
  final void Function(String text) onText;

  const _EmojiPicker({
    required this.onSvg,
    required this.onGif,
    required this.onText,
  });

  @override
  State<_EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<_EmojiPicker>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // ── emojis_v2 — SVG (phpBB set) ────────────────────────────────────────────
  static const _svgEmojis = [
    'icon_e_smile',    'icon_e_biggrin',  'icon_e_wink',
    'icon_e_sad',      'icon_e_surprised','icon_e_confused',
    'icon_e_geek',     'icon_e_ugeek',    'icon_cool',
    'icon_lol',        'icon_lolno',      'icon_mad',
    'icon_razz',       'icon_redface',    'icon_rolleyes',
    'icon_neutral',    'icon_twisted',    'icon_evil',
    'icon_cry',        'icon_eek',        'icon_eh',
    'icon_angel',      'icon_arrow',      'icon_clap',
    'icon_crazy',      'icon_exclaim',    'icon_idea',
    'icon_mrgreen',    'icon_problem',    'icon_question',
    'icon_shh',        'icon_shifty',     'icon_sick',
    'icon_silent',     'icon_think',      'icon_thumbdown',
    'icon_thumbup',    'icon_wave',       'icon_wtf',
    'icon_yawn',
  ];

  // ── emojis — GIF (animated) ────────────────────────────────────────────────
  static const _gifEmojis = [
    'smiley',     'grin',       'laugh',      'wink',
    'cool',       'angel',      'kiss',       'tongue',
    'cheesy',     'embarrassed',
    'sad',        'sad2',       'cry',        'angry',
    'evil',       'huh',        'rolleyes',   'shocked',
    'undecided',  'shrug',      'blank',      'lipsrsealed',
    'afro',       'alabama',    'azn',        'bang',
    'buenpost',   'mario',      'pacman',     'police',
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top:    BorderSide(color: Colors.grey.withOpacity(0.12)),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.08)),
              ),
            ),
            child: TabBar(
              controller: _tab,
              indicatorColor: const Color(0xFFE6B800),
              indicatorWeight: 2.5,
              labelColor: const Color(0xFFE6B800),
              unselectedLabelColor: const Color(0xFF9E9E9E),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_emotions_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Smileys', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gif_box_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('GIF', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // ── SVG tab ─────────────────────────────────────
                GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: _svgEmojis.length,
                  itemBuilder: (_, i) {
                    final name = _svgEmojis[i];
                    return GestureDetector(
                      onTap: () => widget.onSvg(name),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          'assets/emojis_v2/$name.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

                // ── GIF tab ─────────────────────────────────────
                GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: _gifEmojis.length,
                  itemBuilder: (_, i) {
                    final name = _gifEmojis[i];
                    return GestureDetector(
                      onTap: () => widget.onGif(name),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          'assets/emojis/$name.gif',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input button
// ─────────────────────────────────────────────────────────────────────────────

class _InputBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _InputBtn({
      required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? const Color(0xFFE6B800).withOpacity(0.15)
              : const Color(0xFFF5F5F5),
        ),
        child: Icon(icon,
            color: active
                ? const Color(0xFFE6B800)
                : const Color(0xFF9E9E9E),
            size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attach menu
// ─────────────────────────────────────────────────────────────────────────────

class _AttachMenu extends StatelessWidget {
  const _AttachMenu();

  @override
  Widget build(BuildContext context) {
    const items = [
      _AttachItem(icon: Icons.photo_library_rounded,
          color: Color(0xFF5B8DEF), label: 'Galerie'),
      _AttachItem(icon: Icons.camera_alt_rounded,
          color: Color(0xFF26A69A), label: 'Kamera'),
      _AttachItem(icon: Icons.location_on_rounded,
          color: Color(0xFFEF5350), label: 'Standort'),
      _AttachItem(icon: Icons.insert_drive_file_rounded,
          color: Color(0xFFAB47BC), label: 'Datei'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 20),
        const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _AttachItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _AttachItem(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // TODO: implement
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF1A1A1A))),
      ]),
    );
  }
}