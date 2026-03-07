import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/vpn_controller.dart';
import 'package:vtalk_app/data/models/server_model.dart';

/// HAI3 Zen VPN Screen — one button, two menus.
class VpnScreen extends StatefulWidget {
  const VpnScreen({super.key});

  @override
  State<VpnScreen> createState() => _VpnScreenState();
}

class _VpnScreenState extends State<VpnScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VpnController>().initialize();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(context, controller),
                  Expanded(child: _buildCenter(context, controller)),
                  _buildFooter(context, controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, VpnController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'VPN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          _StatusChip(controller: controller),
        ],
      ),
    );
  }

  // ── Center (Zen Button) ───────────────────────────────────────────
  Widget _buildCenter(BuildContext context, VpnController controller) {
    final isConnected = controller.isConnected;
    final isConnecting = controller.isConnecting ||
        controller.connectionState == VpnConnectionState.disconnecting;

    final color = isConnected
        ? const Color(0xFF34C759)
        : isConnecting
            ? const Color(0xFFFF9500)
            : AppColors.primary;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final btnSize = isLandscape ? 100.0 : 180.0;
    final iconSize = isLandscape ? 38.0 : 64.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isLandscape)
          AnimatedOpacity(
            opacity: controller.selectedServer != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.isConnected && controller.selectedServer != null
                        ? controller.selectedServer!.location
                        : controller.autoMode ? 'AI — авто-выбор' : controller.selectedServer?.location ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (controller.isConnected && controller.selectedServer != null)
                    Builder(builder: (context) {
                      final ping = controller.pingFor(controller.selectedServer!.nodeId);
                      return Text(
                        ping != null ? '$ping ms' : controller.selectedServer!.configType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurface.withOpacity(0.4),
                          letterSpacing: 0.3,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

        GestureDetector(
          onTap: isConnecting ? null : controller.toggleConnection,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = isConnected ? _pulseAnimation.value : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isConnected ? 0.35 : 0.15),
                    blurRadius: isConnected ? 60 : 30,
                    spreadRadius: isConnected ? 10 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: isConnecting
                  ? Center(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                            color: color, strokeWidth: 2),
                      ),
                    )
                  : Icon(Icons.power_settings_new_rounded,
                      size: iconSize, color: color),
            ),
          ),
        ),

        SizedBox(height: isLandscape ? 8 : 28),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _statusLabel(controller),
            key: ValueKey(controller.connectionState),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface.withOpacity(0.45),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(VpnController c) {
    switch (c.connectionState) {
      case VpnConnectionState.connected:
        return 'Подключено';
      case VpnConnectionState.connecting:
        return 'Подключение...';
      case VpnConnectionState.disconnecting:
        return 'Отключение...';
      case VpnConnectionState.disconnected:
        return 'Нажмите для подключения';
    }
  }

  // ── Footer ────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context, VpnController controller) {
    return Row(
      children: [
        Expanded(
          child: _FooterButton(
            icon: Icons.language_rounded,
            label: 'Серверы',
            onTap: () => _showServersSheet(context, controller),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FooterButton(
            icon: Icons.tune_rounded,
            label: 'Туннель',
            onTap: () => _showRoutingSheet(context),
          ),
        ),
      ],
    );
  }

  void _showServersSheet(BuildContext context, VpnController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const _ServersSheet(),
      ),
    );
  }

  void _showRoutingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<VpnController>(),
        child: const _RoutingSheet(),
      ),
    );
  }
}

