import 'dart:math';
import 'package:flutter/material.dart';
import 'tema.dart';

// Oyun hissi için küçük efektler. Hepsi "Hareketi Azalt" ayarına uyar:
// o ayar açıkken sarsılma, zıplama ve büyüme yerine yalnızca renk/solma kalır.

// tetik her arttığında çocuğunu kısa ve sönümlü biçimde sarsar
class Sarsinti extends StatefulWidget {
  final int tetik;
  final Widget child;
  const Sarsinti({required this.tetik, required this.child, super.key});

  @override
  State<Sarsinti> createState() => _SarsintiState();
}

class _SarsintiState extends State<Sarsinti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void didUpdateWidget(covariant Sarsinti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tetik != oldWidget.tetik) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        // Azaltılmış harekette sarsılmaz, yalnızca kırmızı kenar parlar
        final hareketsiz = MediaQuery.of(context).disableAnimations;
        final dx = _c.isAnimating && !hareketsiz
            ? sin(t * pi * 7) * (1 - t) * 7
            : 0.0;
        return Stack(
          children: [
            Transform.translate(offset: Offset(dx, 0), child: child),
            // Kısa kırmızı kenar parlaması
            if (_c.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Renk.azalis.withValues(alpha: 0.45 * (1 - t)),
                        width: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Dönüm noktası afişi: ekranın ortasında büyüyerek belirir, sonra söner.
// tetik her arttığında yazi ile yeniden oynar.
class DonumAfisi extends StatefulWidget {
  final int tetik;
  final String? yazi;
  const DonumAfisi({required this.tetik, required this.yazi, super.key});

  @override
  State<DonumAfisi> createState() => _DonumAfisiState();
}

class _DonumAfisiState extends State<DonumAfisi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didUpdateWidget(covariant DonumAfisi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tetik != oldWidget.tetik && widget.yazi != null) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yazi = widget.yazi;
    if (yazi == null) return const SizedBox.shrink();
    final hareketsiz = MediaQuery.of(context).disableAnimations;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (!_c.isAnimating) return const SizedBox.shrink();
          final t = _c.value;
          // 0-0.15 büyüyerek gel, 0.15-0.8 dur, 0.8-1 sön
          final giris = (t / 0.15).clamp(0.0, 1.0);
          final cikis = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2).clamp(0.0, 1.0);
          final olcek = hareketsiz
              ? 1.0
              : Curves.elasticOut.transform(giris) * 0.4 + 0.6;
          return Opacity(
            opacity: (giris * cikis).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: olcek,
              child: Transform.rotate(
                angle: -0.03,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Renk.limon,
                    border: Border.all(color: Renk.murekkep, width: 4),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Renk.murekkep,
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    yazi,
                    textAlign: TextAlign.center,
                    style: Yazi.piksel(boyut: 22, kalinlik: FontWeight.w700),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Değer false'tan true'ya dönünce çocuğunu bir kez zıplatır (ör. hedef bayrağı)
class Ziplat extends StatelessWidget {
  final bool aktif;
  final Widget child;
  const Ziplat({required this.aktif, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey(aktif),
      tween: Tween(begin: aktif ? 1.35 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, v, c) => Transform.scale(scale: v, child: c),
      child: child,
    );
  }
}
