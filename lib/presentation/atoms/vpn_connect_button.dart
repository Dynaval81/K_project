import 'package:flutter/material.dart';
import 'package:vtalk_app/core/constants.dart';

/// HAI3 Atom: Big VPN Connect button – clear On/Off state (Airy style).
class VpnConnectButton extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onPressed;

  const VpnConnectButton({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = isConnected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isConnecting ? null : onPressed,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOn ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isConnecting)
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOn ? AppColors.onPrimary : AppColors.primary,
                    ),
                  ),
                )
              else
                Icon(
                  isOn ? Icons.vpn_lock_rounded : Icons.vpn_lock_outlined,
                  size: 48,
                  color: isOn ? AppColors.onPrimary : AppColors.onSurface,
                ),
              const SizedBox(height: 12),
              Text(
                isConnecting ? 'Connecting...' : (isOn ? 'Connected' : 'Connect'),
                style: AppTextStyles.button.copyWith(
                  fontSize: 18,
                  color: isOn ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
