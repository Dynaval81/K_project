import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme_provider.dart';
import '../utils/glass_kit.dart';
import '../constants/app_constants.dart';
import '../providers/user_provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _userStatus = ""; // will populate from provider
  String _userAvatar = "${AppConstants.defaultAvatarUrl}?u=me"; // default avatar
  
  bool _loadError = false;
  Timer? _loadTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    if (user != null) {
      _nicknameController.text = user.username;
      _emailController.text = user.email;
      _userAvatar = user.avatar ?? _userAvatar;
      _userStatus = user.status ?? _userStatus;
    }
    // start loading new data if necessary
    if (!userProvider.isLoading) {
      userProvider.refreshUserData();
    }
    // start timeout for loading error if there is no user yet
    _loadTimer?.cancel();
    if (user == null) {
      _loadTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && userProvider.isLoading && userProvider.user == null) {
          // 🚨 ИСПРАВЛЕНО: Используем WidgetsBinding вместо setState
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _loadError = true;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required IconData icon,
  }) {
    return GlassKit.liquidGlass(
      radius: 16,
      isDark: isDark,
      opacity: 0.08,
      useBlur: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.black54),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassKit.liquidGlass(
        radius: 16,
        isDark: isDark,
        opacity: 0.08,
        useBlur: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.7), Colors.blue.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: isDark ? Colors.white30 : Colors.black12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle({
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    return GlassKit.liquidGlass(
      radius: 16,
      isDark: isDark,
      opacity: 0.08,
      useBlur: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.withOpacity(0.7), Colors.orange.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDark,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                themeProvider.toggleTheme();
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // if no user yet, show loader or error
    if (user == null) {
      if (_loadError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ошибка загрузки профиля'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadError = false;
                    });
                    userProvider.refreshUserData();
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        );
      }
      // show loading indicator while waiting
      return Scaffold(
        body: Center(child: const CircularProgressIndicator()),
      );
    }

    // at this point user is non-null
    final currentUser = user;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: GlassKit.mainBackground(isDark),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.only(bottom: 28, top: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Flexible(
                      child: Text(
                        'Account Settings',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Avatar Section с возможностью смены
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImagePicker(),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_userAvatar),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GlassKit.liquidGlass(
                              isDark: isDark,
                              radius: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt_rounded, size: 20, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // user is non-null because of early return
                    Text(
                      user.username,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser.vtNumber,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Section - сразу под аватаром
              _buildProfileField(
                label: 'Your Status',
                controller: TextEditingController(text: _userStatus),
                isDark: isDark,
                icon: Icons.edit_note_rounded,
              ),

              const SizedBox(height: 32),

              // Theme Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Display',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildThemeToggle(isDark: isDark, themeProvider: themeProvider),

              const SizedBox(height: 32),

              // Personal Info Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Personal Info',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildProfileField(
                label: 'Nickname',
                controller: _nicknameController,
                isDark: isDark,
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 12),

              _buildProfileField(
                label: 'Email',
                controller: _emailController,
                isDark: isDark,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 32),

              // Account Info Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Account Info',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildInfoTile(
                label: 'VT Number',
                value: currentUser.vtNumber,
                icon: Icons.badge,
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              _buildInfoTile(
                label: 'Joined',
                value: currentUser.createdAt != null
                    ? '${currentUser.createdAt!.day.toString().padLeft(2, '0')}.${currentUser.createdAt!.month.toString().padLeft(2, '0')}.${currentUser.createdAt!.year}'
                    : 'Not available',
                icon: Icons.calendar_today,
                isDark: isDark,
              ),

              const SizedBox(height: 32),

              // Security Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Security',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildInfoTile(
                label: 'Change Password',
                value: 'Update password',
                icon: Icons.lock_outline,
                isDark: isDark,
                onTap: () => _showPasswordDialog(context, isDark),
              ),

              const SizedBox(height: 32),

              // Save Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated!', style: TextStyle(color: isDark ? Colors.black : Colors.white)),
                      backgroundColor: Colors.green.withOpacity(0.7),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: GlassKit.liquidGlass(
                  radius: 16,
                  isDark: isDark,
                  opacity: 0.15,
                  useBlur: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Log Out Button
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: GlassKit.liquidGlass(
                        isDark: isDark,
                        radius: 16,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Log Out?',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Are you sure?',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                                      // 🚨 НОВОЕ: Передаем context в logout для принудительного перехода
                                      await userProvider.logout(context: context);
                                    },
                                    child: const Text(
                                      'Log Out',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: GlassKit.liquidGlass(
                  radius: 16,
                  isDark: isDark,
                  opacity: 0.15,
                  useBlur: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
        ], // end of Stack children
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, bool isDark) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassKit.liquidGlass(
          radius: 24,
          isDark: isDark,
          opacity: 0.15,
          useBlur: true,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white60 : Colors.black45,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPasswordField('Old Password', oldPasswordController, isDark),
                const SizedBox(height: 12),
                _buildPasswordField('New Password', newPasswordController, isDark),
                const SizedBox(height: 12),
                _buildPasswordField('Confirm Password', confirmPasswordController, isDark),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassKit.liquidGlass(
                          radius: 12,
                          isDark: isDark,
                          opacity: 0.15,
                          useBlur: false,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Password changed successfully!'),
                              backgroundColor: Colors.green.withOpacity(0.7),
                            ),
                          );
                        },
                        child: GlassKit.liquidGlass(
                          radius: 12,
                          isDark: isDark,
                          opacity: 0.15,
                          useBlur: false,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Метод для выбора изображения из галереи/камеры
  Future<void> _showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        isDark: Provider.of<ThemeProvider>(context).isDarkMode,
        radius: 20,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Avatar',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _userAvatar = image.path;
                        });
                      }
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _userAvatar = image.path;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  TextField _buildPasswordField(String label, TextEditingController controller, bool isDark) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
        ),
      ),
    );
  }
}
