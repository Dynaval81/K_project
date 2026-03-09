import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/core/controllers/chat_controller.dart';
import 'package:knoty/data/models/chat_room.dart';
import 'package:knoty/data/models/user_model.dart';
import 'package:knoty/presentation/screens/chat/chat_room_screen.dart';
import 'package:knoty/presentation/widgets/knoty_app_bar.dart';

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
      CupertinoPageRoute(builder: (context) => ChatRoomScreen(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final user = context.watch<AuthController>().currentUser;
    final allRooms = controller.chatRooms;

    final personal = allRooms.where((c) => c.isPersonal).toList();
    final groups = allRooms.where((c) => c.type == ChatType.schoolGroup).toList();
    final schoolRooms = allRooms
        .where((c) => c.type == ChatType.classGroup || c.type == ChatType.schoolGroup)
        .toList();

    final isVerified = user?.isSchoolVerified ?? false;

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
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: [
            const Tab(text: 'Persönlich'),
            const Tab(text: 'Gruppen'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Schule'),
                  if (!isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_rounded, size: 12, color: Color(0xFF9E9E9E)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChatList(
            rooms: personal,
            onTap: (chat) => _openChat(context, chat),
            emptyText: 'Noch keine persönlichen Chats',
            emptySubtext: 'Schreibe jemandem als Erstes!',
          ),
          _ChatList(
            rooms: groups,
            onTap: (chat) => _openChat(context, chat),
            emptyText: 'Noch keine Gruppen',
            emptySubtext: '',
          ),
          _SchoolTab(
            rooms: schoolRooms,
            user: user,
            isVerified: isVerified,
            onTap: (chat) => _openChat(context, chat),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFE6B800),
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.edit_rounded, size: 22),
      ),
    );
  }
}

// ── School Tab ────────────────────────────────────────────────────────────────

class _SchoolTab extends StatelessWidget {
  final List<ChatRoom> rooms;
  final User? user;
  final bool isVerified;
  final void Function(ChatRoom) onTap;

  const _SchoolTab({
    required this.rooms,
    required this.user,
    required this.isVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return _LockedSchoolOverlay(user: user);

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school_rounded, size: 36, color: Color(0xFFE6B800)),
            ),
            const SizedBox(height: 16),
            const Text('Keine Schulchats',
                style: TextStyle(fontSize: 15, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 6),
            Text(user?.school ?? '',
                style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
          ],
        ),
      );
    }

    final classRooms = rooms.where((r) => r.type == ChatType.classGroup).toList();
    final schoolRooms = rooms.where((r) => r.type == ChatType.schoolGroup).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (classRooms.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.group_rounded,
            title: 'Meine Klasse',
            subtitle: user?.schoolClass ?? '',
          ),
          ...classRooms.map((r) => _ChatListItem(chat: r, onTap: () => onTap(r))),
        ],
        if (schoolRooms.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.school_rounded,
            title: 'Schulchats',
            subtitle: user?.school ?? '',
          ),
          ...schoolRooms.map((r) => _ChatListItem(chat: r, onTap: () => onTap(r))),
        ],
      ],
    );
  }
}

class _LockedSchoolOverlay extends StatelessWidget {
  final User? user;
  const _LockedSchoolOverlay({this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFE6B800).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.school_rounded,
                      size: 40, color: Color(0xFFE6B800)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Schulchats gesperrt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Deine Schule muss dich erst bestätigen, bevor du auf Klassen- und Schulchats zugreifen kannst.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFE6B800).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded,
                          size: 16, color: Color(0xFFE6B800)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Warte auf Bestätigung von\n${user?.school ?? 'deiner Schule'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE6B800),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE6B800)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Chat List ─────────────────────────────────────────────────────────────────

class _ChatList extends StatelessWidget {
  final List<ChatRoom> rooms;
  final void Function(ChatRoom) onTap;
  final String emptyText;
  final String emptySubtext;

  const _ChatList({
    required this.rooms,
    required this.onTap,
    required this.emptyText,
    required this.emptySubtext,
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
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 36, color: Color(0xFFBDBDBD)),
            ),
            const SizedBox(height: 16),
            Text(emptyText,
                style: const TextStyle(fontSize: 15, color: Color(0xFF9E9E9E))),
            if (emptySubtext.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(emptySubtext,
                  style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
            ],
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

// ── Chat List Item ────────────────────────────────────────────────────────────

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
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
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
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
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
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
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

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final ChatRoom chat;
  const _Avatar({required this.chat});

  @override
  Widget build(BuildContext context) {
    if (chat.isGroup) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6B800).withOpacity(0.3)),
        ),
        child: Icon(
          chat.isClassGroup ? Icons.school_rounded : Icons.group_rounded,
          size: 24,
          color: const Color(0xFFE6B800),
        ),
      );
    }

    final initials = _getInitials(chat.name);
    final color = _getColor(chat.id);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  Color _getColor(String id) {
    const colors = [
      Color(0xFFE6B800),
      Color(0xFF1A1A1A),
      Color(0xFF757575),
      Color(0xFFCC9900),
      Color(0xFF444444),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}