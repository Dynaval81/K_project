import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knoty/services/api_service.dart';
import 'package:knoty/data/models/user_model.dart';

/// HAI3 Core: Auth state — JWT + Matrix token.
class AuthController extends ChangeNotifier {
  AuthController({this.onUserLoaded});

  final void Function(User?)? onUserLoaded;
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();

  static const _jwtKey = 'auth_token';
  static const _matrixTokenKey = 'matrix_token';
  static const _matrixUserIdKey = 'matrix_user_id';

  bool _isAuthenticated = false;
  bool _isLoading = false;
  User? _currentUser;
  String? _matrixToken;
  String? _matrixUserId;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get matrixToken => _matrixToken;
  String? get matrixUserId => _matrixUserId;

  // ── Restore session on app start ──────────────────────────────────────────

  Future<void> tryRestoreSession() async {
    final jwt = await _storage.read(key: _jwtKey);
    if (jwt == null || jwt.isEmpty) return; // нет сохранённой сессии
    // Базовая валидация JWT формата (3 части через точку)
    if (jwt.split('.').length != 3) {
      await _clearSession();
      return;
    }

    _matrixToken = await _storage.read(key: _matrixTokenKey);
    _matrixUserId = await _storage.read(key: _matrixUserIdKey);

    try {
      final result = await _api.getUser();
      if (result['success'] == true) {
        final userData = result['user'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          _isAuthenticated = true;
          notifyListeners();
          onUserLoaded?.call(_currentUser);
        } else {
          await _clearSession();
        }
      } else {
        await _clearSession();
      }
    } on SocketException {
      // Нет сети — оставляем сессию, юзер залогинен по кэшу
      _isAuthenticated = true;
      notifyListeners();
    } on TimeoutException {
      // Таймаут — то же самое
      _isAuthenticated = true;
      notifyListeners();
    } catch (_) {
      // Неизвестная ошибка — безопаснее выйти
      await _clearSession();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.login(email: identifier, password: password);

      if (result['success'] == true) {
        // FIX #1: Сохраняем JWT токен
        final jwt = result['token'] ??
            result['data']?['token'] ??
            result['accessToken'];
        if (jwt != null) {
          await _storage.write(key: _jwtKey, value: jwt.toString());
        }

        // Сохраняем Matrix токены
        final matrixToken = result['matrixAccessToken'] ??
            result['data']?['matrixAccessToken'];
        final matrixUserId =
            result['matrixUserId'] ?? result['data']?['matrixUserId'];

        if (matrixToken != null) {
          await _storage.write(
              key: _matrixTokenKey, value: matrixToken.toString());
          _matrixToken = matrixToken.toString();
        }
        if (matrixUserId != null) {
          await _storage.write(
              key: _matrixUserIdKey, value: matrixUserId.toString());
          _matrixUserId = matrixUserId.toString();
        }

        final userData = result['user'] ?? result['data']?['user'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          onUserLoaded?.call(_currentUser);
        }

        _isAuthenticated = true;
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Netzwerkfehler: ${e.toString()}',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> _clearSession() async {
    await Future.wait([
      _storage.delete(key: _jwtKey),
      _storage.delete(key: _matrixTokenKey),
      _storage.delete(key: _matrixUserIdKey),
    ]);
    _isAuthenticated = false;
    _currentUser = null;
    _matrixToken = null;
    _matrixUserId = null;
    onUserLoaded?.call(null);
  }
}