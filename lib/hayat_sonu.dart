import 'package:flutter/material.dart';
import 'dil.dart';
import 'rozet.dart';
import 'oyuncak.dart';
import 'tema.dart';
import 'yildiz.dart';

// Hayat bitince gösterilen kart: yıldızlar, mesaj, yeni rozetler
class HayatSonuKarti extends StatelessWidget {
  final String mesaj;
  final List<Rozet> yeniRozetler;
  final bool rozetleriGoster; // kutlama anı gelince true olur
  final VoidCallback yenidenBasla;
  final HayatYildizi? yildiz; // hesaplanınca gelir
  final int oncekiEnIyi; // bu ülkedeki önceki en iyi yıldız
  final String hedefAd;
  const HayatSonuKarti({
    required this.mesaj,
    required this.yeniRozetler,
    required this.rozetleriGoster,
    required this.yenidenBasla,
    this.yildiz,
    this.oncekiEnIyi = 0,
    this.hedefAd = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final y = yildiz;
    return Column(
      children: [
        if (y != null) ...[
          _YildizPaneli(yildiz: y, oncekiEnIyi: oncekiEnIyi, hedefAd: hedefAd),
          const SizedBox(height: 12),
        ],
        OyuncakKart(
          renk: Renk.limon,
          child: Text(
            mesaj,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        if (yeniRozetler.isNotEmpty && rozetleriGoster) ...[
          const SizedBox(height: 16),
          for (final r in yeniRozetler)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OyuncakKart(
                  renk: Renk.pembe,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t('yeni_rozet', {
                                'ad': context.t('rozet_${r.id}_ad'),
                              }),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(context.t('rozet_${r.id}_acik')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: yenidenBasla,
          child: Text(context.t('yeni_hayat')),
        ),
      ],
    );
  }
}

// Üç yıldız ve her birinin koşulu; kazanılanlar sırayla belirir
class _YildizPaneli extends StatelessWidget {
  final HayatYildizi yildiz;
  final int oncekiEnIyi;
  final String hedefAd;
  const _YildizPaneli({
    required this.yildiz,
    required this.oncekiEnIyi,
    required this.hedefAd,
  });

  @override
  Widget build(BuildContext context) {
    final kosullar = [
      (yildiz.omur, context.t('yildiz_omur')),
      (yildiz.hedef, '${context.t('yildiz_hedef')} ($hedefAd)'),
      (yildiz.denge, context.t('yildiz_denge')),
    ];
    final rekor = yildiz.sayi > oncekiEnIyi && yildiz.sayi > 0;
    return OyuncakKart(
      renk: Renk.kagit,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                _Yildiz(dolu: i < yildiz.sayi, gecikme: 250 + i * 350),
            ],
          ),
          const SizedBox(height: 8),
          for (final k in kosullar)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    k.$1 ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: k.$1 ? const Color(0xFF2E9E5B) : Renk.murekkep,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      k.$2,
                      style: TextStyle(
                        fontSize: 14,
                        color: k.$1
                            ? Renk.murekkep
                            : Renk.murekkep.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            rekor
                ? context.t('yildiz_rekor')
                : context.t('yildiz_onceki', {'n': oncekiEnIyi}),
            style: TextStyle(
              fontSize: 13,
              fontWeight: rekor ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Gecikmeyle büyüyerek beliren piksel yıldız
class _Yildiz extends StatefulWidget {
  final bool dolu;
  final int gecikme; // milisaniye
  const _Yildiz({required this.dolu, required this.gecikme});

  @override
  State<_Yildiz> createState() => _YildizState();
}

class _YildizState extends State<_Yildiz> {
  bool _gorundu = false;

  @override
  void initState() {
    super.initState();
    if (widget.dolu) {
      Future.delayed(Duration(milliseconds: widget.gecikme), () {
        if (mounted) setState(() => _gorundu = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Azaltılmış hareket ayarı açıksa yıldızlar beklemeden, animasyonsuz görünür
    final hareketsiz = MediaQuery.of(context).disableAnimations;
    final dolu = widget.dolu && (_gorundu || hareketsiz);
    final yildiz = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: CustomPaint(
        size: const Size(36, 36),
        painter: _YildizPainter(dolu),
      ),
    );
    if (!dolu || hareketsiz) return yildiz;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: yildiz,
    );
  }
}

// 9x9 piksel yıldız
const _yildizSprite = [
  '....O....',
  '...OYO...',
  '...OYO...',
  'OOOOYOOOO',
  'OYYYYYYYO',
  '.OYYYYYO.',
  '..OYYYO..',
  '.OYO.OYO.',
  'OO.....OO',
];

class _YildizPainter extends CustomPainter {
  final bool dolu;
  _YildizPainter(this.dolu);

  @override
  void paint(Canvas canvas, Size size) {
    final p = size.width / 9;
    final firca = Paint()..isAntiAlias = false;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final ch = _yildizSprite[r][c];
        if (ch == '.') continue;
        firca.color = ch == 'O'
            ? Renk.murekkep
            : (dolu ? const Color(0xFFFFD84D) : const Color(0xFFE6E0EE));
        canvas.drawRect(Rect.fromLTWH(c * p, r * p, p, p), firca);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _YildizPainter old) => old.dolu != dolu;
}
