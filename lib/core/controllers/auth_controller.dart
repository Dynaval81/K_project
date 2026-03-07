import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vtalk_app/services/api_service.dart';
import 'package:vtalk_app/data/models/user_model.dart';

/// Результат попытки логина
class AuthResult {
  final bool success;
  final String? error;
  final bool isEmailNotVerified;

  const AuthResult({
    required this.success,
    this.error,
    this.isEmailNotVerified = false,
  });

  factory AuthResult.ok() => const AuthResult(success: true);

  factory AuthResult.fail(String error, {bool isEmailNotVerified = false}) =>
      AuthResult(success: false, error: error, isEmailNotVerified: isEmailNotVerified);
}

/// HAI3 Core: Auth controller — единственный источник правды об авторизации.
///
/// Жизненный цикл:
/// 1. [tryRestoreSession] — вызывается при старте приложения.
/// 2. [loginWithCredentials] — реальный логин через POST /auth/login.
/// 3. [logout] — удаляем токен, сбрасываем состояние.
class AuthController extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────────────────────────
  final ApiService _api;
  final FlutterSecureStorage _storage;

  final void Function(User user)? onUserLoaded;
  final Future<void> Function()? onLogout;

  AuthController({
    ApiService? api,
    FlutterSecureStorage? storage,
    this.onUserLoaded,
    this.onLogout,
  })  : _api = api ?? ApiService(),
        _storage = storage ?? const FlutterSecureStorage();

  // ── State ─────────────────────────────────────────────────────────
  bool _isAuthenticated = false;
  bool _isRestoringSession = true;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoringSession => _isRestoringSession;
  User? get currentUser => _currentUser;

  // ── Session restore ───────────────────────────────────────────────

  /// Вызвать один раз при старте приложения в main().
  Future<void> tryRestoreSession() async {
    _isRestoringSession = true;
    notifyListeners();

    try {
      final hasToken = await _api.hasToken();
      if (!hasToken) {
        _setUnauthenticated();
        return;
      }

      final result = await _api.getUser();
      if (result['success'] == true && result['user'] != null) {
        final user = User.fromJson(result['user'] as Map<String, dynamic>);
        _setAuthenticated(user);
      } else {
        _setUnauthenticated();
      }
    } catch (_) {
      _setUnauthenticated();
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────

  /// Принимает email / VT-ID / никнейм — бэкенд различает сам.
  Future<AuthResult> loginWithCredentials({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _api.login(email: identifier, password: password);

      if (response['success'] == true) {
        final userJson = response['user'];
        if (userJson != null) {
          final user = User.fromJson(userJson as Map<String, dynamic>);
          _setAuthenticated(user);
        }
        return AuthResult.ok();
      }

      final isNotVerified = response['isEmailNotVerified'] == true;
      final errorMsg = response['error']?.toString() ?? 'Ошибка входа';
      return AuthResult.fail(errorMsg, isEmailNotVerified: isNotVerified);
    } catch (e) {
      return AuthResult.fail('Сетевая ошибка: ${e.toString()}');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await onLogout?.call();
    } catch (_) {}
    await _api.logout();
    _setUnauthenticated();
  }

  // ── Legacy shim ───────────────────────────────────────────────────

  /// @deprecated Используй [loginWithCredentials].
  void login() => _setAuthenticated(_currentUser ?? _placeholderUser());

  // ── Private ───────────────────────────────────────────────────────

  /// Обновляет текущего пользователя без запроса к серверу (после активации кода).
  void updateUser(User user) {
    _currentUser = user;
    onUserLoaded?.call(user);
    notifyListeners();
  }

  /// Перезапрашивает данные пользователя с сервера.
  Future<void> refreshUser() async {
    try {
      final result = await _api.getUser();
      if (result['success'] == true && result['user'] != null) {
        final user = User.fromJson(result['user'] as Map<String, dynamic>);
        _setAuthenticated(user);
      }
    } catch (e) {
      debugPrint('[AUTH] refreshUser error: \$e');
    }
  }

  void _setAuthenticated(User user) {
    _isAuthenticated = true;
    _currentUser = user;
    onUserLoaded?.call(user);
    notifyListeners();
  }

  void _setUnauthenticated() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  User _placeholderUser() => User(
        id: 'mock',
        username: 'User',
        email: '',
        vtNumber: '',
      );
}