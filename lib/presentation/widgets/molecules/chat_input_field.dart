import 'package:flutter/material.dart';
import 'package:vtalk_app/core/constants.dart';

/// HAI3 Molecule: Chat input bar – attachment, text field, send/voice.
/// Stateful only for controller and typing state; otherwise minimal.
class ChatInputField extends StatefulWidget {
  final void Function(String text) onSendMessage;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: AppColors.onSurfaceVariant),
                onPressed: () {
                  // TODO: attachment picker
                },
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() => _hasText = value.trim().isNotEmpty);
                    },
                    onSubmitted: (_) => _onSend(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _hasText ? Icons.send_rounded : Icons.mic_rounded,
                  color: _hasText ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                onPressed: _hasText
                    ? _onSend
                    : () {
                        // TODO: voice recording
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
