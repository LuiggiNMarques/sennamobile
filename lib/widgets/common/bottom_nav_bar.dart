import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Bottom navigation bar for the Senninha app.
///
/// Four tabs: Controle · LED Face · Telemetria · Desafio.
class SennaBottomNavBar extends StatelessWidget {
  const SennaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.gamepad_outlined, activeIcon: Icons.gamepad, label: 'Controle', color: SennaColors.orange),
    _NavItem(icon: Icons.emoji_emotions_outlined, activeIcon: Icons.emoji_emotions, label: 'LED Face', color: SennaColors.cyan),
    _NavItem(icon: Icons.monitor_heart_outlined, activeIcon: Icons.monitor_heart, label: 'Telemetria', color: SennaColors.magenta),
    _NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Desafio', color: SennaColors.yellow),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SennaColors.background,
        border: Border(
          top: BorderSide(
            color: SennaColors.cyan.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: _NavBarItem(
                  item: item,
                  selected: selected,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? item.color : SennaColors.textDim;
    final icon = selected ? item.activeIcon : item.icon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glow indicator dot when selected
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: selected ? 18 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: selected ? item.color : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: SennaTextStyles.badge.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
