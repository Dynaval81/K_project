import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_singbox_vpn/flutter_singbox.dart';
import 'package:http/http.dart' as http;
import 'package:vtalk_app/data/models/server_model.dart';
import 'package:vtalk_app/services/api_service.dart';

/// VPN engine — sing-box based, TUN mode, works without root.
class VPNService {
  static const _privateRanges = [
    '0.0.0.0/8', '10.0.0.0/8', '100.64.0.0/10', '127.0.0.0/8',
    '169.254.0.0/16', '172.16.0.0/12', '192.0.0.0/24', '192.168.0.0/16',
    '198.18.0.0/15', '198.51.100.0/24', '203.0.113.0/24',
    '240.0.0.0/4', '255.255.255.255/32',
    // IPv6 убран — вызывает проблемы с UDP в РФ
  ];
  final ApiService _api = ApiService();
  final FlutterSingbox _singbox = FlutterSingbox();

  bool _isConnected = false;
  ServerModel? _currentServer;
  bool _splitTunnelingEnabled = false;
  List<String> _splitApps = [];
  List<String> _splitDomains = [];

  bool get isConnected => _isConnected;
  ServerModel? get currentServer => _currentServer;
  bool get isSplitTunnelingEnabled => _splitTunnelingEnabled;
  List<String> get splitApps => List.unmodifiable(_splitApps);
  List<String> get splitDomains => List.unmodifiable(_splitDomains);

  StreamSubscription? _statusSubscription;

  Future<void> initialize(void Function(bool connected) onStatusChanged) async {
    _singbox.setNotificationTitle('VTalk VPN');
    _singbox.setNotificationDescription('Защищённое соединение активно');

    _statusSubscription = _singbox.onStatusChanged.listen((event) {
      final status = event['status'] as String?;
      final connected = status == VPNStatus.STARTED;
      _isConnected = connected;
      onStatusChanged(connected);
    });
  }

