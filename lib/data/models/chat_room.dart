import 'package:knoty/data/models/message_model.dart';

enum ChatType { personal, classGroup, schoolGroup }

extension ChatTypeX on ChatType {
  /// Школьные чаты требуют верификации школы
  bool get requiresVerification =>
      this == ChatType.classGroup || this == ChatType.schoolGroup;
}

class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final bool isOnline;
  int unread;
  final List<Map<String, dynamic>>? participants;
  final List<MessageModel>? messages;
  final DateTime? lastActivity;
  final ChatType type;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isSchool;
  final String? schoolId;
  final String? schoolName;
  final String? classId;
  final String? className;

  ChatRoom({
    required this.id,
    this.name,
    this.isGroup = false,
    this.isOnline = true,
    this.unread = 0,
    this.participants,
    this.messages,
    this.lastActivity,
    this.type = ChatType.personal,
    this.lastMessage,
    this.lastMessageTime,
    this.isSchool = false,
    this.schoolId,
    this.schoolName,
    this.classId,
    this.className,
  });

  // ── Getters ───────────────────────────────────────────────────────
  bool get isPersonal   => type == ChatType.personal;
  bool get isClassGroup => type == ChatType.classGroup;
  bool get isSchoolGroup => type == ChatType.schoolGroup;

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    final rawType = map['type']?.toString() ?? map['roomType']?.toString() ?? '';
    ChatType chatType;
    switch (rawType) {
      case 'classGroup':  chatType = ChatType.classGroup;  break;
      case 'schoolGroup': chatType = ChatType.schoolGroup; break;
      default:            chatType = ChatType.personal;
    }
    return ChatRoom(
      id:       map['id']?.toString() ?? '',
      name:     map['name'] ?? map['title'] ?? '',
      isGroup:  map['isGroup'] ?? false,
      isOnline: map['isOnline'] ?? true,
      unread:   map['unread'] ?? 0,
      type:     chatType,
      isSchool: map['isSchool'] ?? rawType == 'schoolGroup' || rawType == 'classGroup',
      schoolId:   map['schoolId']?.toString(),
      schoolName: map['schoolName']?.toString(),
      classId:    map['classId']?.toString(),
      className:  map['className']?.toString(),
      lastMessage:     map['lastMessage']?.toString(),
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime'].toString())
          : null,
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
    ChatType? type,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isSchool,
    String? schoolId,
    String? schoolName,
    String? classId,
    String? className,
  }) {
    return ChatRoom(
      id:              id              ?? this.id,
      name:            name            ?? this.name,
      isGroup:         isGroup         ?? this.isGroup,
      isOnline:        isOnline        ?? this.isOnline,
      unread:          unread          ?? this.unread,
      participants:    participants    ?? this.participants,
      messages:        messages        ?? this.messages,
      lastActivity:    lastActivity    ?? this.lastActivity,
      type:            type            ?? this.type,
      lastMessage:     lastMessage     ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isSchool:        isSchool        ?? this.isSchool,
      schoolId:        schoolId        ?? this.schoolId,
      schoolName:      schoolName      ?? this.schoolName,
      classId:         classId         ?? this.classId,
      className:       className       ?? this.className,
    );
  }
}