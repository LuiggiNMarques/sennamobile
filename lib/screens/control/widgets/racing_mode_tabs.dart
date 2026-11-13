import 'package:flutter/material.dart';

class RacingModeTabs extends StatelessWidget {
  final int selectedTab; // 0 = ECO, 1 = PISTA
  final bool turboActive;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onTurboToggle;

  const RacingModeTabs({
    super.key,
    required this.selectedTab,
    required this.turboActive,
    required this.onTabChanged,
    this.onTurboToggle,
  });

  @override
  Widget build(BuildContext context) {
    const Color cyan = Color(0xFF00E5FF);
    const Color orange = Color(0xFFFF6B00);
    const Color magenta = Color(0xFFFF006E);
    const Color darkBg = Color(0xFF121830);
    const Color green = Color(0xFF00FF85);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // ECO tab
          _buildTab(
            label: 'ECO',
            icon: Icons.eco_outlined,
            isActive: selectedTab == 0,
            activeColor: green,
            darkBg: darkBg,
            cyan: cyan,
            onTap: () => onTabChanged(0),
          ),
          const SizedBox(width: 8),
          // PISTA tab
          _buildTab(
            label: 'PISTA',
            icon: Icons.speed_outlined,
            isActive: selectedTab == 1,
            activeColor: orange,
            darkBg: darkBg,
            cyan: cyan,
            onTap: () => onTabChanged(1),
          ),
          const Spacer(),
          // TURBO indicator
          GestureDetector(
            onTap: onTurboToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: turboActive ? magenta.withOpacity(0.2) : darkBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: turboActive ? magenta : magenta.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: turboActive
                    ? [
                        BoxShadow(
                          color: magenta.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: turboActive ? magenta : magenta.withOpacity(0.5),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TURBO 100%',
                    style: TextStyle(
                      color: turboActive ? Colors.white : Colors.white.withOpacity(0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TURBO BOOST',
                    style: TextStyle(
                      color: turboActive ? magenta : magenta.withOpacity(0.5),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color darkBg,
    required Color cyan,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : darkBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : cyan.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : cyan.withOpacity(0.4),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
