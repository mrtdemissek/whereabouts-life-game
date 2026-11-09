import 'package:flutter/material.dart';
import 'tema.dart';

// Kalın çerçeveli, sert gölgeli oyuncak kart
class OyuncakKart extends StatelessWidget {
  final Widget child;
  final Color renk;
  final EdgeInsets padding;
  const OyuncakKart({
    required this.child,
    this.renk = Renk.kagit,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: padding,
      decoration: BoxDecoration(
        color: renk,
        border: Border.all(color: Renk.murekkep, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Renk.murekkep, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }
}

// Piksel simgeler. . boş, O çerçeve, W beyaz, M ana renk
const simgeSaat = [
  '..OOOO..',
  '.OMMMMO.',
  'OMMMOMMO',
  'OMMMOMMO',
  'OMMMOOMO',
  'OMMMMMMO',
  '.OMMMMO.',
  '..OOOO..',
];

const simgePara = [
  '..OOOO..',
  '.OMMMMO.',
  'OMMOOMMO',
  'OMOMMMMO',
  'OMOMMMMO',
  'OMMOOMMO',
  '.OMMMMO.',
  '..OOOO..',
];

const simgeArti = [
  '..OOOO..',
  '..OMMO..',
  'OOOMMOOO',
  'OMMMMMMO',
  'OMMMMMMO',
  'OOOMMOOO',
  '..OMMO..',
  '..OOOO..',
];

const simgeKalp = [
  '.OO..OO.',
  'OMMOOMMO',
  'OMMMMMMO',
  'OMMMMMMO',
  '.OMMMMO.',
  '..OMMO..',
  '...OO...',
];

class PikselSimge extends StatelessWidget {
  final List<String> sprite;
  final Color renk;
  final double piksel;
  const PikselSimge({
    required this.sprite,
    required this.renk,
    this.piksel = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final genis =
        sprite.fold<int>(0, (m, s) => s.length > m ? s.length : m);
    return CustomPaint(
      size: Size(genis * piksel, sprite.length * piksel),
      painter: _SimgePainter(sprite, renk, piksel),
    );
  }
}

class _SimgePainter extends CustomPainter {
  final List<String> sprite;
  final Color renk;
  final double piksel;
  const _SimgePainter(this.sprite, this.renk, this.piksel);

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()..isAntiAlias = false;
    for (var y = 0; y < sprite.length; y++) {
      final satir = sprite[y];
      for (var x = 0; x < satir.length; x++) {
        final ch = satir[x];
        Color? c;
        if (ch == 'O') c = Renk.murekkep;
        if (ch == 'W') c = Renk.kagit;
        if (ch == 'M') c = renk;
        if (c == null) continue;
        firca.color = c;
        canvas.drawRect(
          Rect.fromLTWH(x * piksel, y * piksel, piksel, piksel),
          firca,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SimgePainter old) =>
      old.sprite != sprite || old.renk != renk || old.piksel != piksel;
}