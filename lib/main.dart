import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/control/control_screen.dart';
import 'screens/led_face/led_face_screen.dart';
import 'screens/telemetry/telemetry_screen.dart';
import 'screens/challenge/challenge_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SennaApp());
}

class SennaApp extends StatelessWidget {
  const SennaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senninha Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _activeTabIndex = 0; // 0=Controle, 1=LED Face, 2=Telemetria, 3=Desafio

  final List<Widget> _screens = const [
    ControlScreen(),
    LedFaceScreen(),
    TelemetryScreen(),
    ChallengeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: IndexedStack(
        index: _activeTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const Color magenta = SennaColors.magenta;
    const Color orange = SennaColors.orange;
    const Color yellow = SennaColors.yellow;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.sports_esports_rounded,
              label: 'Controle',
              activeColor: magenta,
              dotColor: orange,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.face_rounded,
              label: 'LED Face',
              activeColor: yellow,
              dotColor: yellow,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.speed_rounded,
              label: 'Telemetria',
              activeColor: magenta,
              dotColor: yellow,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.emoji_events_rounded,
              label: 'Desafio',
              activeColor: yellow,
              dotColor: yellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
    required Color dotColor,
  }) {
    final isSelected = _activeTabIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTabIndex = index);
      },
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top glowing dot for active item
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 9),

            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white38,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white38,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
