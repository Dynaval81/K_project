import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: GlassKit.mainBackground(isDark),
            child: SafeArea(
              child: Column(
                children: [
                  _buildCustomAppBar(context),
                  SizedBox(height: 30),
                  _buildProfileSection(),
                  SizedBox(height: 40),
                  Expanded(
                    child: GlassKit.liquidGlass(
                      radius: 30,
                      opacity: 0.15,
                      child: ListView(
                        padding: EdgeInsets.all(20),
                        children: [
                          _buildSettingItem("Dark Mode", Icons.dark_mode, trailing: Switch(
                            value: isDark,
                            onChanged: (val) {
                              themeProvider.toggleTheme();
                            },
                            activeColor: Colors.blueAccent,
                          )),
                          _buildSettingItem("Debug Glass Mode", Icons.bug_report, 
                            subtitle: "Visualize blur optimization", 
                            trailing: Switch(
                              value: themeProvider.debugGlassMode,
                              onChanged: (val) {
                                themeProvider.toggleDebugGlassMode();
                              },
                              activeColor: Colors.green,
                            )),
                          _buildSettingItem("Profile Settings", Icons.person_outline),
                          _buildSettingItem("Notifications", Icons.notifications_none),
                          _buildSettingItem("Privacy & Security", Icons.lock_outline),
                          Divider(color: Colors.white10),
                          _buildSettingItem("Logout", Icons.logout, color: Colors.redAccent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Settings", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=settings")),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          children: [
            CircleAvatar(radius: 55, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=me")),
            SizedBox(height: 15),
            Text("Dynaval81", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
            Text("@vtalk_user", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
          ],
        );
      },
    );
  }

  Widget _buildSettingItem(String title, IconData icon, {String? subtitle, Widget? trailing, Color? color}) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return ListTile(
          leading: Icon(icon, color: color ?? (isDark ? Colors.blueAccent : Colors.blue)),
          title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54, 
            fontSize: 12
          )) : null,
          trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black26),
        );
      },
    );
  }
}
