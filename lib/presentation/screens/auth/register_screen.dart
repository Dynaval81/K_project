import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knoty/l10n/app_localizations.dart';
import 'package:knoty/core/constants.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/presentation/atoms/airy_input_field.dart';
import 'package:knoty/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Step 0 = email+password, Step 1 = username
  int _step = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _stepController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
    _fadeController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _goToUsername() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Введите корректный email');
      return;
    }
    if (password.length < 6) {
      _showError('Пароль минимум 6 символов');
      return;
    }
    setState(() => _step = 1);
    _stepController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      _usernameFocus.requestFocus();
    });
  }

  void _goBack() {
    setState(() => _step = 0);
    _stepController.reverse();
    Future.delayed(const Duration(milliseconds: 100), () {
      _emailFocus.requestFocus();
    });
  }

  Future<void> _onRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    setState(() => _isLoading = true);
    try {
      final result = await ApiService().register(
        email: email,
        password: password,
        username: username.isNotEmpty ? username : null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'];
        final vtNumber = user?['vtNumber']?.toString() ?? '';
        final name = user?['username']?.toString() ?? email.split('@')[0];
        context.go('/verify-email', extra: {
          'email': email,
          'nickname': name,
          'vtalkNumber': vtNumber,
        });
      } else {
        _showError(result['error'] ?? 'Ошибка регистрации');
        _goBack();
      }
    } catch (e) {
      _showError('Ошибка сети');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 50;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_step == 1) {
            _goBack();
          } else {
            context.go(AppRoutes.auth);
          }
        }
      },
      child: Theme(
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F3F5),
            hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.35), fontSize: 15),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // ── Logo ──────────────────────────────────
                          Image.asset(
                            'assets/images/logo_bnb.png',
                            width: 100,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "VTALK",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 10,
                              color: AppColors.primary,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Создать аккаунт',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Card ──────────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [AppShadows.md],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              child: _step == 0
                                  ? _buildStepCredentials()
                                  : _buildStepUsername(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Primary Button ────────────────────────
                          _ZenButton(
                            onPressed: _isLoading
                                ? () {}
                                : (_step == 0 ? _goToUsername : _onRegister),
                            backgroundColor: AppColors.primary,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    _step == 0 ? 'Продолжить' : 'Зарегистрироваться',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // ── Footer ────────────────────────────────────────
                  if (!keyboardVisible)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        border: Border(
                          top: BorderSide(
                              color: AppColors.onSurface.withOpacity(0.06),
                              width: 1),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.auth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  children: [
                                    const TextSpan(text: 'Уже есть аккаунт? '),
                                    TextSpan(
                                      text: 'Войти',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 0: Email + Password ──────────────────────────────────────
  Widget _buildStepCredentials() {
    return Column(
      key: const ValueKey('step_credentials'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiryInputField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: 'Email',
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        AiryInputField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: 'Пароль',
          hint: '••••••••',
          obscureText: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          onSubmitted: (_) => _goToUsername(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  // ── Step 1: Username ──────────────────────────────────────────────
  Widget _buildStepUsername() {
    return Column(
      key: const ValueKey('step_username'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: AppColors.onSurface),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _emailController.text.trim(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AiryInputField(
          controller: _usernameController,
          focusNode: _usernameFocus,
          label: 'Никнейм (необязательно)',
          hint: 'username',
          keyboardType: TextInputType.name,
          onSubmitted: (_) => _onRegister(),
        ),
        const SizedBox(height: 8),
        Text(
          'Если не указать — сгенерируется автоматически',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ZenButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  const _ZenButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Center(child: child),
        ),
      ),
    );
  }
}
