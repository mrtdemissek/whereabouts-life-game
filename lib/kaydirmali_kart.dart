import 'package:flutter/material.dart';
import 'dil.dart';
import 'karar.dart';
import 'oyuncak.dart';
import 'ses.dart';
import 'tema.dart';

// Sağa/sola kaydırılabilir, kaydırırken eğilen karar kartı.
// secildi(true): ekranda sağa kaydırıldı, secildi(false): sola kaydırıldı.
// aynali: kartın sol ve sağ seçenek yazıları yer değiştirmiş mi.
class KaydirmaliKart extends StatefulWidget {
  final Karar karar;
  final int anahtar;
  final bool aynali;
  final void Function(bool sag) secildi;
  const KaydirmaliKart({
    required this.karar,
    required this.anahtar,
    required this.secildi,
    this.aynali = false,
    super.key,
  });

  @override
  State<KaydirmaliKart> createState() => _KaydirmaliKartState();
}

class _KaydirmaliKartState extends State<KaydirmaliKart> {
  double _ilerleme = 0; // sağa +, sola -

  @override
  void didUpdateWidget(covariant KaydirmaliKart old) {
    super.didUpdateWidget(old);
    if (old.anahtar != widget.anahtar) _ilerleme = 0;
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.karar;
    final metin = context.t('${k.id}_metin');
    final solYazi = context.t('${k.id}_${widget.aynali ? 'sag' : 'sol'}');
    final sagYazi = context.t('${k.id}_${widget.aynali ? 'sol' : 'sag'}');
    final guc = _ilerleme.abs().clamp(0.0, 1.0);
    final sagaMi = _ilerleme > 0;
    final etiket = sagaMi ? sagYazi : solYazi;
    final zemin = Color.lerp(
      Renk.kagit,
      sagaMi ? Renk.nane : Renk.seftali,
      guc,
    )!;

    // Yeni kart hafifçe yukarı kayarak belirir
    return TweenAnimationBuilder<double>(
      key: ValueKey('giris${widget.anahtar}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 24),
          child: child,
        ),
      ),
      child: Dismissible(
        key: ValueKey(widget.anahtar),
        direction: DismissDirection.horizontal,
        // Kart kayıp gidince boyunu küçültme: alttaki her şeyin sıçramasını önler
        resizeDuration: null,
        onUpdate: (d) {
          // Karar eşiği aşıldığı anda kısa bir tık ve hafif titreşim
          if (d.reached && !d.previousReached) {
            Ses.ornek.cal(SesTuru.tik);
            Ses.ornek.titret(TitresimTuru.hafif);
          }
          setState(() {
            _ilerleme = d.direction == DismissDirection.startToEnd
                ? d.progress
                : -d.progress;
          });
        },
        onDismissed: (yon) {
          Ses.ornek.titret(TitresimTuru.secim);
          widget.secildi(yon == DismissDirection.startToEnd);
        },
        child: Transform.rotate(
          angle: _ilerleme * 0.25,
          child: OyuncakKart(
            renk: zemin,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment:
                      sagaMi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Opacity(
                    opacity: (guc * 3).clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Renk.kagit,
                        border: Border.all(color: Renk.murekkep, width: 2.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        etiket,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  metin,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}