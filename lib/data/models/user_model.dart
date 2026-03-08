import 'package:knoty/core/enums/verification_level.dart';

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
  final VerificationLevel verificationLevel;

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
    this.verificationLevel = VerificationLevel.none,
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

    // Parse verificationLevel
    VerificationLevel _parseVerificationLevel(dynamic val) {
      if (val == null) return VerificationLevel.none;
      final levelStr = val.toString().toLowerCase();
      switch (levelStr) {
        case 'verified':
          return VerificationLevel.verified;
        case 'sandbox':
          return VerificationLevel.sandbox;
        case 'none':
        default:
          return VerificationLevel.none;
      }
    }

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
      verificationLevel: _parseVerificationLevel(json['verificationLevel']),
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

  /// Returns true if user is in sandbox mode (restricted access)
  bool get isRestricted => verificationLevel == VerificationLevel.sandbox;

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
    'verificationLevel': verificationLevel.name,
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
    VerificationLevel? verificationLevel,
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
      verificationLevel: verificationLevel ?? this.verificationLevel,
    );
  }
}
