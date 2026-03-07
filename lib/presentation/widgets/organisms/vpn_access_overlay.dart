import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/data/models/user_model.dart';
import 'package:vtalk_app/services/api_service.dart';

/// Оверлей поверх VPN экрана — запрашивает код доступа.
class VpnAccessOverlay extends StatefulWidget {
  final VoidCallback onAccessGranted;

  const VpnAccessOverlay({super.key, required this.onAccessGranted});

  @override
  State<VpnAccessOverlay> createState() => _VpnAccessOverlayState();
}

class _VpnAccessOverlayState extends State<VpnAccessOverlay> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Введите код доступа');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService().activatePremium(code);
      debugPrint('[VPN_ACCESS] result: $result');
      if (!mounted) return;

      if (result['success'] == true) {
        // Обновляем AuthController если сервер вернул обновлённого юзера
        final userJson = result['user'];
        if (userJson != null) {
          final user = User.fromJson(userJson as Map<String, dynamic>);
          context.read<AuthController>().updateUser(user);
        } else {
          // Сервер не вернул юзера — перезапрашиваем
          await context.read<AuthController>().refreshUser();
        }
        widget.onAccessGranted();
      } else {
        setState(() => _error = result['error'] ?? 'Неверный код');
      }
    } catch (e) {
      setState(() => _error = 'Ошибка сети');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withOpacity(0.75),
            child: SafeArea(
              child: SingleChildScrollView( // ⭐ фикс overflow при landscape
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.vpn_lock_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'VPN Access',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Введите код для получения доступа к VPN',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [AppShadows.sm],
                        ),
                        child: TextField(
                          controller: _codeController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'XXXX-XXXX',
                            hintStyle: TextStyle(
                              color: AppColors.onSurfaceVariant.withOpacity(0.4),
                              letterSpacing: 4,
                              fontSize: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            errorText: _error,
                          ),
                          onSubmitted: (_) => _activate(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _activate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Активировать',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}