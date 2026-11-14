import 'package:flutter/material.dart';
import 'dil.dart';
import 'karar.dart';
import 'ses.dart';
import 'tema.dart';

// Sağa/sola kaydırılabilir, kaydırırken eğilen karar kartı; arkasında iki
// kartlık bir deste görünür. Seçim düğmeleri de kartı aynı biçimde uçurur
// (secimYap). secildi(true): ekranda sağa, secildi(false): sola gitti.
// aynali: kartın sol ve sağ seçenek yazıları yer değiştirmiş mi.
// evre: kartın üstündeki yaş dönemi etiketi (ör. GENÇLİK).
class KaydirmaliKart extends StatefulWidget {
  final Karar karar;
  final int anahtar;
  final bool aynali;
  final String evre;
  final void Function(bool sag) secildi;
  const KaydirmaliKart({
    required this.karar,
    required this.anahtar,
    required this.secildi,
    this.aynali = false,
    this.evre = '',
    super.key,
  });

  @override
  State<KaydirmaliKart> createState() => KaydirmaliKartDurumu();
}

class KaydirmaliKartDurumu extends State<KaydirmaliKart>
    with SingleTickerProviderStateMixin {
  double _ilerleme = 0; // sürüklerken: sağa +, sola -
  late final AnimationController _ucus = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  int _ucusYonu = 0; // düğmeyle seçimde: 1 sağ, -1 sol

  bool get ucuyor => _ucusYonu != 0;

  @override
  void didUpdateWidget(covariant KaydirmaliKart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anahtar != widget.anahtar) {
      _ilerleme = 0;
      _ucusYonu = 0;
      _ucus.value = 0;
    }
  }

  @override
  void dispose() {
    _ucus.dispose();
    super.dispose();
  }

  // Düğmeyle seçim: kartı o yöne uçurur, sonra secildi'yi çağırır
  Future<void> secimYap(bool sagaGit) async {
    if (ucuyor) return;
    setState(() => _ucusYonu = sagaGit ? 1 : -1);
    Ses.ornek.cal(SesTuru.tik);
    // Azaltılmış harekette kart uçmaz, yerinde solar (aynı kısa sürede)
    await _ucus.forward(from: 0);
    if (!mounted) return;
    Ses.ornek.titret(TitresimTuru.secim);
    widget.secildi(sagaGit);
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
    final genislik = MediaQuery.of(context).size.width;
    final hareketsiz = MediaQuery.of(context).disableAnimations;

    final kart = Container(
      constraints: const BoxConstraints(minHeight: 168),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: zemin,
        border: Border.all(color: Renk.murekkep, width: 4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Renk.murekkep, offset: Offset(0, 6), blurRadius: 0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 26,
            child: Stack(
              children: [
                Row(
                  children: [
                    if (widget.evre.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Renk.gokMavisi,
                          border: Border.all(color: Renk.murekkep, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(widget.evre, style: Yazi.piksel(boyut: 12)),
                      ),
                    const Spacer(),
                    Opacity(
                      opacity: (1 - guc * 3).clamp(0.0, 1.0),
                      child: Text(
                        context.t('kaydir_ya_da_sec'),
                        style: Yazi.govde(boyut: 12, renk: Renk.soluk),
                      ),
                    ),
                  ],
                ),
                // Sürüklerken seçilecek seçenek kartın üstünde belirir
                Align(
                  alignment:
                      sagaMi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Opacity(
                    opacity: (guc * 3).clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Renk.kagit,
                        border: Border.all(color: Renk.murekkep, width: 2.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(etiket, style: Yazi.govde(boyut: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            metin,
            style: Yazi.govde(boyut: 19, kalinlik: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    Widget arkaKart(double aci, Color renk) => Positioned.fill(
          child: Transform.rotate(
            angle: aci,
            child: Container(
              decoration: BoxDecoration(
                color: renk,
                border: Border.all(color: Renk.murekkep, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );

    // Yeni kart hafifçe yukarı kayarak belirir
    return Stack(
      clipBehavior: Clip.none,
      children: [
        arkaKart(0.05, const Color(0xFFE9DFF7)),
        arkaKart(0.018, const Color(0xFFF4EEFB)),
        TweenAnimationBuilder<double>(
          key: ValueKey('giris${widget.anahtar}'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: hareketsiz ? 200 : 260),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, hareketsiz ? 0 : (1 - v) * 24),
              child: child,
            ),
          ),
          child: AnimatedBuilder(
            animation: _ucus,
            builder: (context, child) {
              final u = Curves.easeIn.transform(_ucus.value);
              if (hareketsiz) {
                return Opacity(opacity: 1 - u, child: child);
              }
              return Transform.translate(
                offset: Offset(_ucusYonu * u * genislik * 1.2, u * 40),
                child: Transform.rotate(
                  angle: _ucusYonu * u * 0.35 - 0.02,
                  child: child,
                ),
              );
            },
            child: Dismissible(
              key: ValueKey(widget.anahtar),
              direction: ucuyor
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              // Kart kayıp gidince boyunu küçültme: alttakilerin sıçramasını önler
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
                child: kart,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
