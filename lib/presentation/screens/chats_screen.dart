import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/controllers/chat_controller.dart';
import 'package:vtalk_app/presentation/screens/chat/chat_room_screen.dart';
import 'package:vtalk_app/presentation/widgets/airy_chat_header.dart';
import 'package:vtalk_app/presentation/widgets/chat_search_delegate.dart';
import 'package:vtalk_app/presentation/widgets/airy_chat_list_item.dart';

/// 📱 V-Talk Chats Screen - L4 UI Layer
/// Airy design with glassmorphism header and structured chat list
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ChatController>();
      if (controller.chatRooms.isEmpty) {
        controller.loadChatRooms();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ChatController>();
    final chatRooms = controller.chatRooms;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          AiryChatHeader(
            title: 'Chats',
            onSearchPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(chats: chatRooms),
            ),
            showProfileIcon: true,
          ),
          chatRooms.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AiryChatListItem(
                        chatRoom: chatRooms[index],
                        onTap: () {
                          final chatId = chatRooms[index].id;
                          controller.markAsRead(chatId);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChatRoomScreen(
                                chat: chatRooms[index],
                              ),
                            ),
                          );
                        },
                      ),
                      childCount: chatRooms.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.message, size: 24),
      ),
    );
  }

  void _createNewChat() {
    // TODO: Implement new chat creation
  }
}
