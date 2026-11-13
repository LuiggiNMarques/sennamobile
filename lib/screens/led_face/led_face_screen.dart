import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

class FaceExpression {
  final String id;
  final String name;
  final String previewSymbol;
  final String description;
  final Color accentColor;

  const FaceExpression({
    required this.id,
    required this.name,
    required this.previewSymbol,
    required this.description,
    required this.accentColor,
  });
}

class LedFaceScreen extends StatefulWidget {
  const LedFaceScreen({super.key});

  @override
  State<LedFaceScreen> createState() => _LedFaceScreenState();
}

class _LedFaceScreenState extends State<LedFaceScreen> {
  final BleService _ble = BleService();
  String _selectedFace = 'FELIZ';

  static const List<FaceExpression> _expressions = [
    FaceExpression(
      id: 'FELIZ',
      name: 'Feliz',
      previewSymbol: '^ _ ^',
      description: 'Olhos alegres e sorriso aberto',
      accentColor: SennaColors.neonGreen,
    ),
    FaceExpression(
      id: 'CORRIDA',
      name: 'Foco Corrida',
      previewSymbol: '> _ <',
      description: 'Determinado na pista',
      accentColor: SennaColors.yellow,
    ),
    FaceExpression(
      id: 'PISCADELA',
      name: 'Piscadela',
      previewSymbol: '^ _ ~',
      description: 'Piscando olho direito',
      accentColor: SennaColors.cyan,
    ),
    FaceExpression(
      id: 'VITORIA',
      name: 'Vitória',
      previewSymbol: '★ _ ★',
      description: 'Comemorando no pódio!',
      accentColor: SennaColors.orange,
    ),
    FaceExpression(
      id: 'CORACAO',
      name: 'Coração',
      previewSymbol: '♥ _ ♥',
      description: 'Olhos de coração',
      accentColor: SennaColors.magenta,
    ),
    FaceExpression(
      id: 'BRAVO',
      name: 'Modo Turbo',
      previewSymbol: '> _ <',
      description: 'Expressão agressiva de ultrapassagem',
      accentColor: SennaColors.red,
    ),
    FaceExpression(
      id: 'SONECA',
      name: 'Standby / Zzz',
      previewSymbol: '- _ -',
      description: 'Modo de economia de energia',
      accentColor: Colors.blueGrey,
    ),
    FaceExpression(
      id: 'NEUTRO',
      name: 'Neutro',
      previewSymbol: '• _ •',
      description: 'Aguardando ordens',
      accentColor: Colors.white,
    ),
  ];

  void _applyExpression(FaceExpression expr) {
    setState(() {
      _selectedFace = expr.id;
    });
    _ble.sendFace(expr.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SennaColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: expr.accentColor, width: 1.5),
        ),
        content: Row(
          children: [
            Text(
              expr.previewSymbol,
              style: TextStyle(
                color: expr.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Enviado "${expr.name}" para o display OLED!',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExpr = _expressions.firstWhere(
      (e) => e.id == _selectedFace,
      orElse: () => _expressions.first,
    );

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SennaColors.magenta.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SennaColors.magenta, width: 1.5),
                      ),
                      child: const Icon(Icons.face_retouching_natural, color: SennaColors.magenta, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROSTINHO OLED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          'Display SSD1306 • I2C (SDA 8, SCL 9)',
                          style: TextStyle(
                            color: SennaColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ListenableBuilder(
                  listenable: _ble,
                  builder: (context, _) {
                    final connected = _ble.isConnected;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (connected ? SennaColors.neonGreen : Colors.red)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: connected ? SennaColors.neonGreen : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: connected ? SennaColors.neonGreen : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            connected ? 'ONLINE' : 'OFFLINE',
                            style: TextStyle(
                              color: connected ? SennaColors.neonGreen : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // OLED Virtual Simulator Box
            _buildOledSimulator(currentExpr),

            const SizedBox(height: 20),

            // Section Title
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: SennaColors.yellow, size: 16),
                SizedBox(width: 8),
                Text(
                  'SELECIONE A EXPRESSÃO',
                  style: TextStyle(
                    color: SennaColors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Grid of expressions
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.1,
              ),
              itemCount: _expressions.length,
              itemBuilder: (context, index) {
                final expr = _expressions[index];
                final isSelected = expr.id == _selectedFace;

                return InkWell(
                  onTap: () => _applyExpression(expr),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? expr.accentColor.withValues(alpha: 0.15)
                          : SennaColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? expr.accentColor : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: expr.accentColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? expr.accentColor : Colors.white24,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            expr.previewSymbol,
                            style: TextStyle(
                              color: isSelected ? expr.accentColor : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                expr.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? expr.accentColor : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                expr.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: SennaColors.textSecondary,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // Piscar olhos rápido / Botão de ação
            OutlinedButton.icon(
              onPressed: () {
                _ble.sendFace('PISCAR');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comando de piscar olhos enviado!'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
              icon: const Icon(Icons.remove_red_eye_outlined, color: SennaColors.cyan),
              label: const Text(
                'ANIMAR: PISCAR OLHOS',
                style: TextStyle(
                  color: SennaColors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SennaColors.cyan, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOledSimulator(FaceExpression currentExpr) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentExpr.accentColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: currentExpr.accentColor.withValues(alpha: 0.3),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grade simulando pixels do display OLED
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 128,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 16,
                ),
                itemBuilder: (_, index) => Container(
                  margin: const EdgeInsets.all(1),
                  color: Colors.cyan,
                ),
              ),
            ),
          ),

          // Informação de modelo OLED no topo da moldura
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'OLED 128x64 • SSD1306',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'EXPR: ${currentExpr.id}',
                  style: TextStyle(
                    color: currentExpr.accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // O Rosto renderizado em destaque no centro
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentExpr.previewSymbol,
                  style: TextStyle(
                    color: currentExpr.accentColor,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: currentExpr.accentColor,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentExpr.name.toUpperCase(),
                  style: TextStyle(
                    color: currentExpr.accentColor.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
