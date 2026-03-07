import 'message_model.dart';

class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final bool isOnline;
  int unread;
  final List<Map<String, dynamic>>? participants;
  final List<MessageModel>? messages;
  final DateTime? lastActivity;

  ChatRoom({
    required this.id,
    this.name,
    this.isGroup = false,
    this.isOnline = true,
    this.unread = 0,
    this.participants,
    this.messages,
    this.lastActivity,
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

  ChatRoom copyWith({
    String? id,
    String? name,
    bool? isGroup,
    bool? isOnline,
    int? unread,
    List<Map<String, dynamic>>? participants,
    List<MessageModel>? messages,
    DateTime? lastActivity,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      isOnline: isOnline ?? this.isOnline,
      unread: unread ?? this.unread,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
