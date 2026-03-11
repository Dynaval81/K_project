import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knoty/data/models/message_model.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final bool isPreviousFromSameSender;
  final String? senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isPreviousFromSameSender = false,
    this.senderName,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String? _reaction; // выбранная реакция

  static const _reactionIcons = [
    'icon_thumbup', 'icon_e_biggrin', 'icon_lol',  'icon_clap',
    'icon_cry',     'icon_eek',       'icon_mad',   'icon_wave',
  ];

  void _showReactions(BuildContext context) {
    if (!mounted) return;
    // Находим позицию пузыря на экране
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    // Показываем popup около пузыря
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      barrierDismissible: true,
      builder: (_) {
        final screenH = MediaQuery.of(context).size.height;
        // Показываем выше пузыря если он в нижней части экрана
        final showAbove = pos.dy > screenH * 0.6;
        final top = showAbove
            ? pos.dy - 76.0
            : pos.dy + size.height + 8.0;

        return Stack(children: [
          Positioned(
            top: top.clamp(48.0, screenH - 100.0),
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: _ReactionsSheet(
                icons: _reactionIcons,
                onReact: (icon) {
                  setState(() => _reaction = icon);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.isPreviousFromSameSender ? 2 : 8,
        left: widget.isMe ? 56 : 0,
        right: widget.isMe ? 0 : 56,
      ),
      child: Row(
        mainAxisAlignment: widget.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) ...[
            if (!widget.isPreviousFromSameSender)
              _SenderAvatar(
                  name: widget.senderName ??
                      (widget.message.senderId ?? ''))
            else
              const SizedBox(width: 32),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!widget.isMe &&
                    !widget.isPreviousFromSameSender &&
                    widget.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      widget.senderName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _nameColor(
                            widget.message.senderId ?? ''),
                      ),
                    ),
                  ),

                // Пузырь + реакция
                GestureDetector(
                  onLongPress: () => _showReactions(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Основной пузырь
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? const Color(0xFFE6B800)
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft:
                                Radius.circular(widget.isMe ? 20 : 4),
                            bottomRight:
                                Radius.circular(widget.isMe ? 4 : 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _MessageContent(
                              text: widget.message.text,
                              isMe: widget.isMe,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(
                                      widget.message.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: widget.isMe
                                        ? Colors.white
                                            .withOpacity(0.75)
                                        : const Color(0xFF9E9E9E),
                                  ),
                                ),
                                if (widget.isMe) ...[
                                  const SizedBox(width: 4),
                                  _StatusIcon(
                                      status: widget.message.status),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Реакция — снизу пузыря
                      if (_reaction != null)
                        Positioned(
                          bottom: -14,
                          right: widget.isMe ? null : 8,
                          left: widget.isMe ? 8 : null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFF0F0F0)),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.08),
                                    blurRadius: 4)
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: SvgPicture.asset(
                              'assets/emojis_v2/$_reaction.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Отступ под реакцию
                if (_reaction != null) const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  Color _nameColor(String id) {
    const colors = [
      Color(0xFF5B8DEF), Color(0xFF26A69A), Color(0xFFAB47BC),
      Color(0xFFEC407A), Color(0xFF66BB6A), Color(0xFFFF7043),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}

// ── Inline message content ────────────────────────────────────────────────────

class _MessageContent extends StatelessWidget {
  final String text;
  final bool isMe;
  const _MessageContent({required this.text, required this.isMe});

  List<InlineSpan> _buildSpans() {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\[([^\]]+)\]');
    int last = 0;

    final textStyle = TextStyle(
      fontSize: 16,
      color: isMe ? Colors.white : const Color(0xFF1A1A1A),
      height: 1.4,
    );

    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(
            text: text.substring(last, m.start), style: textStyle));
      }
      final code = m.group(1)!;
      final isSvg = code.startsWith('icon_');
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: isSvg
              ? SvgPicture.asset('assets/emojis_v2/$code.svg',
                  width: 22, height: 22)
              : Image.asset('assets/emojis/$code.gif',
                  width: 22, height: 22, gaplessPlayback: true),
        ),
      ));
      last = m.end;
    }

    if (last < text.length) {
      spans.add(
          TextSpan(text: text.substring(last), style: textStyle));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: textStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) =>
      Text.rich(TextSpan(children: _buildSpans()));
}

// ── Sender avatar ─────────────────────────────────────────────────────────────

class _SenderAvatar extends StatelessWidget {
  final String name;
  const _SenderAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name
            .trim()
            .split(' ')
            .map((p) => p[0])
            .take(2)
            .join()
            .toUpperCase();
    const colors = [
      Color(0xFF5B8DEF), Color(0xFF26A69A), Color(0xFFAB47BC),
      Color(0xFFEC407A), Color(0xFF66BB6A), Color(0xFFFF7043),
    ];
    final color = colors[name.hashCode.abs() % colors.length];
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}

// ── Status icon ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12, height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation(Colors.white70),
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded,
            size: 14, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded,
            size: 14, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 14, color: Colors.white);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline_rounded,
            size: 14, color: Colors.redAccent);
    }
  }
}

// ── Reactions sheet ───────────────────────────────────────────────────────────

class _ReactionsSheet extends StatelessWidget {
  final List<String> icons;
  final void Function(String icon) onReact;
  const _ReactionsSheet({required this.icons, required this.onReact});

  @override
  Widget build(BuildContext context) {
    // Ширина экрана минус отступы — делим на 8 иконок
    final screenW = MediaQuery.of(context).size.width;
    final itemSize = ((screenW - 48 - 7 * 8) / 8).clamp(36.0, 52.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: icons.map((icon) {
            return GestureDetector(
              onTap: () => onReact(icon),
              child: Container(
                width: itemSize,
                height: itemSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(7),
                child: SvgPicture.asset(
                  'assets/emojis_v2/$icon.svg',
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}