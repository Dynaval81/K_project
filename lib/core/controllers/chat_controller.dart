import 'dart:math' show Random;
import 'package:flutter/foundation.dart';
import 'package:knoty/core/services/chat_service.dart';
import 'package:knoty/data/models/chat_model.dart';
import 'package:knoty/data/models/chat_room.dart';
import 'package:knoty/data/models/message_model.dart';
import 'package:knoty/logic/chat_manager.dart';

/// Single chat state controller (Provider-only).
class ChatController extends ChangeNotifier {
  ChatController() {
    _chatRooms = List.from(ChatManager.chats);
    _messages  = List.from(ChatManager.messages);
    _chats     = _chatRooms.map((r) => ChatModel.fromChatRoom(r)).toList();
  }

  final ChatService _chatService = ChatService();
  List<ChatRoom>    _chatRooms   = [];
  List<MessageModel> _messages   = [];
  List<ChatModel>   _chats       = [];
  bool   _isLoading = false;
  String? _error;

  List<ChatRoom>    get chatRooms => List.unmodifiable(_chatRooms);
  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool   get isLoading => _isLoading;
  String? get error    => _error;
  List<ChatModel> get chats => List.unmodifiable(_chats);

  Future<void> loadChatRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _chatRooms = List.from(ChatManager.chats);
      _messages  = List.from(ChatManager.messages);
      _chats     = _chatRooms.map((r) => ChatModel.fromChatRoom(r)).toList();
    } catch (e, stack) {
      _error = 'Fehler beim Laden';
      debugPrint('[Chat] loadChats error: ' + e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String chatId) {
    // Sync both collections atomically
    ChatManager.markAsRead(chatId);
    _chatRooms = List.from(ChatManager.chats);
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx >= 0) _chats[idx].markAsRead();
    final ri = _chatRooms.indexWhere((r) => r.id == chatId);
    if (ri >= 0) _chatRooms[ri].unread = 0;
    notifyListeners();
  }

  Future<void> sendMessage(String chatRoomId, String text) async {
    final trimmed = text.trim();
    if (!_chatService.validateMessage(trimmed)) {
      _error = trimmed.isEmpty
          ? 'Nachricht darf nicht leer sein'
          : 'Nachricht zu lang (max. 1000 Zeichen)';
      notifyListeners();
      return;
    }
    final newMessage = MessageModel(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(0x7FFFFFFF)}',
      text: _chatService.parseMessageText(text),
      chatId: chatRoomId,
      senderId: 'me',
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    _messages.add(newMessage);
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final i = _messages.indexWhere((m) => m.id == newMessage.id);
      if (i >= 0) _messages[i] = newMessage.copyWith(status: MessageStatus.sent);
      ChatManager.messages.add(newMessage.copyWith(status: MessageStatus.sent));
      // Update lastMessage in chatRoom
      final ri = _chatRooms.indexWhere((r) => r.id == chatRoomId);
      if (ri >= 0) {
        _chatRooms[ri] = _chatRooms[ri].copyWith(
          lastMessage: _previewText(text),
          lastMessageTime: DateTime.now(),
        );
      }
      _error = null;
    } on FormatException catch (e) {
      final i = _messages.indexWhere((m) => m.id == newMessage.id);
      if (i >= 0) _messages[i] = newMessage.copyWith(status: MessageStatus.failed);
      _error = 'Ungültiges Nachrichtenformat';
      debugPrint('[Chat] FormatException: $e');
    } on StateError catch (e) {
      final i = _messages.indexWhere((m) => m.id == newMessage.id);
      if (i >= 0) _messages[i] = newMessage.copyWith(status: MessageStatus.failed);
      _error = 'Chat nicht gefunden';
      debugPrint('[Chat] StateError: $e');
    } catch (e, stack) {
      final i = _messages.indexWhere((m) => m.id == newMessage.id);
      if (i >= 0) _messages[i] = newMessage.copyWith(status: MessageStatus.failed);
      _error = 'Fehler beim Senden';
      debugPrint('[Chat] sendMessage error: ' + e.toString() + ' ' + stack.toString());
    }
    notifyListeners();
  }

  /// Возвращает сообщения для чата, новейшие первыми (для reverse ListView).
  List<MessageModel> messagesForChat(String chatId) {
    final list = _messages.where((m) => m.chatId == chatId).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int getUnreadCount(String chatId) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx < 0) return 0; // chat not found — not an error
    return _chats[idx].unreadCount;
  }

  /// Stub для совместимости с main.dart (Matrix userId не используется в mock-режиме)
  // ignore: avoid_setters_without_getters
  void updateUserId(String? userId) {}

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Converts [icon_name] emoji codes to a readable preview string
  static String _previewText(String text) {
    final cleaned = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]'),
      (m) {
        final code = m.group(1) ?? '';
        // Map common icons to descriptive labels
        if (code.startsWith('icon_')) return '🙂';
        return '🖼';  // GIF sticker
      },
    ).trim();
    return cleaned.isEmpty ? '🙂' : cleaned;
  }
}