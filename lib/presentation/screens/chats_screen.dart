import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/chat_controller.dart';
import 'package:knoty/data/models/chat_room.dart';
import 'package:knoty/presentation/screens/chat/chat_room_screen.dart';
import 'package:knoty/presentation/widgets/knoty_app_bar.dart';
import 'package:knoty/presentation/widgets/locked_feature_wrapper.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
    super.dispose();
  }

  void _openChat(BuildContext context, ChatRoom chat) {
    context.read<ChatController>().markAsRead(chat.id);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ChatRoomScreen(chat: chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final allRooms = controller.chatRooms;
    final personal = allRooms.where((c) => c.isPersonal).toList();
    final groups = allRooms.where((c) => c.isGroup).toList();
    final school = allRooms.where((c) => c.isSchool).toList();
    final isSchoolVerified = context.watch<AuthController>().currentUser?.isSchoolVerified ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KnotyAppBar(
        title: 'Chats',
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE6B800),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFFE6B800),
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            const Tab(text: 'Persönlich'),
            const Tab(text: 'Gruppen'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Schule'),
                  if (!isSchoolVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_rounded, size: 12,
                        color: Color(0xFF9E9E9E)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _ChatList(
            rooms: personal,
            onTap: (chat) => _openChat(context, chat),
            emptyText: 'Noch keine persönlichen Chats',
          ),
          _ChatList(
            rooms: groups,
            onTap: (chat) => _openChat(context, chat),
            emptyText: 'Noch keine Gruppen',
          ),
          isSchoolVerified
              ? _ChatList(
                  rooms: school,
                  onTap: (chat) => _openChat(context, chat),
                  emptyText: 'Noch keine Schulchats',
                )
              : LockedFeatureWrapper(
                  isLocked: true,
                  title: 'Schulchats gesperrt',
                  subtitle: 'Warte auf die Freigabe durch deinen Schuladministrator.',
                  child: const SizedBox.expand(),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: новый чат
        backgroundColor: const Color(0xFFE6B800),
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.edit_rounded, size: 22),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatRoom> rooms;
  final void Function(ChatRoom) onTap;
  final String emptyText;

  const _ChatList({
    required this.rooms,
    required this.onTap,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: Color(0xFFBDBDBD),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyText,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _ChatListItem(
        chat: rooms[index],
        onTap: () => onTap(rooms[index]),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatRoom chat;
  final VoidCallback onTap;

  const _ChatListItem({required this.chat, required this.onTap});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Jetzt';
    if (diff.inHours < 1) return '${diff.inMinutes} Min.';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}.${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unread > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                _Avatar(chat: chat),
                if (chat.isOnline && chat.isPersonal)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name ?? 'Unbekannt',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: const Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? const Color(0xFFE6B800)
                              : const Color(0xFF9E9E9E),
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFF9E9E9E),
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6B800),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unread > 99 ? '99+' : '${chat.unread}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ChatRoom chat;

  const _Avatar({required this.chat});

  @override
  Widget build(BuildContext context) {
    // Группа — иконка с золотым фоном
    if (chat.isGroup) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6B800).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          chat.isClassGroup
              ? Icons.school_rounded
              : Icons.group_rounded,
          size: 24,
          color: const Color(0xFFE6B800),
        ),
      );
    }

    // Личный чат — инициалы
    final initials = _getInitials(chat.name);
    final color = _getAvatarColor(chat.id);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getAvatarColor(String id) {
    const colors = [
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFF42A5F5),
      Color(0xFFAB47BC),
      Color(0xFFEC407A),
      Color(0xFF66BB6A),
      Color(0xFFFF7043),
    ];
    final index = id.hashCode.abs() % colors.length;
    return colors[index];
  }
}