// ── Status Chip ──────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final VpnController controller;
  const _StatusChip({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isOn = controller.isConnected;
    final color = isOn ? const Color(0xFF34C759) : AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            isOn ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer Button ─────────────────────────────────────────────────────────────
class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FooterButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Servers Bottom Sheet ──────────────────────────────────────────────────────
class _ServersSheet extends StatelessWidget {
  const _ServersSheet();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VpnController>();

    // Split servers by purpose
    final general = controller.servers
        .where((s) => s.purpose == 'general' || s.purpose == null)
        .toList();
    final reverse =
        controller.servers.where((s) => s.purpose == 'reverse').toList();

    return _GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Text(
              'Серверы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),

          // AI auto
          _NodeTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.primary, size: 20),
            ),
            title: 'AI — авто-выбор',
            subtitle: 'Минимальный пинг',
            pingMs: null,
            trailing: controller.autoMode
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 22)
                : null,
            onTap: () {
              controller.setAutoMode(true);
              Navigator.pop(context);
            },
          ),

          if (general.isNotEmpty) ...[
            const _SectionLabel('Глобальные'),
            ...general.map((server) =>
                _serverTile(context, controller, server)),
          ],

          if (reverse.isNotEmpty) ...[
            const _SectionLabel('Для России 🇷🇺'),
            ...reverse.map((server) =>
                _serverTile(context, controller, server)),
          ],

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _serverTile(
      BuildContext context, VpnController controller, ServerModel server) {
    final ping = controller.pingFor(server.nodeId);
    final isActive = controller.isConnected &&
        controller.selectedServer?.nodeId == server.nodeId;
    final isSelected = !controller.autoMode &&
        controller.selectedServer?.nodeId == server.nodeId;
    final isLocked = controller.isConnected;

    return Opacity(
      opacity: isLocked && !isActive ? 0.4 : 1.0,
      child: _NodeTile(
        leading: Text(server.flagEmoji, style: const TextStyle(fontSize: 28)),
        title: server.location,
        subtitle: isActive ? 'Подключено' : server.loadLabel,
        pingMs: ping,
        trailing: isActive
            ? const Icon(Icons.radio_button_checked,
                color: Color(0xFF34C759), size: 22)
            : isSelected
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 22)
                : null,
        onTap: isLocked
            ? () {} // заморожено
            : () {
                controller.selectServer(server);
                Navigator.pop(context);
              },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface.withOpacity(0.4),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Routing Bottom Sheet ──────────────────────────────────────────────────────
class _RoutingSheet extends StatefulWidget {
  const _RoutingSheet();

  @override
  State<_RoutingSheet> createState() => _RoutingSheetState();
}

class _RoutingSheetState extends State<_RoutingSheet> {
  final TextEditingController _domainsController = TextEditingController();
  List<AppInfo> _installedApps = [];
  Set<String> _selectedApps = {};
  bool _loadingApps = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<VpnController>();
    _domainsController.text = controller.customDomains.join('\n');
    _selectedApps = Set.from(controller.selectedApps);
  }

  @override
  void dispose() {
    _domainsController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    if (_installedApps.isNotEmpty || _loadingApps) return;
    setState(() => _loadingApps = true);
    try {
      final apps = await InstalledApps.getInstalledApps(true, true);
      setState(() {
        _installedApps = apps;
        _loadingApps = false;
      });
    } catch (_) {
      setState(() => _loadingApps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VpnController>();

    return _GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Text(
              'Туннелирование',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface),
            ),
          ),

          _RoutingTile(
            icon: Icons.public_rounded,
            title: 'Весь трафик',
            subtitle: 'Всё через VPN',
            selected: controller.routingMode == VpnRoutingMode.full,
            onTap: () => controller.setRoutingMode(VpnRoutingMode.full),
          ),

          _RoutingTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Только VTalk',
            subtitle: 'Мессенджер через VPN, остальное напрямую',
            selected: controller.routingMode == VpnRoutingMode.vtalkOnly,
            onTap: () =>
                controller.setRoutingMode(VpnRoutingMode.vtalkOnly),
          ),

          _RoutingTile(
            icon: Icons.apps_rounded,
            title: 'Выбрать приложения',
            subtitle: _selectedApps.isEmpty
                ? 'Указать какие приложения через VPN'
                : 'Выбрано: ${_selectedApps.length} прил.',
            selected: controller.routingMode == VpnRoutingMode.apps,
            onTap: () {
              controller.setRoutingMode(VpnRoutingMode.apps);
              _loadApps();
            },
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: controller.routingMode == VpnRoutingMode.apps
                ? _buildAppsSection(controller)
                : const SizedBox.shrink(),
          ),

          _RoutingTile(
            icon: Icons.edit_note_rounded,
            title: 'Свои адреса',
            subtitle: 'Указать домены вручную',
            selected: controller.routingMode == VpnRoutingMode.custom,
            onTap: () => controller.setRoutingMode(VpnRoutingMode.custom),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: controller.routingMode == VpnRoutingMode.custom
                ? _buildDomainsSection(controller)
                : const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }

  Widget _buildAppsSection(VpnController controller) {
    if (_loadingApps) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_installedApps.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _installedApps.length,
            itemBuilder: (context, i) {
              final app = _installedApps[i];
              final pkg = app.packageName ?? '';
              final selected = _selectedApps.contains(pkg);
              return CheckboxListTile(
                value: selected,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selectedApps.add(pkg);
                  } else {
                    _selectedApps.remove(pkg);
                  }
                }),
                title: Text(
                  app.name ?? pkg,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                secondary: app.icon != null
                    ? Image.memory(app.icon!, width: 32, height: 32)
                    : const Icon(Icons.android_rounded, size: 32),
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24),
                dense: true,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                controller.setSelectedApps(_selectedApps.toList());
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_selectedApps.isEmpty
                  ? 'Сохранить'
                  : 'Применить (${_selectedApps.length})'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDomainsSection(VpnController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _domainsController,
            maxLines: 4,
            style:
                const TextStyle(fontSize: 14, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'example.com\nsite.org',
              hintStyle: TextStyle(
                  color: AppColors.onSurface.withOpacity(0.35),
                  fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF1F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                final domains = _domainsController.text
                    .split('\n')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                controller.setCustomDomains(domains);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Sheet Widgets ──────────────────────────────────────────────────────
class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.onSurface.withOpacity(0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final int? pingMs;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NodeTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.pingMs,
    this.trailing,
    required this.onTap,
  });

  Color _pingColor(int ms) {
    if (ms < 80) return const Color(0xFF34C759);
    if (ms < 150) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.onSurface.withOpacity(0.45),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pingMs != null && pingMs! < 9000)
            Text(
              '$pingMs ms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _pingColor(pingMs!),
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _RoutingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoutingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            fontSize: 13, color: AppColors.onSurface.withOpacity(0.45)),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }
}