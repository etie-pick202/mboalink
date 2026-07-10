// Outil de développement (pas un test) — régénère les images maîtres
// utilisées par flutter_launcher_icons à partir du logo de marque
// MboaLink (mêmes couleurs et même glyphe "hub" que AppLogo), sans
// dépendre du rendu de police (dessin vectoriel pur via dart:ui.Canvas).
//
// Usage : flutter test tool/generate_launcher_icon.dart
// Puis   : dart run flutter_launcher_icons
import "dart:io";
import "dart:math";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:flutter_test/flutter_test.dart";

const _primary = ui.Color(0xFF0A7D4D);
const _primaryDark = ui.Color(0xFF064D30);
const _white = ui.Color(0xFFFFFFFF);
const _size = 1024.0;

void _drawHubGlyph(ui.Canvas canvas) {
  const center = ui.Offset(_size / 2, _size / 2);
  const centerRadius = _size * 0.085;
  const orbitRadius = _size * 0.235;
  const satelliteRadius = _size * 0.062;
  const strokeWidth = _size * 0.035;

  final linePaint = ui.Paint()
    ..color = _white
    ..strokeWidth = strokeWidth
    ..strokeCap = ui.StrokeCap.round;
  final nodePaint = ui.Paint()..color = _white;

  final satellites = List.generate(6, (i) {
    final angle = (-90 + i * 60) * pi / 180;
    return ui.Offset(
      center.dx + orbitRadius * cos(angle),
      center.dy + orbitRadius * sin(angle),
    );
  });

  for (final s in satellites) {
    canvas.drawLine(center, s, linePaint);
  }
  for (final s in satellites) {
    canvas.drawCircle(s, satelliteRadius, nodePaint);
  }
  canvas.drawCircle(center, centerRadius, nodePaint);
}

Future<Uint8List> _encodePng(void Function(ui.Canvas canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  paint(canvas);
  final picture = recorder.endRecording();
  final image = await picture.toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

void main() {
  test("génère les images maîtres du logo MboaLink", () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // 1. Icône pleine (fond dégradé + glyphe) — utilisée pour iOS et
    //    l'icône Android historique (non-adaptive).
    final iconBytes = await _encodePng((canvas) {
      const rect = ui.Rect.fromLTWH(0, 0, _size, _size);
      final gradientPaint = ui.Paint()
        ..shader = ui.Gradient.linear(
          const ui.Offset(_size * 0.15, 0),
          const ui.Offset(_size * 0.85, _size),
          [_primary, _primaryDark],
        );
      canvas.drawRect(rect, gradientPaint);
      _drawHubGlyph(canvas);
    });
    await File("assets/icon/icon.png").writeAsBytes(iconBytes, flush: true);

    // 2. Premier plan seul (fond transparent) — utilisé pour l'icône
    //    adaptative Android (le fond est fourni séparément en couleur
    //    unie dans la config flutter_launcher_icons).
    final foregroundBytes = await _encodePng(_drawHubGlyph);
    await File(
      "assets/icon/icon_foreground.png",
    ).writeAsBytes(foregroundBytes, flush: true);

    expect(File("assets/icon/icon.png").existsSync(), isTrue);
    expect(File("assets/icon/icon_foreground.png").existsSync(), isTrue);
  });
}
