/// Server/location model for VPN selection.
class ServerModel {
  final String id;
  final String nodeId;
  final String location;
  final String countryCode;
  final String endpoint;
  final String purpose;
  final int capacity;
  final int currentLoad;
  final int loadPercentage;
  final String configType;
  final bool isAI;
  final bool available;
  final String? vlessUri;
  final String? xrayConfig; // Full Xray JSON config string
  final int priority; // Приоритет от сервера: 0 = наивысший, 10 = обычный

  const ServerModel({
    required this.id,
    required this.nodeId,
    required this.location,
    required this.countryCode,
    required this.endpoint,
    this.purpose = 'general',
    this.capacity = 1000,
    this.currentLoad = 0,
    this.loadPercentage = 0,
    this.configType = 'vless',
    this.isAI = false,
    this.available = true,
    this.vlessUri,
    this.xrayConfig,
    this.priority = 10,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id']?.toString() ?? json['nodeId']?.toString() ?? '',
      nodeId: json['nodeId']?.toString() ?? json['id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? '',
      endpoint: json['endpoint']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? 'general',
      capacity: (json['capacity'] as num?)?.toInt() ?? 1000,
      currentLoad: (json['currentLoad'] as num?)?.toInt() ?? 0,
      loadPercentage: (json['loadPercentage'] as num?)?.toInt() ?? 0,
      configType: json['configType']?.toString() ?? 'vless',
      isAI: json['isAI'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
      vlessUri: json['vlessUri']?.toString(),
      xrayConfig: json['xrayConfig']?.toString(),
      priority: (json['priority'] as num?)?.toInt() ?? 10,
    );
  }

  /// Flag emoji from country code
  String get flagEmoji {
    if (countryCode.length != 2) return '🌐';
    final base = 0x1F1E6 - 0x41;
    final first = countryCode.codeUnitAt(0);
    final second = countryCode.codeUnitAt(1);
    return String.fromCharCode(base + first) + String.fromCharCode(base + second);
  }

  /// Load label for UI
  String get loadLabel {
    if (loadPercentage == 0) return 'Свободен';
    if (loadPercentage < 50) return 'Нагрузка: низкая';
    if (loadPercentage < 80) return 'Нагрузка: средняя';
    return 'Нагрузка: высокая';
  }
}