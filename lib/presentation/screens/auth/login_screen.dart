import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:knoty/l10n/app_localizations.dart';
import 'package:knoty/core/constants.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/core/controllers/auth_controller.dart';
import 'package:knoty/presentation/atoms/airy_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Step 0 = enter login, Step 1 = enter password
  int _step = 0;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  int _loginMethodIndex = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Step transition animation
  late final AnimationController _stepController;
  late final Animation<Offset> _slideOut;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _stepFade;

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
    _slideOut = Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
        .animate(CurvedAnimation(parent: _stepController, curve: Curves.easeInCubic));
    _slideIn = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepController, curve: Curves.easeOutCubic));
    _stepFade = CurvedAnimation(parent: _stepController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _goToPassword() {
    final identifier = _loginController.text.trim();
    if (identifier.isEmpty) {
      _showError(AppLocalizations.of(context)!.loginErrorEmpty);
      return;
    }
    setState(() => _step = 1);
    _stepController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      _passwordFocus.requestFocus();
    });
  }

  void _goBack() {
    setState(() => _step = 0);
    _stepController.reverse();
    Future.delayed(const Duration(milliseconds: 100), () {
      _loginFocus.requestFocus();
    });
  }

  Future<void> _onLogin() async {
    final identifier = _loginController.text.trim();
    final password = _passwordController.text;

    if (password.isEmpty) {
      _showError(AppLocalizations.of(context)!.loginEnterPassword);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await context.read<AuthController>().loginWithCredentials(
        identifier: identifier,
        password: password,
      );
      if (!mounted) return;

      if (result.success) {
        context.go(AppRoutes.home);
      } else if (result.isEmailNotVerified) {
        _showError(AppLocalizations.of(context)!.loginErrorEmailVerification);
        _goBack();
      } else {
        _showError(result.error ?? AppLocalizations.of(context)!.loginErrorGeneric);
        _goBack();
      }
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.loginErrorNetwork);
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

  void _selectMethod(int index) {
    if (_loginMethodIndex == index) return;
    setState(() => _loginMethodIndex = index);
  }

  String _getLoginHint(AppLocalizations l10n) {
    switch (_loginMethodIndex) {
      case 0: return 'Spitzname';
      case 1: return 'Knoty-ID';
      case 2: return l10n.loginHintEmail;
      default: return 'Spitzname';
    }
  }

  TextInputType _getKeyboardType() {
    switch (_loginMethodIndex) {
      case 0: return TextInputType.name;
      case 1: return TextInputType.visiblePassword;
      case 2: return TextInputType.emailAddress;
      default: return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 50;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_step == 1) {
            _goBack();
          }
        }
      },
      child: Theme(
        // Force light theme on login screen regardless of system theme
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F3F5),
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.35), fontSize: 15),
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
                        const SizedBox(height: 40),

                        // ── Card ──────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [AppShadows.md],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: ClipRect(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              child: _step == 0
                                  ? _buildStepLogin(l10n)
                                  : _buildStepPassword(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Primary Button ────────────────────────
                        _ZenButton(
                          onPressed: _isLoading
                              ? () {}
                              : (_step == 0 ? _goToPassword : _onLogin),
                          backgroundColor: AppColors.primary,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _step == 0
                                      ? AppLocalizations.of(context)!.loginPrimaryButton
                                      : AppLocalizations.of(context)!.loginButtonLogin,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),

                        const SizedBox(height: 24),
                        _ZenDivider(label: AppLocalizations.of(context)!.loginDividerOr),
                        const SizedBox(height: 24),

                        _ZenButton(
                          onPressed: () => _showError(AppLocalizations.of(context)!.loginGoogleSoon),
                          backgroundColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded,
                                  color: AppColors.onSurface, size: 32),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.loginGoogle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ZenButton(
                          onPressed: () => _showError(AppLocalizations.of(context)!.loginAppleSoon),
                          backgroundColor: AppColors.onSurface,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.loginApple,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // ── Footer — hidden when keyboard open ─────────────
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
                        onTap: () =>
                            context.go('/register'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                                children: [
                                  TextSpan(text: AppLocalizations.of(context)!.loginNoAccount),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.loginRegister,
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
        ), // Scaffold
      ), // Theme
    );
  }

  // ── Step 0: Enter login ───────────────────────────────────────────
  Widget _buildStepLogin(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('step_login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiryInputField(
          controller: _loginController,
          focusNode: _loginFocus,
          label: 'Login',
          hint: _getLoginHint(l10n),
          keyboardType: _getKeyboardType(),
          onSubmitted: (_) => _goToPassword(),
        ),
        const SizedBox(height: 16),
        _MethodSelector(
          selected: _loginMethodIndex,
          labels: [
            'Spitzname',
            'Knoty-ID',
            l10n.loginMethodEmail,
          ],
          onSelect: _selectMethod,
        ),
      ],
    );
  }

  // ── Step 1: Enter password ────────────────────────────────────────
  Widget _buildStepPassword() {
    return Column(
      key: const ValueKey('step_password'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Who you're logging in as
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
                _loginController.text.trim(),
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
        // Password field
        AiryInputField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: AppLocalizations.of(context)!.loginPasswordLabel,
          hint: AppLocalizations.of(context)!.loginPasswordHint,
          obscureText: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          onSubmitted: (_) => _onLogin(),
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
    final isLight = backgroundColor == Colors.white;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isLight
            ? Border.all(color: AppColors.onSurface.withOpacity(0.08))
            : null,
        boxShadow: [
          isLight
              ? AppShadows.sm
              : BoxShadow(
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

class _MethodSelector extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  const _MethodSelector({
    required this.selected,
    required this.labels,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active ? [AppShadows.sm] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ZenDivider extends StatelessWidget {
  final String label;
  const _ZenDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.onSurface.withOpacity(0.06))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label,
              style: TextStyle(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 12)),
        ),
        Expanded(child: Divider(color: AppColors.onSurface.withOpacity(0.06))),
      ],
    );
  }
}
