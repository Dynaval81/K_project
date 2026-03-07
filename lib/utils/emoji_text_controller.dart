import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom TextEditingController that renders emoji codes as images inline
/// Shows :smile: as actual image while keeping text format for sending
/// Supports both primary (main) and retro (8-bit) emoji collections
class EmojiTextEditingController extends TextEditingController {
  late Map<String, String> _primaryEmojis;
  late Map<String, String> _retroEmojis;
  bool isDark;

  EmojiTextEditingController({
    required Map<String, String> emojiAssets, // Primary collection
    required this.isDark,
    Map<String, String>? retroAssets, // Retro collection
    String? text,
  }) : super(text: text ?? '') {
    _primaryEmojis = emojiAssets;
    _retroEmojis = retroAssets ?? {};
  }

  Map<String, String> get emojiAssets => _primaryEmojis;
  
  set emojiAssets(Map<String, String> assets) {
    _primaryEmojis = assets;
    notifyListeners();
  }

  void setRetroEmojis(Map<String, String> retroAssets) {
    _retroEmojis = retroAssets;
    notifyListeners();
  }

  void updateTheme(bool isDark) {
    this.isDark = isDark;
  }

  // Helper to render emoji asset as GIF or SVG
  Widget _buildEmojiAsset(String assetPath) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        assetPath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, size: 14, color: Colors.red),
      );
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> spans = [];
    final text = this.text;
    // Pattern to match both [retro]:code: and :code: formats
    final emojiRegex = RegExp(r'(\[retro\])?:(\w+):');
    int lastIndex = 0;

    for (final match in emojiRegex.allMatches(text)) {
      // Add text before emoji
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style ?? TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ));
      }

      // Check if this is from retro collection
      final isRetro = match.group(1) != null;
      final emojiCode = ':${match.group(2)}:';
      
      // Get appropriate collection
      final currentEmojis = isRetro ? _retroEmojis : _primaryEmojis;
      final asset = currentEmojis[emojiCode];

      if (asset != null) {
        // Render emoji as image
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: SizedBox(
              width: 22,
              height: 22,
              child: _buildEmojiAsset(asset),
            ),
          ),
        ));
      } else {
        // If emoji not found, show as text code
        final displayCode = isRetro ? '[retro]$emojiCode' : emojiCode;
        spans.add(TextSpan(
          text: displayCode,
          style: style ?? TextStyle(
            color: isDark ? Colors.grey : Colors.grey,
            fontSize: 14,
          ),
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style ?? TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ));
    }

    return TextSpan(
      style: style,
      children: spans.isEmpty
          ? [TextSpan(text: text, style: style)]
          : spans,
    );
  }
}
