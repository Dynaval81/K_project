class ChatRoom {
  final String id;
  final String name;
  final bool isGroup;
  final bool isOnline;
  final int unread;

  ChatRoom({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.isOnline,
    required this.unread,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['title'] ?? '',
      isGroup: map['isGroup'] ?? false,
      isOnline: map['isOnline'] ?? true,
      unread: map['unread'] ?? 0,
    );
  }
}
