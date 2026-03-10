import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:knoty/core/services/matrix_chat_service.dart';
import 'package:knoty/core/services/chat_service.dart';
import 'package:knoty/data/models/chat_room.dart';
import 'package:knoty/data/models/message_model.dart';

/// Chat state controller backed by Matrix Synapse.
class ChatController extends ChangeNotifier {
  // FIX #4: matrixUserId обновляется после init через updateUserId()
  String? _matrixUserId;
  String? get matrixUserId => _matrixUserId;

  ChatController({String? matrixUserId}) : _matrixUserId = matrixUserId {
    _subscribeToStreams();
  }

  final MatrixChatService _matrix = MatrixChatService();
  final ChatService _chatService = ChatService();

  List<ChatRoom> _chatRooms = [];
  // FIX #2: используем копии списков чтобы избежать race condition
  final Map<String, List<MessageModel>> _messagesByRoom = {};
  bool _isLoading = false;
  String? _error;

  List<ChatRoom> get chatRooms => List.unmodifiable(_chatRooms);
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<List<ChatRoom>>? _roomsSub;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  // FIX #4: вызывается из main.dart после восстановления сессии
  void updateUserId(String? userId) {
    if (_matrixUserId == userId) return;
    _matrixUserId = userId;
    _matrix.setUserContext(userId: userId);
  }

  void _subscribeToStreams() {
    _roomsSub = _matrix.roomsStream.listen((rooms) {
      _chatRooms = List.of(rooms); // копия
      notifyListeners();
    });

    _messagesSub = _matrix.messagesStream.listen((newMessages) {
      for (final msg in newMessages) {
        final roomId = msg.chatId ?? '';
        // Атомарное обновление через putIfAbsent + работа только с актуальным списком
        final list = _messagesByRoom.putIfAbsent(roomId, () => []);
        if (!list.any((m) => m.id == msg.id)) {
          final corrected = _matrixUserId != null
              ? msg.copyWith(isMe: msg.senderId == _matrixUserId)
              : msg;
          list.insert(0, corrected);
        }
      }
      notifyListeners();
    });
  }

  Future<void> loadChatRooms({String? school, String? schoolClass}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matrix.setUserContext(
        school: school,
        schoolClass: schoolClass,
        userId: _matrixUserId,
      );
      _matrix.startSync();
    } catch (e) {
      _error = 'Fehler beim Laden: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String roomId) async {
    if (_messagesByRoom.containsKey(roomId)) return;

    final history = await _matrix.loadHistory(
      roomId,
      currentUserId: _matrixUserId,
    );
    // FIX #2: присваиваем новый список
    _messagesByRoom[roomId] = List.of(history);
    notifyListeners();
  }

  void markAsRead(String chatId) {
    final idx = _chatRooms.indexWhere((r) => r.id == chatId);
    if (idx >= 0) {
      // FIX #2: создаём новый список вместо мутации
      final updated = List<ChatRoom>.of(_chatRooms);
      updated[idx] = updated[idx].copyWith(unread: 0);
      _chatRooms = updated;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String roomId, String text) async {
    if (!_chatService.validateMessage(text)) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = MessageModel(
      id: tempId,
      text: text.trim(),
      chatId: roomId,
      senderId: _matrixUserId ?? 'me',
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // FIX #2: работаем с копией чтобы избежать race condition
    final listBefore = List<MessageModel>.of(_messagesByRoom[roomId] ?? []);
    listBefore.insert(0, tempMsg);
    _messagesByRoom[roomId] = listBefore;
    notifyListeners();

    final success = await _matrix.sendMessage(roomId, text.trim());

    // Берём актуальный список (мог обновиться за время отправки)
    final list = _messagesByRoom[roomId];
    if (list != null) {
      final idx = list.indexWhere((m) => m.id == tempId);
      if (idx >= 0) {
        list[idx] = tempMsg.copyWith(
          status: success ? MessageStatus.sent : MessageStatus.failed,
        );
        notifyListeners();
      }
      // Если temp не найден — sync уже пришёл с реальным сообщением, всё ок
    }
  }

  List<MessageModel> messagesForChat(String chatId) {
    return List.unmodifiable(_messagesByRoom[chatId] ?? []);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _messagesSub?.cancel();
    _matrix.dispose();
    super.dispose();
  }
}