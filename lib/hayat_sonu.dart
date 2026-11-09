import 'package:flutter/material.dart';
import 'dil.dart';
import 'rozet.dart';
import 'oyuncak.dart';
import 'tema.dart';

// Hayat bitince gösterilen kart
class HayatSonuKarti extends StatelessWidget {
  final String mesaj;
  final List<Rozet> yeniRozetler;
  final bool rozetleriGoster; // kutlama anı gelince true olur
  final VoidCallback yenidenBasla;
  const HayatSonuKarti({
    required this.mesaj,
    required this.yeniRozetler,
    required this.rozetleriGoster,
    required this.yenidenBasla,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OyuncakKart(
          renk: Renk.limon,
          child: Text(
            mesaj,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
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