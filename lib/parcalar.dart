import 'package:flutter/material.dart';
import 'dil.dart';
import 'oyuncak.dart';
import 'tema.dart';

enum OlcuTuru { zaman, para, saglik, iliski }

(List<String>, Color) _simgeVeRenk(OlcuTuru tur) {
  switch (tur) {
    case OlcuTuru.zaman:
      return (simgeSaat, Renk.zaman);
    case OlcuTuru.para:
      return (simgePara, Renk.para);
    case OlcuTuru.saglik:
      return (simgeArti, Renk.saglik);
    case OlcuTuru.iliski:
      return (simgeKalp, Renk.iliski);
  }
}

// Simgeli, animasyonlu ölçü çubuğu
class Olcu extends StatefulWidget {
  final OlcuTuru tur;
  final int deger;
  const Olcu(this.tur, this.deger, {super.key});

  @override
  State<Olcu> createState() => _OlcuState();
}

class _OlcuState extends State<Olcu> with SingleTickerProviderStateMixin {
  late final AnimationController _ucus;
  int _delta = 0;

  @override
  void initState() {
    super.initState();
    _ucus = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(covariant Olcu old) {
    super.didUpdateWidget(old);
    if (old.deger != widget.deger) {
      _delta = widget.deger - old.deger;
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
    final (simge, renk) = _simgeVeRenk(widget.tur);
    final dolgu = widget.deger <= 20 ? const Color(0xFFFF8A80) : renk;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            PikselSimge(sprite: simge, renk: renk, piksel: 3),
            const SizedBox(width: 8),
            SizedBox(
              width: 92,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  context.t('olcu_${widget.tur.name}'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 16,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Renk.kagit,
                  border: Border.all(color: Renk.murekkep, width: 2.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: widget.deger / 100),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, v, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: v.clamp(0.0, 1.0),
                      child: Container(color: dolgu),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${widget.deger}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedBuilder(
                      animation: _ucus,
                      builder: (context, _) {
                        final t = _ucus.value;
                        if (_delta == 0 || t == 0 || t == 1) {
                          return const SizedBox.shrink();
                        }
                        final artti = _delta > 0;
                        return Transform.translate(
                          offset: Offset(0, -10 - 18 * t),
                          child: Opacity(
                            opacity: 1 - t,
                            child: Text(
                              '${artti ? '+' : '−'}${_delta.abs()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: artti
                                    ? const Color(0xFF2E9E5B)
                                    : const Color(0xFFE0524D),
                              ),
                            ),
                          ),
                        );
                      },
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