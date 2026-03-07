import 'package:flutter/material.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/data/models/message_model.dart';

/// HAI3 Molecule: Message bubble – stateless, Airy style.
/// Sent: primary blue; received: light surface grey.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isPreviousFromSameSender;
  /// Optional color for receiver (left) bubbles – e.g. #F3E5F5 for V-Assistant.
  final Color? receiverBubbleColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isPreviousFromSameSender = false,
    this.receiverBubbleColor,
  });

  static String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = _formatTime(message.timestamp);

    return Padding(
      padding: EdgeInsets.only(
        top: isPreviousFromSameSender ? 2 : 12,
        left: 16,
        right: 16,
        bottom: 2,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : (receiverBubbleColor ?? AppColors.surface),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(18),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? AppColors.onPrimary : AppColors.onSurface,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeFormat,
                style: TextStyle(
                  color: isMe
                      ? AppColors.onPrimary.withValues(alpha: 0.8)
                      : AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
