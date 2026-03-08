import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/chat_controller.dart';
import 'package:knoty/presentation/screens/chat/chat_room_screen.dart';
import 'package:knoty/presentation/widgets/chat_search_delegate.dart';
import 'package:knoty/presentation/widgets/airy_chat_list_item.dart';
import 'package:knoty/presentation/widgets/knoty_app_bar.dart';

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
    final controller = context.watch<ChatController>();
    final chatRooms = controller.chatRooms;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KnotyAppBar(
        title: 'Chats',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: Color(0xFF1A1A1A), size: 22),
            onPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(chats: chatRooms),
            ),
          ),
        ],
      ),
      body: chatRooms.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 56, color: Color(0xFFE0E0E0)),
                  SizedBox(height: 16),
                  Text(
                    'Noch keine Nachrichten',
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: chatRooms.length,
              itemBuilder: (context, index) => AiryChatListItem(
                chatRoom: chatRooms[index],
                onTap: () {
                  final chatId = chatRooms[index].id;
                  controller.markAsRead(chatId);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          ChatRoomScreen(chat: chatRooms[index]),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: новый чат
        backgroundColor: const Color(0xFFE6B800),
        foregroundColor: Colors.white,
        child: const Icon(Icons.message_rounded, size: 24),
      ),
    );
  }
}