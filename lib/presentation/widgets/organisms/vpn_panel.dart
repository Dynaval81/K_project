import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/vpn_controller.dart';
import 'package:vtalk_app/data/models/server_model.dart';
import 'package:vtalk_app/presentation/atoms/vpn_connect_button.dart';
import 'package:vtalk_app/presentation/widgets/molecules/premium_bottom_sheet.dart';
import 'package:vtalk_app/presentation/molecules/server_picker.dart';
import 'package:vtalk_app/presentation/molecules/split_tunneling_toggle.dart';

class VpnPanel extends StatelessWidget {
  const VpnPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnController>(
      builder: (context, vpn, _) {
        final servers = vpn.servers;

        return Container(
          color: AppColors.surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VpnConnectButton(
                  isConnected: vpn.isConnected,
                  isConnecting: vpn.isConnecting,
                  onPressed: () => vpn.toggleConnection(),
                ),

                // Бейдж авто-выбранного сервера
                if (vpn.isConnected && vpn.autoMode && vpn.selectedServer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _AutoConnectedBadge(server: vpn.selectedServer!),
                  ),

                const SizedBox(height: 24),

                if (servers.isNotEmpty)
                  ServerPicker(
                    servers: servers,
                    selectedServer: vpn.selectedServer ?? servers.first,
                    onServerSelected: (s) => vpn.selectServer(s),
                  ),

                const SizedBox(height: 16),
                SplitTunnelingToggle(
                  value: vpn.routingMode != VpnRoutingMode.full,
                  onChanged: (enabled) => vpn.setRoutingMode(
                    enabled ? VpnRoutingMode.vtalkOnly : VpnRoutingMode.full,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AutoConnectedBadge extends StatelessWidget {
  final ServerModel server;
  const _AutoConnectedBadge({required this.server});

  @override
  Widget build(BuildContext context) {
    final protocol = server.configType.toUpperCase();
    final ping = context.watch<VpnController>().pingFor(server.nodeId);
    final pingText = ping != null ? ' • ${ping}ms' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Авто: ${server.location} • $protocol$pingText',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}