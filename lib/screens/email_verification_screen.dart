import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import '../providers/user_provider.dart';
import 'package:knoty/data/models/user_model.dart';
import 'main_app.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String username;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassKit.liquidGlass(
              radius: 20,
              isDark: isDark,
              opacity: 0.15,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Иконка письма
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Заголовок
                    const Text(
                      'Check your email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Email
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Username с VT-номером
                    Text(
                      'VT-ID: ${widget.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Описание
                    Text(
                      'We sent you a confirmation email. Please check your inbox (including spam folder).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Кнопка подтверждения
                    if (!_isConfirmed)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'I have verified my email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    
                    // Сообщение об успехе
                    if (_isConfirmed)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Email подтвержден!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Перенаправление в приложение...',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirmation() async {
    if (_isLoading) return; // ⭐ ЗАЩИТА ОТ МНОГОКРАТНЫХ КЛИКОВ
    
    setState(() => _isLoading = true);

    try {
      // ⭐ ЗАДЕРЖКА ДЛЯ ОБНОВЛЕНИЯ БАЗЫ ДАННЫХ
      await Future.delayed(const Duration(seconds: 2));
      
      // ⭐ ЗАПРАШИВАЕМ СВЕЖИЕ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ
      final userResult = await AuthService().getMe();
      
      if (userResult['success']) {
        final user = userResult['user'];
        if (user['emailVerified'] == true) {
          // ✅ ВЕРИФИКАЦИЯ ПОДТВЕРЖДЕНА - ОБНОВЛЯЕМ STATE
          setState(() {
            _isLoading = false;
            _isConfirmed = true;
          });

          // 🎯 ОБНОВЛЯЕМ USER PROVIDER STATE
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(User.fromJson(user));
          
          print('🔍 User state updated: ${userProvider.user}'); // 🎯 DEBUG LOG

          // Задержка перед переходом
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => MainApp(initialTab: 0)),
            );
          }
        } else {
          // ❌ ВЕРИФИКАЦИЯ ЕЩЕ НЕ ПОДТВЕРЖДЕНА
          setState(() => _isLoading = false);
          _showError('Email not verified yet. Check your inbox.');
        }
      } else {
        setState(() => _isLoading = false);
        _showError(userResult['error'] ?? 'Failed to check verification status');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Ошибка: ${e.toString()}');
    }
  }

  void _showError(String message) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white
                      : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
