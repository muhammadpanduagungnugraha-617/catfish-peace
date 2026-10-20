import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';

class _NavDef {
  const _NavDef(this.icon, this.label);
  final IconData icon;
  final String label;
}

const _items = [
  _NavDef(Icons.space_dashboard_outlined, 'Dashboard'),
  _NavDef(Icons.tune_rounded, 'Kontrol'),
  _NavDef(Icons.history_rounded, 'Riwayat'),
];

/// Bottom navigation 3 tab (mobile dan web). Tab aktif: pill + warna aksen.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.isWide(context) ? 12.0 : 8.0;
    return Container(
      color: AppColors.bottomNav,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    def: _items[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.def,
    required this.active,
    required this.onTap,
  });

  final _NavDef def;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: active ? AppColors.navActivePill : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(def.icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                def.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
