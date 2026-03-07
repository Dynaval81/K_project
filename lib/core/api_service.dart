import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ── Singleton ─────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Используем переменную окружения для базового URL
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://hypermax.duckdns.org/api/v1',
  );
  static const String _tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 30);
  
  // In-memory token cache — populated after login, shared across all usages
  String? _cachedToken;
  
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Get token — from cache first, then secure storage
  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _secureStorage.read(key: _tokenKey);
    return _cachedToken;
  }

  /// Save token to both cache and secure storage
  Future<void> _saveToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Clear token from both cache and secure storage  
  Future<void> _clearToken() async {
    _cachedToken = null;
    await _secureStorage.delete(key: _tokenKey);
  }

  // Регистрация пользователя
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? username,  // ⭐ Делаем опциональным
    String region = 'RU',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,  // Отправляем null если пусто
          // ⭐ Region убираем - бэкенд сам ставит
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // 🎯 ПРАВИЛЬНЫЙ ПАРСИНГ ОТВЕТА БЭКЕНДА (КАК В LOGIN)
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['user'] ?? data['data']?['user'];
        
        if (token != null) {
          await _saveToken(token);
        }
        
        return {
          'success': true,
          'user': userData,
          'token': token,
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        // ⭐ MATRIX ОШИБКИ - ПРОКИДЫВАЕМ ТЕКСТ ИСКЛЮЧЕНИЯ
        final matrixError = errorData['error'] ?? errorData['message'] ?? 'Registration failed';
        return {
          'success': false,
          'error': matrixError,
        };
      } else {
        // ⭐ ДРУГИЕ ОШИБКИ - ТАКЖЕ ПРОКИДЫВАЕМ ТЕКСТ
        final otherError = data['error'] ?? data['message'] ?? 'Registration failed';
        return {
          'success': false,
          'error': otherError,
        };
      }
    } catch (e) {
      // ⭐ MATRIX ОШИБКИ - ПРОКИДЫВАЕМ ТЕКСТ ИСКЛЮЧЕНИЯ
      String errorMessage = 'Registration failed';
      
      try {
        // Если это Exception с текстом ошибки - прокидываем его
        if (e.toString().contains('Exception:')) {
          final errorString = e.toString().split('Exception: ')[1];
          errorMessage = errorString.replaceAll(RegExp(r'[{}"]'), '').trim();
        } else {
          // Если это другая ошибка - пробуем распарсить как JSON
          final errorString = e.toString().replaceAll('Exception: ', '');
          errorMessage = errorString.replaceAll(RegExp(r'[{}"]'), '').trim();
        }
      } catch (_) {
        errorMessage = 'Network error: ${e.toString()}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  // Вход пользователя
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': email,
          'password': password,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // 🎯 ПРАВИЛЬНЫЙ ПАРСИНГ ОТВЕТА БЭКЕНДА
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['user'] ?? data['data']?['user'];
        
        if (token != null) {
          await _saveToken(token);
        }
        
        return {
          'success': true,
          'user': userData,
          'token': token,
          'isFirstLogin': userData?['isFirstLogin'] ?? false,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': data['error'] ?? 'Email not verified',
          'isEmailNotVerified': true,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      // ⭐ КРИТИЧНО - ПРАВИЛЬНЫЙ ПАРСИНГ ОШИБОК
      String errorMessage = 'Network error';
      
      try {
        if (e.toString().contains('Exception:')) {
          final errorString = e.toString().split('Exception: ')[1];
          errorMessage = errorString.replaceAll(RegExp(r'[{}"]'), '').trim();
        }
      } catch (_) {
        errorMessage = 'Network error: ${e.toString()}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  // Получение данных пользователя
  Future<Map<String, dynamic>> getUser() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      // 🔄 новый путь
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // теперь данные лежат глубже
        final userJson = data['data']?['user'] ?? data['user'];
        return {
          'success': true,
          'user': userJson,
        };
      } else {
        // Токен протух, удаляем его
        await _clearToken();
        return {
          'success': false,
          'error': 'Token expired',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Public token access for services that make direct HTTP calls
  Future<String?> getToken() => _getToken();

  // Проверка наличия токена
  Future<bool> hasToken() async {
    final token = await _getToken();
    return token != null;
  }

  // ⭐ СМЕНА ИМЕНИ ПОЛЬЗОВАТЕЛЯ
  Future<Map<String, dynamic>> changeUsername(String newName) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': newName,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'username': data['username'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error': data['message'] ?? 'Это имя зарезервировано системой. Пожалуйста, выберите другое',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error': data['message'] ?? 'Превышен лимит попыток смены имени',
          'nextChangeDate': data['nextChangeDate'], // ⭐ ДАТА СЛЕДУЮЩЕЙ ВОЗМОЖНОСТИ
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Ошибка смены имени',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ⭐ ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final userJson = data['data']?['user'] ?? data['user'];
        return {
          'success': true,
          'user': userJson,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get user data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // 🎯 ГЛОБАЛЬНЫЙ ПОИСК ПОЛЬЗОВАТЕЛЕЙ
  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      // строим URI безопасно, чтобы избежать проблем с пробелами и спецсимволами
      final uri = Uri.parse('$_baseUrl/users/search').replace(
        queryParameters: {'query': query},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // поддерживаем обе возможные структуры ответа
        final usersList = data['data']?['users'] ?? data['users'] ?? [];
        return {
          'success': true,
          'users': usersList,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to search users',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ⭐ ПРОВЕРКА СТАТУСА ВЕРИФИКАЦИИ
  Future<Map<String, dynamic>> checkVerificationStatus(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/check-verification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'verified': data['verified'] ?? false,
          'message': data['message'] ?? 'Verification checked',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Verification check failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ⭐ АКТИВАЦИЯ PREMIUM
  Future<Map<String, dynamic>> activatePremium(String code) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/premium/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': code}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Premium activated successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Activation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Восстановление доступа
  Future<void> recoverAccess(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/recovery'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) throw Exception('Recovery failed');
  }

  // ⭐ СОЗДАНИЕ ЧАТА
  Future<Map<String, dynamic>> createChat(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final response = await http.post(
        Uri.parse('$_baseUrl/chats/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'roomId': data['roomId'] ?? data['data']?['roomId'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to create chat',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ⭐ ПОЛУЧЕНИЕ СПИСКА ЧАТОВ
  Future<Map<String, dynamic>> listChats() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final response = await http.get(
        Uri.parse('$_baseUrl/chats/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'rooms': data['rooms'] ?? data['data']?['rooms'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to load chats',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Выход
  Future<void> logout() async {
    await _clearToken();
  }

  // ── VPN ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getVpnServers({String? purpose}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final uri = Uri.parse('$_baseUrl/vpn/servers').replace(
        queryParameters: purpose != null ? {'purpose': purpose} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final servers = data['servers'] ?? data['data']?['servers'] ?? [];
        return {'success': true, 'servers': servers};
      }
      return {'success': false, 'error': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getVpnConfig(String nodeId, {bool fullJson = false}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final uri = Uri.parse('$_baseUrl/vpn/config/$nodeId').replace(
        queryParameters: fullJson ? {'format': 'json'} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final config = data['data'] ?? data;
        return {'success': true, 'data': config};
      }
      return {'success': false, 'error': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
