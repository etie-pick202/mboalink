import "package:flutter/material.dart";

/// Peint un motif de rayures diagonales répétées, fidèle au
/// `repeating-linear-gradient(45deg, ...)` de la maquette — utilisé comme
/// espace réservé pour les illustrations/images pas encore disponibles.
class _DiagonalStripesPainter extends CustomPainter {
  const _DiagonalStripesPainter({required this.colorA, required this.colorB});

  final Color colorA;
  final Color colorB;

  static const double _stripeWidth = 9;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = colorA,
    );

    final paint = Paint()..color = colorB;
    final diagonal = size.width + size.height;
    const step = _stripeWidth * 2;

    for (double x = -diagonal; x < diagonal; x += step) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + _stripeWidth, 0)
        ..lineTo(x + _stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripesPainter oldDelegate) =>
      oldDelegate.colorA != colorA || oldDelegate.colorB != colorB;
}

/// Espace réservé illustré : fond à rayures diagonales + icône + légende.
/// Réutilisé partout où la maquette prévoit une image pas encore fournie.
class DiagonalPlaceholder extends StatelessWidget {
  const DiagonalPlaceholder({
    required this.icon,
    required this.illustrationCaption,
    this.height = 262,
    this.iconColor,
    this.colorA = const Color(0xFFE6EFE9),
    this.colorB = const Color(0xFFEEF4EF),
    this.borderColor = const Color(0xFFE1E6E1),
    super.key,
  });

  final IconData icon;
  final String illustrationCaption;
  final double height;
  final Color? iconColor;
  final Color colorA;
  final Color colorB;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DiagonalStripesPainter(
                  colorA: colorA,
                  colorB: colorB,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 54,
                    color: iconColor ?? const Color(0xFF0A7D4D),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    illustrationCaption,
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9AA39D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
