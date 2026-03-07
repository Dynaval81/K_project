import '../data/models/chat_room.dart';
import '../data/models/message_model.dart';
import '../data/mock/mock_messages.dart';

class ChatManager {
  static List<ChatRoom> chats = _generateMockChatRooms();
  static List<MessageModel> messages = mockMessages;

  static void markAsRead(String chatId) {
    final index = chats.indexWhere((c) => c.id == chatId);
    if (index >= 0) chats[index].unread = 0;
  }
}

List<ChatRoom> _generateMockChatRooms() {
  return [
    ChatRoom(
      id: '1',
      name: 'Alice',
      isGroup: false,
      isOnline: true,
      unread: 2,
      participants: [],
      messages: [],
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ChatRoom(
      id: '2',
      name: 'Bob',
      isGroup: false,
      isOnline: false,
      unread: 0,
      participants: [],
      messages: [],
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ChatRoom(
      id: '3',
      name: 'Group Chat',
      isGroup: true,
      isOnline: false,
      unread: 1,
      participants: [],
      messages: [],
      lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ChatRoom(
      id: '4',
      name: 'Charlie',
      isGroup: false,
      isOnline: true,
      unread: 3,
      participants: [],
      messages: [],
      lastActivity: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];
}
