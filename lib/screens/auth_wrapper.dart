import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme_provider.dart';  // ✅ Исправлено: правильный путь
import 'main_app.dart';
import 'auth/register_screen.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Используем secure storage для проверки токена
      final token = await _secureStorage.read(key: 'auth_token');
      final userId = await _secureStorage.read(key: 'user_id');
      
      if (!mounted) return;
      
      setState(() {
        _isAuthenticated = token != null && token.isNotEmpty && userId != null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing app: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode 
          ? Color(0xFF1A1A2E) 
          : Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    return _isAuthenticated ? MainApp() : RegisterScreen();
  }
}
