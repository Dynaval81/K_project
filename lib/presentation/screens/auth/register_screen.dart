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
  final _schoolSearchController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasActivationCode = false;

  String? _selectedSchool;
  String? _selectedClass;
  List<String> _filteredSchools = [];
  List<String> _schoolClasses = [];
  bool _showSchoolDropdown = false;

  // Demo — will come from backend
  final List<String> _allSchools = [
    'Goethe-Gymnasium München',
    'Schiller-Realschule Berlin',
    'Humboldt-Gesamtschule Hamburg',
    'Einstein-Gymnasium Frankfurt',
    'Kant-Gymnasium Köln',
    'Andere Schule',
  ];

  // Demo classes per school — will come from backend
  final Map<String, List<String>> _schoolClassMap = {
    'Goethe-Gymnasium München': ['5a','5b','6a','6b','7a','7b','8a','8b','9a','9b','10a','10b','11','12'],
    'Schiller-Realschule Berlin': ['5a','5b','6a','6b','7a','7b','8a','8b','9a','9b','10a','10b'],
    'Humboldt-Gesamtschule Hamburg': ['5a','5b','5c','6a','6b','6c','7a','7b','8a','8b','9a','9b','10a','10b','11','12','13'],
    'Einstein-Gymnasium Frankfurt': ['5a','5b','6a','6b','7a','7b','8a','9a','10a','11','12'],
    'Kant-Gymnasium Köln': ['5a','5b','6a','6b','7a','8a','9a','10a','11','12'],
    'Andere Schule': ['1','2','3','4','5','6','7','8','9','10','11','12','13'],
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _activationCodeController.dispose();
    _schoolSearchController.dispose();
    super.dispose();
  }

  void _onSchoolSearch(String query) {
    setState(() {
      _filteredSchools = query.isEmpty
          ? []
          : _allSchools
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
      _showSchoolDropdown = _filteredSchools.isNotEmpty;
    });
  }

  void _selectSchool(String school) {
    setState(() {
      _selectedSchool = school;
      _selectedClass = null;
      _schoolClasses = _schoolClassMap[school] ?? [];
      _schoolSearchController.text = school;
      _showSchoolDropdown = false;
      _filteredSchools = [];
    });
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;

    if (_firstNameController.text.trim().isEmpty) {
      _showError('Bitte Vornamen eingeben');
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showError('Bitte Nachnamen eingeben');
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
    if (_hasActivationCode && _activationCodeController.text.trim().isEmpty) {
      _showError('Bitte Aktivierungscode eingeben');
      return;
    }
    if (!_hasActivationCode && _selectedSchool == null) {
      _showError('Bitte Schule auswählen');
      return;
    }
    if (!_hasActivationCode && _selectedSchool != null && _selectedClass == null) {
      _showError('Bitte Klasse auswählen');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      final name = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      context.go('/register-success', extra: {
        'nickname': name,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Compact header
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/knoty_logo_nt.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.registerTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Fields card
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
                            // Vorname
                            AiryInputField(
                              controller: _firstNameController,
                              label: 'Vorname',
                              hint: 'Max',
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),

                            // Nachname
                            AiryInputField(
                              controller: _lastNameController,
                              label: 'Nachname',
                              hint: 'Mustermann',
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),

                            // School search
                            if (!_hasActivationCode) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AiryInputField(
                                    controller: _schoolSearchController,
                                    label: 'Schule',
                                    hint: 'Schulname eingeben...',
                                    keyboardType: TextInputType.text,
                                    onChanged: _onSchoolSearch,
                                  ),
                                  if (_showSchoolDropdown)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: _filteredSchools
                                            .map((school) => InkWell(
                                                  onTap: () =>
                                                      _selectSchool(school),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.school_outlined,
                                                            size: 16,
                                                            color: Color(
                                                                0xFFE6B800)),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(school,
                                                              style: const TextStyle(
                                                                  fontSize: 14)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Class — only after school selected
                              if (_selectedSchool != null) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Klasse',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF6B6B6B))),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F5),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedClass,
                                          hint: const Text('Klasse wählen',
                                              style: TextStyle(
                                                  color: Colors.black38,
                                                  fontSize: 15)),
                                          isExpanded: true,
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Color(0xFF6B6B6B)),
                                          items: _schoolClasses
                                              .map((c) => DropdownMenuItem(
                                                    value: c,
                                                    child: Text(c,
                                                        style: const TextStyle(
                                                            fontSize: 15)),
                                                  ))
                                              .toList(),
                                          onChanged: (v) => setState(
                                              () => _selectedClass = v),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Info box
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6B800).withOpacity(0.08),
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
                              const SizedBox(height: 16),
                            ],

                            // Email
                            AiryInputField(
                              controller: _emailController,
                              label: l10n.registerEmailLabel,
                              hint: l10n.registerEmailHint,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password
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

                            // Activation code toggle — at bottom
                            GestureDetector(
                              onTap: () => setState(
                                  () => _hasActivationCode = !_hasActivationCode),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _hasActivationCode
                                          ? const Color(0xFFE6B800)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _hasActivationCode
                                            ? const Color(0xFFE6B800)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: _hasActivationCode
                                        ? const Icon(Icons.check,
                                            size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
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
                            ),

                            if (_hasActivationCode) ...[
                              const SizedBox(height: 16),
                              AiryInputField(
                                controller: _activationCodeController,
                                label: 'Aktivierungscode',
                                hint: 'KNOTY-XXXX-XXXX',
                                keyboardType: TextInputType.text,
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
                                      color: Colors.white, strokeWidth: 2))
                              : Text(l10n.registerButton,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  border: Border(
                      top: BorderSide(color: Colors.black.withOpacity(0.06))),
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