import 'package:flutter/foundation.dart';
import 'package:vtalk_app/core/services/chat_service.dart';
import 'package:vtalk_app/data/models/chat_model.dart';
import 'package:vtalk_app/data/models/chat_room.dart';
import 'package:vtalk_app/data/models/message_model.dart';
import 'package:vtalk_app/logic/chat_manager.dart';

/// Single chat state controller (Provider-only). Replaces Riverpod ChatProvider.
class ChatController extends ChangeNotifier {
  ChatController() {
    _chatRooms = List.from(ChatManager.chats);
    _messages = List.from(ChatManager.messages);
    _chats = _chatRooms.map((r) => ChatModel.fromChatRoom(r)).toList();
  }

  final ChatService _chatService = ChatService();
  List<ChatRoom> _chatRooms = [];
  List<MessageModel> _messages = [];
  List<ChatModel> _chats = [];
  bool _isLoading = false;
  String? _error;

  List<ChatRoom> get chatRooms => List.unmodifiable(_chatRooms);
  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatModel> get chats => List.unmodifiable(_chats);

  Future<void> loadChatRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _chatRooms = List.from(ChatManager.chats);
      _messages = List.from(ChatManager.messages);
      _chats = _chatRooms.map((r) => ChatModel.fromChatRoom(r)).toList();
    } catch (e) {
      _error = 'Failed to load: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String chatId) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx >= 0) {
      _chats[idx].markAsRead();
      ChatManager.markAsRead(chatId);
      _chatRooms = List.from(ChatManager.chats);
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatRoomId, String text) async {
    if (!_chatService.validateMessage(text)) {
      _error = 'Message validation failed';
      notifyListeners();
      return;
    }
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _chatService.parseMessageText(text),
      chatId: chatRoomId,
      senderId: 'current_user_id',
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    _messages.add(newMessage);
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final i = _messages.indexWhere((m) => m.id == newMessage.id);
      if (i >= 0) _messages[i] = newMessage.copyWith(status: MessageStatus.sent);
      ChatManager.messages.add(newMessage.copyWith(status: MessageStatus.sent));
      _error = null;
    } catch (e) {
      final i = _messages.indexWhere((m) => m.id == newMessage.id);
      if (i >= 0) _messages[i] = newMessage.copyWith(status: MessageStatus.failed);
      _error = 'Failed to send: ${e.toString()}';
    }
    notifyListeners();
  }

  /// Returns messages for a chat, newest first (for reverse ListView).
  List<MessageModel> messagesForChat(String chatId) {
    final list = _messages.where((m) => m.chatId == chatId).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int getUnreadCount(String chatId) {
    try {
      return _chats.firstWhere((c) => c.id == chatId).unreadCount;
    } catch (_) {
      return 0;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
