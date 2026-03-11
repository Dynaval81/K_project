import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom TextEditingController that renders emoji codes as images inline.
/// Format: [icon_name] for SVG (emojis_v2), [name] for GIF (emojis).
class EmojiTextEditingController extends TextEditingController {
  /// Map of emoji code → asset path, e.g. 'icon_cool' → 'assets/emojis_v2/icon_cool.svg'
  final Map<String, String> _emojiAssets;

  EmojiTextEditingController({
    Map<String, String>? emojiAssets,
    String? text,
  })  : _emojiAssets = emojiAssets ?? _buildDefaultAssets(),
        super(text: text ?? '');

  /// Auto-builds asset map from our two emoji sets
  static Map<String, String> _buildDefaultAssets() {
    const svgNames = [
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
    const gifNames = [
      'afro',    'alabama',   'angel',      'angry',
      'azn',     'bang',      'blank',      'buenpost',
      'cheesy',  'cool',      'cry',        'embarrassed',
      'evil',    'grin',      'huh',        'kiss',
      'laugh',   'lipsrsealed','mario',     'pacman',
      'police',  'rolleyes',  'sad',        'sad2',
      'shocked', 'shrug',     'smile',      'smiley',
      'tongue',  'undecided', 'wink',
    ];
    final map = <String, String>{};
    for (final n in svgNames) map[n] = 'assets/emojis_v2/$n.svg';
    for (final n in gifNames) map[n] = 'assets/emojis/$n.gif';
    return map;
  }

  Map<String, String> get emojiAssets => Map.unmodifiable(_emojiAssets);

  static final _emojiRe = RegExp(r'\[([^\]]+)\]');

  Widget _buildAsset(String code, String path) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path, width: 22, height: 22, fit: BoxFit.contain,
      );
    }
    return Image.asset(
      path,
      width: 22, height: 22, fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 14, color: Colors.grey),
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = <InlineSpan>[];
    final text  = this.text;
    final base  = style ?? const TextStyle(
      fontSize: 16, color: Color(0xFF1A1A1A), height: 1.4);
    int last = 0;

    for (final m in _emojiRe.allMatches(text)) {
      // Plain text before this emoji
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start), style: base));
      }

      final code = m.group(1)!;
      final path = _emojiAssets[code];

      if (path != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _buildAsset(code, path),
          ),
        ));
      } else {
        // Unknown code — show as grey text so user notices the typo
        spans.add(TextSpan(
          text: m.group(0),
          style: base.copyWith(color: Colors.grey),
        ));
      }

      last = m.end;
    }

    // Remaining plain text
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: base));
    }

    return TextSpan(
      style: style,
      children: spans.isEmpty
          ? [TextSpan(text: text, style: base)]
          : spans,
    );
  }
}