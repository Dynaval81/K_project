import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/glass_kit.dart';
import 'main_app.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../screens/email_verification_screen.dart';
import '../providers/user_provider.dart';
import 'package:knoty/data/models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  bool _isLogin = true; // Переключатель между Входом и Регистрацией
  
  // Контроллеры для полей ввода
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // AuthService
  final AuthService _authService = AuthService();
  
  // ApiService
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Плавный цикл 4 секунды
      vsync: this,
    )..repeat(reverse: true); // Зацикливаем туда-обратно

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Наш фирменный фон
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: GlassKit.mainBackground(isDark),
          ),
          
          // 2. Основной контент
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // ПУЛЬСИРУЮЩАЯ СФЕРА
                    ScaleTransition(
                      scale: _animation,
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: isDark 
                            ? [
                                // Для ТЕМНОЙ темы: оставляем магическое фиолетовое свечение
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [
                                // Для СВЕТЛОЙ темы: минималистичный "стеклянный" блик
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.08), // Почти прозрачный голубой
                                  blurRadius: 15, 
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4), // Смещаем тень чуть вниз для объема
                                ),
                              ],
                        ),
                        child: Image.asset('assets/images/app_logo_mercury.png'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // ЗАГОЛОВОК - СЛОГАН
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14, 
                          letterSpacing: 2, 
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54
                        ),
                        children: [
                          TextSpan(text: "VPN "),
                          TextSpan(text: "• ", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.normal)),
                          TextSpan(text: "CHAT "),
                          TextSpan(text: "• ", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.normal)),
                          TextSpan(text: "AI"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),

                    // ПОЛЯ ВВОДА (Стеклянные) с анимацией
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _isLogin 
                          ? _buildLoginFields(isDark)
                          : _buildRegisterFields(isDark),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),

                    // КНОПКА ВХОДА ИЛИ ЗАГРУЗКА
                    _isLoading 
                        ? _buildLoadingIndicator()
                        : _buildMercuryButton(_isLogin ? "START SESSION" : "GENERATE IDENTITY"),
                    
                    const SizedBox(height: 30),
                    
                    // ПЕРЕКЛЮЧАТЕЛЬ ВХОД/РЕГИСТРАЦИЯ
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          children: [
                            TextSpan(text: _isLogin ? "New here? " : "Already have account? "),
                            TextSpan(
                              text: _isLogin ? "Create Identity" : "Sign In",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Генератор VT-ID
  String generateVTID() {
    final random = Random();
    int number = random.nextInt(90000) + 10000; // 5 знаков
    return "VT-$number"; // С префиксом VT-
  }

  // Виджет полей регистрации
  Widget _buildRegisterFields(bool isDark) {
    return Column(
      children: [
        _buildAuthField(
          icon: Icons.face_rounded, 
          hint: "Username / Nickname", 
          isDark: isDark,
          controller: _usernameController,
        ),
        const SizedBox(height: 16),
        _buildAuthField(
          icon: Icons.alternate_email_rounded, 
          hint: "Email Address", 
          isDark: isDark,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        _buildAuthField(
          icon: Icons.lock_outline_rounded, 
          hint: "Create Access Key", 
          isDark: isDark, 
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 16),
        _buildAuthField(
          icon: Icons.verified_user_outlined, 
          hint: "Confirm Access Key", 
          isDark: isDark, 
          isPassword: true,
          controller: _confirmPasswordController,
        ),
      ],
    );
  }

  // Виджет полей входа
  Widget _buildLoginFields(bool isDark) {
    return Column(
      children: [
        _buildAuthField(
          icon: Icons.alternate_email_rounded, 
          hint: "Login (VT-XXXXX / Nickname / Email)", 
          isDark: isDark,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        _buildAuthField(
          icon: Icons.lock_outline_rounded, 
          hint: "Access Key", 
          isDark: isDark, 
          isPassword: true,
          controller: _passwordController,
        ),
      ],
    );
  }

  // Вспомогательный виджет для стеклянных полей
  Widget _buildAuthField({
    required IconData icon, 
    required String hint, 
    required bool isDark, 
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // Кнопка в стиле Mercury
  Widget _buildMercuryButton(String text) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purpleAccent.withOpacity(0.8),
            Colors.blueAccent.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () async {
            if (_isLogin) {
              // ЛОГИКА ВХОДА
              await _handleLogin();
            } else {
              // ЛОГИКА РЕГИСТРАЦИИ
              await _handleRegistration();
            }
          },
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Индикатор загрузки
  Widget _buildLoadingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: const Center(
        child: SizedBox(
          width:24,
          height:24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  // Обработчик входа
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Валидация
      if (email.isEmpty || password.isEmpty) {
        _showGlassError('Please fill all fields');
        return;
      }

      // Вызываем реальное API
      final result = await _apiService.login(email: email, password: password);

      if (result['success']) {
        // 🎯 ПРОВЕРКА isFirstLogin ФЛАГА (БЕЗОПАСНОЕ ПРИВЕДЕНИЕ)
        final isFirstLogin = result['isFirstLogin']?.toString() == 'true' || result['isFirstLogin'] == true;
        
        print('🔍 Login Response: $result'); // 🎯 DEBUG PRINT
        print('🔍 isFirstLogin: $isFirstLogin'); // 🎯 DEBUG PRINT
        
        if (isFirstLogin) {
          // ПЕРВЫЙ ВХОД - MAINAPP С ОТКРЫТЫМ ПРОФИЛЕМ
          Navigator.pushReplacement(
            context, 
            CupertinoPageRoute(builder: (context) => MainApp(initialTab: 3)), // 3 = Dashboard
          );
        } else {
          // ОБЫЧНЫЙ ВХОД - CHATS
          Navigator.pushReplacement(
            context, 
            CupertinoPageRoute(builder: (context) => MainApp(initialTab: 0)),
          );
        }
      } else {
        // ⭐ ПРОВЕРКА НА EMAIL NOT VERIFIED
        if (result['isEmailNotVerified'] == true) {
          _showEmailNotVerifiedAlert(result['error'] ?? 'Email not verified');
        } else {
          _showGlassError(result['error'] ?? 'Login failed');
        }
      }
    } catch (e) {
      _showGlassError('Network error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Обработчик регистрации
  Future<void> _handleRegistration() async {
    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      // 🎯 БЛОКИРОВКА ДО ВВОДА ПАРОЛЯ
      if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        _showGlassError('Please fill all fields');
        return;
      }

      // 🎯 ДЕМО КОСТЫЛЬ - БЫСТРЫЙ ВХОД
      if (email == "1" && password == "1") {
        setState(() => _isLoading = false);
        _showDemoSuccessDialog();
        return;
      }

      // Валидация пароля
      if (!_authService.isValidPassword(password)) {
        _showGlassError('Password must be at least 6 characters');
        return;
      }

      if (password != confirmPassword) {
        _showGlassError('Passwords do not match');
        return;
      }

      // Вызываем реальное API
      final result = await _apiService.register(
        email: email,
        password: password,
        username: username.isEmpty ? null : username,  // Отправляем null если пусто
      );

      if (result['success']) {
        // 🎯 СОХРАНЯЕМ ТОКЕН СРАЗУ ПОСЛЕ РЕГИСТРАЦИИ
        final token = result['token'];
        final userData = result['user'];
        
        print('🔍 Register Token: $token'); // 🎯 DEBUG LOG
        print('🔍 Register User Data: $userData'); // 🎯 DEBUG LOG
        
        if (token != null && userData != null) {
          // 🎯 ОБНОВЛЯЕМ USER PROVIDER
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(User.fromJson(userData));
          
          print('🔍 User Provider Updated: ${userProvider.user}'); // 🎯 DEBUG LOG
        }
        
        // ⭐ НОВЫЙ ФЛОУ - ПЕРЕХОДИМ НА ВЕРИФИКАЦИЮ
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => EmailVerificationScreen(
            email: email,
            username: username ?? email.split('@')[0],
          )),
        );
      } else {
        // 🎯 ДЕТАЛЬНАЯ ОШИБКА РЕГИСТРАЦИИ
        final errorMessage = result['error'] ?? 'Registration error';
        print('Registration error: $errorMessage'); // ⭐ ДЕБАГ ЛОГ
        _showGlassError(errorMessage);
      }
    } catch (e) {
      _showGlassError('Network error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Показать стеклянную ошибку
  void _showGlassError(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Красная иконка ошибки
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Заголовок
              const Text(
                'ERROR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              
              // Текст ошибки
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70
                      : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Кнопка
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ ПОКАЗАТЬ АЛЕРТ EMAIL NOT VERIFIED
  void _showEmailNotVerifiedAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Оранжевая иконка
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Заголовок
              const Text(
                'EMAIL NOT VERIFIED',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              
              // Текст ошибки
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70
                      : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Кнопка ОК
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Показать демо успешную регистрацию
  void _showDemoSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Оранжевая иконка демо
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Заголовок
              const Text(
                'DEMO MODE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              
              // Текст
              Text(
                'Quick access to VTalk demo',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              
              // ⭐ УБИРАЕМ ПОДСКАЗКУ УЧЕТНЫХ ДАННЫХ
              Text(
                'Demo credentials activated',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white54
                      : Colors.black54,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              
              // VT-ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'VT-12345',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        // TODO: Добавить копирование в буфер
                      },
                      icon: const Icon(Icons.copy, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Кнопка
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context, 
                      CupertinoPageRoute(builder: (context) => MainApp(initialTab: 0)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ENTER DEMO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Подсказка
              Text(
                'Try: ABC123XYZ0',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white54
                      : Colors.black54,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
