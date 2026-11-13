import 'package:flutter/material.dart';

enum ControlMode { dpad, joystick, volante }

class ControlModeSelector extends StatelessWidget {
  final ControlMode selectedMode;
  final ValueChanged<ControlMode> onModeChanged;

  const ControlModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPill(
            icon: Icons.gamepad_outlined,
            label: 'D-PAD',
            mode: ControlMode.dpad,
          ),
          const SizedBox(width: 8),
          _buildPill(
            icon: Icons.sports_esports_outlined,
            label: 'JOYSTICK ARCADE',
            mode: ControlMode.joystick,
          ),
          const SizedBox(width: 8),
          _buildPill(
            icon: Icons.radio_button_unchecked,
            label: 'VOLANTE F1',
            mode: ControlMode.volante,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required ControlMode mode,
  }) {
    final bool isActive = selectedMode == mode;
    const Color activeColor = Color(0xFFFF6B00);
    const Color activeMagenta = Color(0xFFFF006E);
    const Color cyanBorder = Color(0xFF00E5FF);
    const Color darkBg = Color(0xFF121830);

    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [activeColor, activeMagenta],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : darkBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? Colors.transparent : cyanBorder.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : cyanBorder.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : cyanBorder.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
