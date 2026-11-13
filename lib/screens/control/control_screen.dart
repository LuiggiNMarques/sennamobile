import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/control/cockpit_top_panel.dart';
import 'dpad_control.dart';
import 'joystick_control.dart';
import 'steering_control.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  int _controlMode = 0; // 0 = D-PAD, 1 = JOYSTICK ARCADE, 2 = VOLANTE F1
  int _powerMode = 2; // 0 = ECO, 1 = PISTA, 2 = SENNA 100%
  bool _isFarolOn = false;

  @override
  Widget build(BuildContext context) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;
    const Color cardBg = SennaColors.surface;

    return SafeArea(
      child: Column(
        children: [
          // ── Cockpit Top Status Panel ───────────────────────────────
          CockpitTopPanel(
            selectedPowerMode: _powerMode,
            onPowerModeChanged: (mode) => setState(() => _powerMode = mode),
            isFarolOn: _isFarolOn,
            onToggleFarol: () => setState(() => _isFarolOn = !_isFarolOn),
          ),

          const SizedBox(height: 8),

          // ── Mode Selector Pill Tabs: D-PAD | JOYSTICK ARCADE | VOLANTE F1 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF10142A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  _buildModeTab(
                    title: 'D-PAD',
                    icon: Icons.gamepad,
                    index: 0,
                    activeColor: yellow,
                  ),
                  _buildModeTab(
                    title: 'JOYSTICK ARCADE',
                    icon: Icons.sports_esports,
                    index: 1,
                    activeColor: magenta,
                  ),
                  _buildModeTab(
                    title: 'VOLANTE F1',
                    icon: Icons.sports_motorsports,
                    index: 2,
                    activeColor: yellow,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Active Control Mode View ───────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _controlMode,
              children: const [
                DpadControl(),
                JoystickControl(),
                SteeringControl(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required int index,
    required Color activeColor,
  }) {
    final isSelected = _controlMode == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _controlMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.white38,
                size: 13,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? activeColor : Colors.white54,
                    fontSize: 8.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

