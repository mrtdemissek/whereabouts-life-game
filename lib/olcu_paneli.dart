import 'package:flutter/material.dart';
import 'dil.dart';
import 'oyun_ui.dart';
import 'oyuncak.dart';
import 'parcalar.dart';
import 'tema.dart';

// Dört ölçü, 2x2 panelde: piksel simge, ad, sayı ve 10 dilimli çubuk.
// Değer değişince yanında kısa süre ▲/▼ farkı görünür.
class OlcuPaneli extends StatelessWidget {
  final int zaman;
  final int para;
  final int saglik;
  final int iliski;
  const OlcuPaneli({
    required this.zaman,
    required this.para,
    required this.saglik,
    required this.iliski,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OyunPanel(
      renk: Renk.kagit.withValues(alpha: 0.94),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: _OlcuHucresi(tur: OlcuTuru.zaman, deger: zaman)),
            const SizedBox(width: 14),
            Expanded(child: _OlcuHucresi(tur: OlcuTuru.para, deger: para)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _OlcuHucresi(tur: OlcuTuru.saglik, deger: saglik)),
            const SizedBox(width: 14),
            Expanded(child: _OlcuHucresi(tur: OlcuTuru.iliski, deger: iliski)),
          ]),
        ],
      ),
    );
  }
}

class _OlcuHucresi extends StatefulWidget {
  final OlcuTuru tur;
  final int deger;
  const _OlcuHucresi({required this.tur, required this.deger});

  @override
  State<_OlcuHucresi> createState() => _OlcuHucresiState();
}

class _OlcuHucresiState extends State<_OlcuHucresi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fark = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  int _son = 0;

  @override
  void didUpdateWidget(covariant _OlcuHucresi old) {
    super.didUpdateWidget(old);
    if (widget.deger != old.deger) {
      _son = widget.deger - old.deger;
      _fark.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (sprite, renk) = switch (widget.tur) {
      OlcuTuru.zaman => (simgeSaat, Renk.zaman),
      OlcuTuru.para => (simgePara, Renk.para),
      OlcuTuru.saglik => (simgeArti, Renk.saglik),
      OlcuTuru.iliski => (simgeKalp, Renk.iliski),
    };
    final v = widget.deger.clamp(0, 100);
    final dolu = (v / 10).ceil().clamp(0, 10);
    final kritik = v <= 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            PikselSimge(sprite: sprite, renk: renk, piksel: 2),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                context.t('olcu_${widget.tur.name}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Yazi.piksel(boyut: 14),
              ),
            ),
            AnimatedBuilder(
              animation: _fark,
              builder: (context, _) {
                if (!_fark.isAnimating || _son == 0) {
                  return const SizedBox.shrink();
                }
                final o = (1 - _fark.value * _fark.value).clamp(0.0, 1.0);
                return Opacity(
                  opacity: o,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      _son > 0 ? '▲$_son' : '▼${-_son}',
                      style: Yazi.sayi(
                        boyut: 12,
                        renk: _son > 0 ? Renk.artis : Renk.azalis,
                      ),
                    ),
                  ),
                );
              },
            ),
            Text('$v', style: Yazi.sayi(boyut: 15)),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 11,
          child: Row(
            children: [
              for (var i = 0; i < 10; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    color: i < dolu
                        ? (kritik ? Renk.azalis : renk)
                        : Renk.bos,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
