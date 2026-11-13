import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: SennaColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: yellow, width: 2),
                  boxShadow: [
                    BoxShadow(color: yellow.withValues(alpha: 0.3), blurRadius: 16),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded, color: magenta, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'MODO DESAFIO',
                style: TextStyle(
                  color: yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cronômetro de voltas na Pista Cyber Speed, telemetria de corrida e ranking.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