  void dispose() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
  }

  Future<List<ServerModel>> loadServers({String? purpose}) async {
    try {
      final result = await _api.getVpnServers(purpose: purpose);
      if (result['success'] == true) {
        final list = result['servers'] as List<dynamic>;
        return list
            .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
            .where((s) => s.available && !_isFakeServer(s))
            .toList();
      }
    } catch (e) {
      assert(() { debugPrint('[VPN] loadServers error: \$e'); return true; }());
    }
    return [];
  }

  bool _isFakeServer(ServerModel s) {
    final loc = s.location.toUpperCase();
    final id = s.nodeId.toUpperCase();
    return loc.contains('FAKE') || loc.contains('TEST ONLY');
  }

  Future<ServerModel?> loadConfig(String nodeId) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
          return null;
      }

      const base = 'https://hypermax.duckdns.org/api/v1';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final resp = await http.get(
        Uri.parse('$base/vpn/config/$nodeId'),
        headers: headers,
      );

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final nodeData = (data['data'] ?? data) as Map<String, dynamic>;
      final vlessUri = nodeData['vlessUri'] as String?;

      final singboxConfig = nodeData['singboxConfig'] as Map<String, dynamic>?;

      return ServerModel.fromJson({
        'id': nodeData['nodeId'] ?? nodeId,
        'nodeId': nodeData['nodeId'] ?? nodeId,
        'location': nodeData['location'] ?? '',
        'countryCode': _countryFromNodeId(nodeId),
        'endpoint': nodeData['endpoint'] ?? '',
        'purpose': 'general',
        'capacity': 1000,
        'currentLoad': 0,
        'loadPercentage': 0,
        'configType': nodeData['configType'] ?? 'vless',
        'isAI': false,
        'available': true,
        'vlessUri': vlessUri,
        'xrayConfig': singboxConfig != null ? jsonEncode(singboxConfig) : null,
      });
    } catch (e) {
      assert(() { debugPrint('[VPN] loadConfig error: \$e'); return true; }());
    }
    return null;
  }

  /// Пингуем сервер TCP-коннектом к его endpoint.
  /// Для всех протоколов — просто проверяем достижимость хоста.
  Future<int?> pingServer(ServerModel server) async {
    try {
      final parts = server.endpoint.split(':');
      if (parts.length < 2) return null;
      final host = parts[0];
      final configuredPort = int.tryParse(parts[1]) ?? 443;

      // Hysteria2 использует UDP — TCP пинг на его порт не работает.
      // Пробуем несколько TCP портов подряд, берём первый отвечающий.
      final portsToTry = server.configType == 'hysteria2'
          ? [443, 80, 8080, configuredPort]
          : [configuredPort];

      for (final port in portsToTry) {
        Socket? socket;
        try {
          final sw = Stopwatch()..start();
          socket = await Socket.connect(host, port,
              timeout: const Duration(seconds: 2));
          sw.stop();
          socket.destroy();
          return sw.elapsedMilliseconds;
        } catch (_) {
          socket?.destroy();
          // пробуем следующий порт
        }
      }
      return null; // ни один порт не ответил
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, int?>> pingAll(List<ServerModel> servers) async {
    if (servers.isEmpty) return {};
    final results = await Future.wait(
      servers.map((s) async => MapEntry(s.nodeId, await pingServer(s))),
    );
    return Map.fromEntries(results);
  }

  /// Возвращает серверы отсортированные по пингу (живые первыми).
  Future<List<ServerModel>> getSortedByPing(List<ServerModel> servers) async {
    if (servers.isEmpty) return [];
    final pings = await pingAll(servers);
    final alive = servers.where((s) => pings[s.nodeId] != null).toList();
    // Fallback: если никто не ответил на пинг — сортируем всех по priority
    final list = alive.isEmpty ? List<ServerModel>.from(servers) : alive;
    // Сортируем: сначала по priority (0 = наивысший), затем по пингу
    list.sort((a, b) {
      final pDiff = a.priority.compareTo(b.priority);
      if (pDiff != 0) return pDiff;
      return (pings[a.nodeId] ?? 9999).compareTo(pings[b.nodeId] ?? 9999);
    });
    return list;
  }

  /// Выбирает лучший сервер: сначала те что реально отвечают,
  /// среди них — с наименьшим пингом.
  Future<ServerModel?> pickFastest(List<ServerModel> servers) async {
    final sorted = await getSortedByPing(servers);
    return sorted.isEmpty ? null : sorted.first;
  }

  /// Проверяет реальное подключение к интернету через VPN сервер.
  /// Пытается подключиться к известному хосту через TCP.
  Future<bool> verifyConnectivity(ServerModel server) async {
    // Сначала проверяем пинг до сервера
    final ping = await pingServer(server);
    if (ping == null) return false;
    // Дополнительно проверяем TCP соединение с известным хостом
    try {
      Socket? socket;
      try {
        socket = await Socket.connect('8.8.8.8', 53,
            timeout: const Duration(seconds: 3));
        return true;
      } finally {
        socket?.destroy();
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> connect(ServerModel server) async {
    final Map<String, dynamic> singboxConfig;

    switch (server.configType) {
      case 'hysteria2':
      case 'wireguard':
        // Для этих протоколов берём singboxConfig с сервера как есть
        if (server.xrayConfig == null) {
          throw Exception('No singboxConfig for node \${server.nodeId}');
        }
        final raw = jsonDecode(server.xrayConfig!) as Map<String, dynamic>;
        singboxConfig = _mergeWithServerConfig(raw, '', serverEndpoint: server.endpoint);

      case 'singbox':
      case 'vless':
      default:
        // Для VLESS — берём singboxConfig с сервера или строим из vlessUri
        Map<String, dynamic>? serverConfig;
        try {
          if (server.xrayConfig != null) {
            serverConfig = jsonDecode(server.xrayConfig!) as Map<String, dynamic>;
          }
        } catch (_) {}
        if (serverConfig != null) {
          singboxConfig = _mergeWithServerConfig(serverConfig, server.vlessUri ?? '', serverEndpoint: server.endpoint);
        } else {
          final uri = server.vlessUri;
          if (uri == null || uri.isEmpty) {
            throw Exception('No config for node \${server.nodeId}');
          }
          singboxConfig = _buildSingboxConfig(uri, serverEndpoint: server.endpoint);
        }
    }

    final saved = await _singbox.saveConfig(jsonEncode(singboxConfig));
    if (!saved) throw Exception('Failed to save sing-box config');

    final started = await _singbox.startVPN();
    if (!started) throw Exception('Failed to start VPN');

    _currentServer = server;
  }

  Future<void> disconnect() async {
    try {
      await _singbox.stopVPN();
    } catch (e) {
      assert(() { debugPrint('[VPN] disconnect error: $e'); return true; }());
    } finally {
      _isConnected = false;
      _currentServer = null;
    }
  }

  bool _isReconnecting = false;

  Future<void> setSplitTunneling({
    required List<String> apps,
    required List<String> domains,
    required bool enabled,
  }) async {
    if (_isReconnecting) return; // защита от race condition
    _splitApps = List.from(apps);
    _splitDomains = List.from(domains);
    _splitTunnelingEnabled = enabled;

    // Если VPN уже подключён — переподключаем с новым конфигом
    if (_isConnected && _currentServer != null) {
      _isReconnecting = true;
      try {
        await disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
        await connect(_currentServer!);
      } finally {
        _isReconnecting = false;
      }
    }
  }

  Future<void> selectServer(ServerModel server) async {
    _currentServer = server;
  }

  Map<String, dynamic> _mergeWithServerConfig(
      Map<String, dynamic> serverConfig, String vlessUri, {String? serverEndpoint}) {
    final serverOutbounds =
        (serverConfig['outbounds'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ?? [];

    // Добавляем xudp к proxy outbound для поддержки UDP мессенджеров
    final patchedOutbounds = serverOutbounds.map((o) {
      if (o['tag'] == 'proxy' && o['type'] == 'vless') {
        return {...o, 'packet_encoding': 'xudp'};
      }
      return o;
    }).toList();

    final outbounds = [
      ...patchedOutbounds,
      if (!serverOutbounds.any((o) => o['tag'] == 'direct'))
        {'tag': 'direct', 'type': 'direct'},
      if (!serverOutbounds.any((o) => o['tag'] == 'dns-out'))
        {'tag': 'dns-out', 'type': 'dns'},
    ];

    const privateRanges = _privateRanges;

    // Извлекаем и валидируем IP сервера (только IPv4)
    final rawHost = serverEndpoint?.split(':').first;
    final serverIp = _isValidIPv4(rawHost) ? rawHost : null;

    final routeRules = <Map<String, dynamic>>[
      {'protocol': 'dns', 'outbound': 'dns-out'},
      if (serverIp != null)
        {'ip_cidr': ['$serverIp/32'], 'outbound': 'direct'},
      {'ip_version': 6, 'outbound': 'direct'}, // блокируем IPv6 — в РФ вызывает проблемы
      // Telegram серверы — принудительно через VPN (для звонков в РФ)
      {
        'ip_cidr': [
          '91.108.4.0/22', '91.108.8.0/22', '91.108.12.0/22',
          '91.108.16.0/22', '91.108.56.0/22', '149.154.160.0/20',
          '2001:b28:f23d::/48', '2001:b28:f23f::/48',
        ],
        'outbound': 'proxy',
      },
      {'ip_cidr': privateRanges, 'outbound': 'direct'},
      if (_splitTunnelingEnabled) ...([
        if (_splitApps.isNotEmpty)
          {'android_package_names': _splitApps, 'outbound': 'proxy'},
        if (_splitDomains.isNotEmpty)
          {'domain': _splitDomains, 'outbound': 'proxy'},
        {'outbound': 'direct'},
      ]),
    ];

    return {
      'log': {'level': 'warn', 'disabled': false, 'timestamp': false},
      'dns': {
        'servers': [
          {'tag': 'remote-dns', 'address': 'https://1.1.1.1/dns-query', 'detour': 'proxy'},
          {'tag': 'local-dns', 'address': 'local', 'detour': 'direct'},
        ],
        'rules': [
          {'outbound': 'any', 'server': 'local-dns'},
          // Домены мессенджеров — через remote DNS (обход DNS poisoning)
          {
            'domain_suffix': [
              'telegram.org', 't.me', 'cdn-telegram.org',
              'whatsapp.com', 'whatsapp.net',
              'signal.org', 'youtube.com', 'googlevideo.com',
            ],
            'server': 'remote-dns',
          },

        ],
        'final': 'remote-dns',
        'strategy': 'prefer_ipv4',
        'independent_cache': true,
      },
      'inbounds': [
        {
          'type': 'tun',
          'tag': 'tun-in',
          'interface_name': 'tun0',
          'inet4_address': '172.19.0.1/30',
          'mtu': 1280,
          'auto_route': true,
          'endpoint_independent_nat': true,
          'strict_route': true,
          'stack': 'system',
          'sniff': true,
          'sniff_override_destination': true,
          'udp_timeout': '5m',
        }
      ],
      'outbounds': outbounds,
      'route': {
        'auto_detect_interface': true,
        'final': _splitTunnelingEnabled ? 'direct' : 'proxy',
        'rules': routeRules,
      },
    };
  }

  Map<String, dynamic> _buildSingboxConfig(String vlessUri, {String? serverEndpoint}) {
    // Parse: vless://UUID@HOST:PORT?params#name
    final uri = Uri.parse(vlessUri);
    final uuid = uri.userInfo;
    final host = uri.host;
    final port = uri.port;
    final params = uri.queryParameters;

    final pbk  = params['pbk'] ?? '';
    final sni  = params['sni'] ?? host;
    final sid  = params['sid'] ?? '';
    final fp   = params['fp'] ?? 'chrome';
    final flow = params['flow'] ?? '';

    // Private IP ranges — replaces deprecated geoip:private
    const privateRanges = _privateRanges;

    // Извлекаем и валидируем IP сервера (только IPv4)
    final rawHost = serverEndpoint?.split(':').first;
    final serverIp = _isValidIPv4(rawHost) ? rawHost : null;

    final routeRules = <Map<String, dynamic>>[
      {'protocol': 'dns', 'outbound': 'dns-out'},
      if (serverIp != null)
        {'ip_cidr': ['$serverIp/32'], 'outbound': 'direct'},
      {'ip_version': 6, 'outbound': 'direct'}, // блокируем IPv6 — в РФ вызывает проблемы
      // Telegram серверы — принудительно через VPN (для звонков в РФ)
      {
        'ip_cidr': [
          '91.108.4.0/22', '91.108.8.0/22', '91.108.12.0/22',
          '91.108.16.0/22', '91.108.56.0/22', '149.154.160.0/20',
          '2001:b28:f23d::/48', '2001:b28:f23f::/48',
        ],
        'outbound': 'proxy',
      },
      {'ip_cidr': privateRanges, 'outbound': 'direct'},
      // STUN/TURN для звонков Telegram, WhatsApp, WebRTC
      {'protocol': 'stun', 'outbound': 'direct'},
      {'port': [3478, 3479, 5349, 19302, 19303, 19304, 19305, 19306, 19307, 19308, 19309], 'outbound': 'direct'},
      // Split tunneling: только выбранные приложения/домены через VPN, остальное direct
      if (_splitTunnelingEnabled) ...([
        if (_splitApps.isNotEmpty)
          {'android_package_names': _splitApps, 'outbound': 'proxy'},
        if (_splitDomains.isNotEmpty)
          {'domain': _splitDomains, 'outbound': 'proxy'},
        {'outbound': 'direct'},
      ]),
    ];

    return {
      'log': {'level': 'warn', 'disabled': false, 'timestamp': false},
      'dns': {
        'servers': [
          {'tag': 'remote-dns', 'address': 'https://1.1.1.1/dns-query', 'detour': 'proxy'},
          {'tag': 'local-dns', 'address': 'local', 'detour': 'direct'},
        ],
        'rules': [
          {'outbound': 'any', 'server': 'local-dns'},
          // Домены мессенджеров — через remote DNS (обход DNS poisoning)
          {
            'domain_suffix': [
              'telegram.org', 't.me', 'cdn-telegram.org',
              'whatsapp.com', 'whatsapp.net',
              'signal.org', 'youtube.com', 'googlevideo.com',
            ],
            'server': 'remote-dns',
          },

        ],
        'final': 'remote-dns',
        'strategy': 'prefer_ipv4',
        'independent_cache': true,
      },
      'inbounds': [
        {
          'type': 'tun',
          'tag': 'tun-in',
          'interface_name': 'tun0',
          'inet4_address': '172.19.0.1/30',
          'mtu': 1280,
          'auto_route': true,
          'endpoint_independent_nat': true,
          'strict_route': true,
          'stack': 'system',
          'sniff': true,
          'sniff_override_destination': true,
          'udp_timeout': '5m',
        }
      ],
      'outbounds': [
        {
          'tag': 'proxy',
          'type': 'vless',
          'server': host,
          'server_port': port,
          'uuid': uuid,
          if (flow.isNotEmpty) 'flow': flow,
          'tls': {
            'enabled': true,
            'server_name': sni,
            'reality': {
              'enabled': true,
              'public_key': pbk,
              'short_id': sid,
            },
            'utls': {
              'enabled': true,
              'fingerprint': fp,
            },
          },
          'packet_encoding': 'xudp',
        },
        {'tag': 'direct', 'type': 'direct'},
        {'tag': 'dns-out', 'type': 'dns'},
      ],
      'route': {
        'auto_detect_interface': true,
        // Если split tunneling — дефолт direct, иначе всё через proxy
        'final': _splitTunnelingEnabled ? 'direct' : 'proxy',
        'rules': routeRules,
      },
    };
  }

  static bool _isValidIPv4(String? ip) {
    if (ip == null || ip.isEmpty) return false;
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255;
    });
  }

  String _countryFromNodeId(String nodeId) {
    final id = nodeId.toUpperCase();
    if (id.startsWith('PL')) return 'PL';
    if (id.startsWith('FI')) return 'FI';
    if (id.startsWith('DE')) return 'DE';
    if (id.startsWith('US')) return 'US';
    if (id.startsWith('RU')) return 'RU';
    if (id.startsWith('NL')) return 'NL';
    if (id.startsWith('GB') || id.startsWith('UK')) return 'GB';
    return 'XX';
  }
}