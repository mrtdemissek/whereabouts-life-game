import 'dart:math';
import 'package:flutter/material.dart';

class _Parca {
  final double x; // 0..1 yatay başlangıç
  final double hiz; // düşme hızı çarpanı
  final double faz; // yatay salınım fazı
  final double genlik; // yatay salınım genliği
  final double boy; // piksel boyutu
  final Color renk;
  const _Parca({
    required this.x,
    required this.hiz,
    required this.faz,
    required this.genlik,
    required this.boy,
    required this.renk,
  });
}

// Ekranın üstünden düşen pastel piksel konfeti. Bir kez oynar ve söner.
class Konfeti extends StatefulWidget {
  const Konfeti({super.key});

  @override
  State<Konfeti> createState() => _KonfetiState();
}

class _KonfetiState extends State<Konfeti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Parca> _parcalar;

  @override
  void initState() {
    super.initState();
    final r = Random();
    const renkler = [
      Color(0xFFFFC8DD),
      Color(0xFFBFE3F5),
      Color(0xFFFFE680),
      Color(0xFFBDEBD6),
      Color(0xFFC3B1E8),
      Color(0xFFFFD3B6),
    ];
    _parcalar = List.generate(
      60,
      (_) => _Parca(
        x: r.nextDouble(),
        hiz: 0.7 + r.nextDouble() * 0.6,
        faz: r.nextDouble() * 2 * pi,
        genlik: 0.01 + r.nextDouble() * 0.03,
        boy: (6 + r.nextInt(3) * 2).toDouble(),
        renk: renkler[r.nextInt(renkler.length)],
      ),
    );
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _KonfetiPainter(_parcalar, _c.value),
        ),
      ),
    );
  }
}

class _KonfetiPainter extends CustomPainter {
  final List<_Parca> parcalar;
  final double t;
  const _KonfetiPainter(this.parcalar, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()..isAntiAlias = false;
    final alfa = t < 0.8 ? 1.0 : ((1 - t) / 0.2).clamp(0.0, 1.0).toDouble();
    for (final p in parcalar) {
      final y = (t * p.hiz * 1.3 - 0.1) * size.height;
      if (y > size.height) continue;
      final x = (p.x + sin(t * 6 + p.faz) * p.genlik) * size.width;
      // 4 piksellik ızgaraya oturt: piksel sanatı görünümü
      final gx = (x / 4).floorToDouble() * 4;
      final gy = (y / 4).floorToDouble() * 4;
      firca.color = p.renk.withValues(alpha: alfa);
      canvas.drawRect(Rect.fromLTWH(gx, gy, p.boy, p.boy), firca);
    }
  }

  @override
  bool shouldRepaint(covariant _KonfetiPainter old) => old.t != t;
}