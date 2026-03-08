import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knoty/core/constants/app_constants.dart';
import 'package:knoty/l10n/app_localizations.dart';
import 'package:knoty/presentation/atoms/airy_input_field.dart';
import 'package:knoty/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _activationCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasActivationCode = false;

  // School selection
  String? _selectedSchool;
  String? _selectedClass;

  // Demo list — will come from backend
  final List<String> _schools = [
    'Goethe-Gymnasium München',
    'Schiller-Realschule Berlin',
    'Humboldt-Gesamtschule Hamburg',
    'Andere Schule',
  ];

  final List<String> _classes = [
    '1a', '1b', '2a', '2b', '3a', '3b',
    '4a', '4b', '5a', '5b', '6a', '6b',
    '7a', '7b', '8a', '8b', '9a', '9b',
    '10a', '10b', '11', '12', '13',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _activationCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;

    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      _showError('Bitte Vor- und Nachname eingeben');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError(l10n.registerEmailHint);
      return;
    }
    if (_passwordController.text.length < AppConstants.minPasswordLength) {
      _showError(l10n.registerPasswordHint);
      return;
    }
    if (!_hasActivationCode && _selectedSchool == null) {
      _showError('Bitte Schule auswählen');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // TODO: connect to real Knoty API
      // Fields to send: firstName, lastName, email, password,
      // activationCode OR (schoolId + classId)
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.go('/register-success', extra: {
        'nickname': '$firstName $lastName',
        'vtalkNumber': '',
      });
    } catch (e) {
      if (mounted) _showError(l10n.errorUnknown);
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
    final l10n = AppLocalizations.of(context)!;

    return Theme(
      data: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6B800).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.school_rounded,
                            size: 32, color: Color(0xFFE6B800)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Knoty',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 8,
                            color: Color(0xFF1A1A1A),
                          )),
                      const SizedBox(height: 32),

                      // Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.registerTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                )),
                            const SizedBox(height: 4),
                            Text(l10n.registerSubtitle,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF6B6B6B))),
                            const SizedBox(height: 20),

                            // Name row
                            Row(
                              children: [
                                Expanded(
                                  child: AiryInputField(
                                    controller: _firstNameController,
                                    label: 'Vorname',
                                    hint: 'Max',
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AiryInputField(
                                    controller: _lastNameController,
                                    label: 'Nachname',
                                    hint: 'Mustermann',
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            AiryInputField(
                              controller: _emailController,
                              label: l10n.registerEmailLabel,
                              hint: l10n.registerEmailHint,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            AiryInputField(
                              controller: _passwordController,
                              label: l10n.registerPasswordLabel,
                              hint: l10n.registerPasswordHint,
                              obscureText: _obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.greyText,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Activation code toggle
                            Row(
                              children: [
                                Checkbox(
                                  value: _hasActivationCode,
                                  onChanged: (v) => setState(
                                      () => _hasActivationCode = v ?? false),
                                  activeColor: const Color(0xFFE6B800),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                const Flexible(
                                  child: Text(
                                    'Ich habe einen Aktivierungscode',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A)),
                                  ),
                                ),
                              ],
                            ),

                            // Code OR school selector
                            const SizedBox(height: 12),
                            if (_hasActivationCode) ...[
                              AiryInputField(
                                controller: _activationCodeController,
                                label: 'Aktivierungscode',
                                hint: 'KNOTY-XXXX-XXXX',
                                keyboardType: TextInputType.text,
                              ),
                            ] else ...[
                              // School dropdown
                              _DropdownField(
                                label: 'Schule',
                                hint: 'Schule auswählen',
                                value: _selectedSchool,
                                items: _schools,
                                onChanged: (v) =>
                                    setState(() => _selectedSchool = v),
                              ),
                              const SizedBox(height: 16),
                              // Class dropdown
                              _DropdownField(
                                label: 'Klasse',
                                hint: 'Klasse auswählen',
                                value: _selectedClass,
                                items: _classes,
                                onChanged: (v) =>
                                    setState(() => _selectedClass = v),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6B800)
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        size: 16, color: Color(0xFFE6B800)),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Dein Konto wird vom Schuladministrator geprüft.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B6B6B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6B800),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(l10n.registerButton,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Footer — fixed at bottom, не залезает на кнопку
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  border: Border(
                    top: BorderSide(color: Colors.black.withOpacity(0.06)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.auth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(text: l10n.registerHaveAccount),
                              TextSpan(
                                text: l10n.registerLogin,
                                style: const TextStyle(
                                  color: Color(0xFFE6B800),
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
    );
  }
}

// Dropdown field widget
class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6B6B))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint,
                  style: const TextStyle(
                      color: Colors.black38, fontSize: 15)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF6B6B6B)),
              items: items
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s,
                            style: const TextStyle(fontSize: 15)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}