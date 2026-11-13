import 'package:flutter/material.dart';
import 'oyuncak.dart';
import 'tema.dart';

// 2x2 kompakt ölçü ızgarası: simge, çubuk, sayı; değişimde +/- uçuşu
class OlcuIzgara extends StatefulWidget {
  final int zaman;
  final int para;
  final int saglik;
  final int iliski;
  const OlcuIzgara({
    required this.zaman,
    required this.para,
    required this.saglik,
    required this.iliski,
    super.key,
  });

  @override
  State<OlcuIzgara> createState() => _OlcuIzgaraState();
}

class _OlcuIzgaraState extends State<OlcuIzgara> {
  @override
  Widget build(BuildContext context) {
    Widget hucre(OlcuTuru2 t, int v) => Expanded(child: _Hucre(tur: t, deger: v));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          hucre(OlcuTuru2.zaman, widget.zaman),
          const SizedBox(width: 8),
          hucre(OlcuTuru2.para, widget.para),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          hucre(OlcuTuru2.saglik, widget.saglik),
          const SizedBox(width: 8),
          hucre(OlcuTuru2.iliski, widget.iliski),
        ]),
      ],
    );
  }
}

enum OlcuTuru2 { zaman, para, saglik, iliski }

class _Hucre extends StatefulWidget {
  final OlcuTuru2 tur;
  final int deger;
  const _Hucre({required this.tur, required this.deger});

  @override
  State<_Hucre> createState() => _HucreState();
}

class _HucreState extends State<_Hucre> with SingleTickerProviderStateMixin {
  late final AnimationController _ucus = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  int _fark = 0;

  @override
  void didUpdateWidget(covariant _Hucre old) {
    super.didUpdateWidget(old);
    if (widget.deger != old.deger) {
      _fark = widget.deger - old.deger;
      _ucus.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ucus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (sprite, renk) = switch (widget.tur) {
      OlcuTuru2.zaman => (simgeSaat, Renk.zaman),
      OlcuTuru2.para => (simgePara, Renk.para),
      OlcuTuru2.saglik => (simgeArti, Renk.saglik),
      OlcuTuru2.iliski => (simgeKalp, Renk.iliski),
    };
    final v = widget.deger.clamp(0, 100);
    final dusuk = v <= 20;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: Renk.murekkep, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(children: [
            PikselSimge(sprite: sprite, renk: renk, piksel: 2.5),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 10,
                  color: Renk.murekkep.withValues(alpha: 0.12),
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    widthFactor: v / 100,
                    child: Container(
                      color: dusuk ? const Color(0xFFFF8A80) : renk,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 24,
              child: Text(
                '$v',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Renk.murekkep,
                ),
              ),
            ),
          ]),
          AnimatedBuilder(
            animation: _ucus,
            builder: (context, _) {
              if (!_ucus.isAnimating || _fark == 0) {
                return const SizedBox.shrink();
              }
              final t = _ucus.value;
              return Positioned(
                right: 4,
                top: -4 - 14 * t,
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Text(
                    _fark > 0 ? '+$_fark' : '$_fark',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _fark > 0
                          ? const Color(0xFF2E9E5B)
                          : const Color(0xFFD9534F),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}