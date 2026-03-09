import 'package:knoty/data/models/message_model.dart';

// ── Chat Type ─────────────────────────────────────────────────────────────────

enum ChatType {
  personal,      // личный чат
  classGroup,    // чат класса (требует верификации школы)
  schoolGroup,   // чат школы / по интересам (требует верификации школы)
}

extension ChatTypeX on ChatType {
  bool get requiresVerification =>
      this == ChatType.classGroup || this == ChatType.schoolGroup;
}

// ── Chat Room ─────────────────────────────────────────────────────────────────

class ChatRoom {
  final String id;
  final String? name;
  final ChatType type;
  final bool isOnline;
  int unread;
  final List<Map<String, dynamic>>? participants;
  final List<MessageModel>? messages;
  final DateTime? lastActivity;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? avatarUrl;

  // Школьные метаданные
  final String? schoolId;
  final String? schoolName;
  final String? classId;
  final String? className;

  ChatRoom({
    required this.id,
    this.name,
    this.type = ChatType.personal,
    this.isOnline = false,
    this.unread = 0,
    this.participants,
    this.messages,
    this.lastActivity,
    this.lastMessage,
    this.lastMessageTime,
    this.avatarUrl,
    this.schoolId,
    this.schoolName,
    this.classId,
    this.className,
  });

  bool get isPersonal => type == ChatType.personal;
  bool get isGroup => type != ChatType.personal;
  bool get isClassGroup => type == ChatType.classGroup;
  bool get isSchoolGroup => type == ChatType.schoolGroup;
  bool get requiresVerification => type.requiresVerification;

  factory ChatRoom.fromMatrix(Map<String, dynamic> map) {
    final roomName = (map['name'] ?? map['title'] ?? '').toString();
    final type = _detectType(roomName, map);
    return ChatRoom(
      id: map['id']?.toString() ?? map['room_id']?.toString() ?? '',
      name: roomName.isNotEmpty ? roomName : null,
      type: type,
      isOnline: map['isOnline'] == true,
      unread: (map['unread'] as int?) ?? 0,
      lastMessage: map['lastMessage']?.toString(),
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime'].toString())
          : null,
      avatarUrl: map['avatarUrl']?.toString(),
      schoolId: map['schoolId']?.toString(),
      schoolName: map['schoolName']?.toString(),
      classId: map['classId']?.toString(),
      className: map['className']?.toString(),
    );
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) =>
      ChatRoom.fromMatrix(map);

  static ChatType _detectType(String name, Map<String, dynamic> map) {
    final rawType = map['chatType']?.toString().toLowerCase() ?? '';
    if (rawType == 'class' || rawType == 'classgroup') return ChatType.classGroup;
    if (rawType == 'school' || rawType == 'schoolgroup') return ChatType.schoolGroup;
    if (rawType == 'personal') return ChatType.personal;
    final lower = name.toLowerCase();
    if (lower.contains('klasse') || lower.contains('class')) return ChatType.classGroup;
    if (lower.contains('schule') || lower.contains('school') ||
        lower.contains('interesse') || lower.contains('ag-')) return ChatType.schoolGroup;
    return ChatType.personal;
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    ChatType? type,
    bool? isOnline,
    int? unread,
    List<Map<String, dynamic>>? participants,
    List<MessageModel>? messages,
    DateTime? lastActivity,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? avatarUrl,
    String? schoolId,
    String? schoolName,
    String? classId,
    String? className,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOnline: isOnline ?? this.isOnline,
      unread: unread ?? this.unread,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      classId: classId ?? this.classId,
      className: className ?? this.className,
    );
  }
}