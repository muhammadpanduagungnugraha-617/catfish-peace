import 'package:flutter/material.dart';

enum ConnectionBadgeState { connected, disconnected, connecting }

/// Badge outline di header: Terhubung (border biru) / Terputus (border merah).
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.state});

  final ConnectionBadgeState state;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color border;
    switch (state) {
      case ConnectionBadgeState.connected:
        label = 'Terhubung';
        border = const Color(0xFF2F8CFF);
      case ConnectionBadgeState.disconnected:
        label = 'Terputus';
        border = const Color(0xFFFF383B);
      case ConnectionBadgeState.connecting:
        label = 'Menghubungkan';
        border = Colors.white54;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
