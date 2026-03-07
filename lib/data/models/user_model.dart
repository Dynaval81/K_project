class User {
  final String id;
  final String username;
  final String email;
  final String vtNumber;
  final bool isPremium;
  final String? premiumPlan;
  final DateTime? premiumExpiresAt;
  final bool hasVpnAccess;
  final DateTime? vpnExpiresAt;
  final bool hasAiAccess;
  final DateTime? aiExpiresAt;
  final String? avatar;
  final String? status;
  final String? matrixUserId;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.vtNumber,
    this.isPremium = false,
    this.premiumPlan,
    this.premiumExpiresAt,
    this.hasVpnAccess = false,
    this.vpnExpiresAt,
    this.hasAiAccess = false,
    this.aiExpiresAt,
    this.avatar,
    this.status,
    this.matrixUserId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final username = json['username']?.toString().isNotEmpty == true
        ? json['username'].toString()
        : (json['email']?.toString().split('@')[0] ?? 'User');

    DateTime? _parseDate(dynamic val) {
      if (val == null) return null;
      try { return DateTime.parse(val.toString()); } catch (_) { return null; }
    }

    // Нормализуем vtNumber — убираем VT- префикс если бэкенд его присылает
    final rawVt = json['vtNumber']?.toString() ?? '';
    final vtClean = rawVt.startsWith('VT-') ? rawVt.substring(3) : rawVt;

    return User(
      id: json['id']?.toString() ?? '',
      username: username,
      email: json['email']?.toString() ?? '',
      vtNumber: vtClean,
      isPremium: json['isPremium'] == true,
      premiumPlan: json['premiumPlan']?.toString(),
      premiumExpiresAt: _parseDate(json['premiumExpiresAt']),
      hasVpnAccess: json['hasVpnAccess'] == true,
      vpnExpiresAt: _parseDate(json['vpnExpiresAt']),
      hasAiAccess: json['hasAiAccess'] == true,
      aiExpiresAt: _parseDate(json['aiExpiresAt']),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
      matrixUserId: json['matrixUserId']?.toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// VPN доступен если hasVpnAccess=true И (vpnExpiresAt null ИЛИ не истёк)
  /// ИЛИ isPremium=true (полный доступ)
  bool get canUseVpn {
    if (isPremium) return true;
    if (!hasVpnAccess) return false;
    if (vpnExpiresAt == null) return true;
    return DateTime.now().isBefore(vpnExpiresAt!);
  }

  bool get canUseAi {
    if (isPremium) return true;
    if (!hasAiAccess) return false;
    if (aiExpiresAt == null) return true;
    return DateTime.now().isBefore(aiExpiresAt!);
  }

  String get premiumStatus {
    if (isPremium) return 'Premium активен';
    if (premiumExpiresAt == null) return 'Premium не активен';
    if (DateTime.now().isBefore(premiumExpiresAt!)) return 'Premium активен';
    return 'Premium истёк';
  }

  String get vpnStatus {
    if (canUseVpn) {
      if (vpnExpiresAt == null) return 'VPN — бессрочно';
      return 'VPN до ${_formatDate(vpnExpiresAt!)}';
    }
    return 'VPN недоступен';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'vtNumber': vtNumber,
    'isPremium': isPremium,
    'premiumPlan': premiumPlan,
    'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
    'hasVpnAccess': hasVpnAccess,
    'vpnExpiresAt': vpnExpiresAt?.toIso8601String(),
    'hasAiAccess': hasAiAccess,
    'aiExpiresAt': aiExpiresAt?.toIso8601String(),
    'avatar': avatar,
    'status': status,
    'matrixUserId': matrixUserId,
    'createdAt': createdAt?.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? vtNumber,
    bool? isPremium,
    String? premiumPlan,
    DateTime? premiumExpiresAt,
    bool? hasVpnAccess,
    DateTime? vpnExpiresAt,
    bool? hasAiAccess,
    DateTime? aiExpiresAt,
    String? avatar,
    String? status,
    String? matrixUserId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      vtNumber: vtNumber ?? this.vtNumber,
      isPremium: isPremium ?? this.isPremium,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      hasVpnAccess: hasVpnAccess ?? this.hasVpnAccess,
      vpnExpiresAt: vpnExpiresAt ?? this.vpnExpiresAt,
      hasAiAccess: hasAiAccess ?? this.hasAiAccess,
      aiExpiresAt: aiExpiresAt ?? this.aiExpiresAt,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      matrixUserId: matrixUserId ?? this.matrixUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
