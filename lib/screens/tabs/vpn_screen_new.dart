import 'package:flutter/material.dart';
import '../../widgets/vtalk_header.dart';
import '../../utils/glass_kit.dart';

class VPNScreen extends StatelessWidget {
  final bool isLocked;

  const VPNScreen({super.key, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    if (isLocked) {
      return Scaffold(
        body: Container(
          color: bgColor,

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 50,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'VPN FEATURES LOCKED',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Activate Mercury Premium to unlock VPN capabilities',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Premium VPN Features:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(context, '🌍 Global Servers', '50+ locations worldwide'),
                      _buildFeatureItem(context, '⚡ Ultra Fast Speed', '10Gbps connection speed'),
                      _buildFeatureItem(context, '🔒 Military-Grade Encryption', 'AES-256 encryption'),
                      _buildFeatureItem(context, '📱 No-Log Policy', 'Complete privacy protection'),
                      _buildFeatureItem(context, '🎮 Gaming Mode', 'Optimized for low latency'),
                      _buildFeatureItem(context, '📊 Bandwidth Monitoring', 'Real-time usage stats'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: GlassKit.liquidGlass(
              radius: 0,
              isDark: isDark,
              opacity: 0.3,
              useBlur: true,
              child: Container(),
            ),
            expandedHeight: 200,
            title: VtalkHeader(
              title: 'VTalk VPN',
              showScrollAnimation: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.vpn_lock,
                      size: 80,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'VPN Protection Active',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure connection established',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
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

  Widget _buildFeatureItem(BuildContext context, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
