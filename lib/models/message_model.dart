class MessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final Map<String, int>? reactions;
  final MessageModel? replyTo;
  final bool isDeleted;
  final List<String>? urls;
  final String? imageUrl;
  final MessageType type;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.reactions,
    this.replyTo,
    this.isDeleted = false,
    this.urls,
    this.imageUrl,
    this.type = MessageType.text,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isMe: json['isMe'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reactions: (json['reactions'] as Map<String, dynamic>?)?.cast<String, int>(),
      replyTo: json['replyTo'] != null 
        ? MessageModel.fromJson(json['replyTo'] as Map<String, dynamic>)
        : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      urls: (json['urls'] as List<dynamic>?)?.cast<String>(),
      imageUrl: json['imageUrl'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isMe': isMe,
      'timestamp': timestamp.toIso8601String(),
      'reactions': reactions,
      'replyTo': replyTo?.toJson(),
      'isDeleted': isDeleted,
      'urls': urls,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
    };
  }

  String get formattedTime {
    final hours = timestamp.hour.toString().padLeft(2, '0');
    final minutes = timestamp.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  MessageModel copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? timestamp,
    Map<String, int>? reactions,
    MessageModel? replyTo,
    bool? isDeleted,
    List<String>? urls,
    String? imageUrl,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      replyTo: replyTo ?? this.replyTo,
      isDeleted: isDeleted ?? this.isDeleted,
      urls: urls ?? this.urls,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  sticker,
  system,
}
