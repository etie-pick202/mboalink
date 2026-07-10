import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";

/// Petit graphique en courbe, sans dépendance externe — utilisé pour les
/// tendances (revenus, vues…). Affiche un état "pas assez de données"
/// tant qu'il n'y a pas au moins 2 points avec une valeur positive.
class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    required this.values,
    required this.labels,
    this.lineColor = AppColors.primary,
    this.height = 110,
    this.emptyMessage = "Pas encore assez de données",
    super.key,
  });

  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final double height;
  final String emptyMessage;

  bool get _hasEnoughData =>
      values.length >= 2 && values.where((v) => v > 0).length >= 2;

  @override
  Widget build(BuildContext context) {
    if (!_hasEnoughData) {
      return _EmptyChart(height: height, message: emptyMessage);
    }
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(values: values, color: lineColor),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in labels)
                Text(
                  label,
                  style: AppTypography.caption.copyWith(fontSize: 9.5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.height, required this.message});

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.monitoring,
              size: 26,
              color: AppColors.textFaint,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width == 0 || size.height == 0) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 1e-9
        ? 1.0
        : maxValue - minValue;

    const topPad = 8.0;
    const bottomPad = 6.0;
    final chartHeight = size.height - topPad - bottomPad;
    final stepX = values.length > 1
        ? size.width / (values.length - 1)
        : size.width;

    Offset pointAt(int i) {
      final x = i * stepX;
      final normalized = (values[i] - minValue) / range;
      final y = topPad + chartHeight - (normalized * chartHeight);
      return Offset(x, y);
    }

    final points = List.generate(values.length, pointAt);

    // Zone remplie sous la courbe
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Courbe
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final controlX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(controlX, prev.dy, controlX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Points
    for (final p in points) {
      canvas.drawCircle(p, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        3.5,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
