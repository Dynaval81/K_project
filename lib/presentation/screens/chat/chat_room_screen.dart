import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/chat_controller.dart';
import 'package:vtalk_app/data/models/chat_room.dart';
import 'package:vtalk_app/presentation/widgets/molecules/chat_input_field.dart';
import 'package:vtalk_app/presentation/widgets/molecules/message_bubble.dart';

const Color _kChatBackground = Color(0xFFF8F9FA);
const Color _kChatAppBarBackground = Color(0xFFFFFFFF);
const Color _kChatDividerLabel = Color(0xFF00A3FF);

/// HAI3 Screen: Chat room – message thread + input.
class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chat;

  const ChatRoomScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late bool hasUnread;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    hasUnread = widget.chat.unread > 0;
    if (hasUnread) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatController>().markAsRead(widget.chat.id);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final chatMessages = controller.messagesForChat(widget.chat.id);

    return Scaffold(
      backgroundColor: _kChatBackground,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: chatMessages.length + (hasUnread ? 1 : 0),
              itemBuilder: (context, index) {
                if (hasUnread && index == 0) {
                  return _buildNewMessagesDivider();
                }
                final messageIndex = hasUnread ? index - 1 : index;
                final message = chatMessages[messageIndex];
                final isPreviousFromSameSender = messageIndex < chatMessages.length - 1 &&
                    chatMessages[messageIndex + 1].isMe == message.isMe;
                return MessageBubble(
                  message: message,
                  isMe: message.isMe,
                  isPreviousFromSameSender: isPreviousFromSameSender,
                );
              },
            ),
          ),
          ChatInputField(
            onSendMessage: (text) {
              controller.sendMessage(widget.chat.id, text);
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _kChatAppBarBackground,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=${widget.chat.name}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.chat.name ?? 'Unknown',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'online',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewMessagesDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3))),
          const SizedBox(width: 8),
          Text(
            'NEW MESSAGES',
            style: TextStyle(
              color: _kChatDividerLabel,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3))),
        ],
      ),
    );
  }
}
