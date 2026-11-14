import 'dart:math';
import 'package:flutter/material.dart';
import 'dil.dart';
import 'gecis.dart';
import 'karar_ekrani.dart';
import 'oyun_sahnesi.dart';
import 'oyun_ui.dart';
import 'ses.dart';
import 'tema.dart';
import 'ulke.dart';

// Ülke adlarının bir slot makinesi gibi döndüğü, yavaşlayıp birinde durduğu
// doğum ekranı. Arkada dönen dünya ve bebek karakter.
class DogumEkrani extends StatefulWidget {
  final List<Ulke> ulkeler;
  final Ulke hedef;
  const DogumEkrani({required this.ulkeler, required this.hedef, super.key});

  @override
  State<DogumEkrani> createState() => _DogumEkraniState();
}

class _DogumEkraniState extends State<DogumEkrani> {
  late Ulke _gosterilen;
  bool _bitti = false;
  int _adim = 0;

  @override
  void initState() {
    super.initState();
    _gosterilen = widget.ulkeler[Random().nextInt(widget.ulkeler.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) => _dondur());
  }

  Future<void> _dondur() async {
    final r = Random();
    // Azaltılmış harekette dönme kısa tutulur
    final adim = MediaQuery.of(context).disableAnimations ? 3 : 22;
    for (var i = 0; i < adim; i++) {
      await Future.delayed(Duration(milliseconds: 40 + (i * i) ~/ 2));
      if (!mounted) return;
      setState(() {
        _gosterilen = widget.ulkeler[r.nextInt(widget.ulkeler.length)];
        _adim++;
      });
      Ses.ornek.cal(SesTuru.tik);
    }
    if (!mounted) return;
    setState(() {
      _gosterilen = widget.hedef;
      _adim++;
      _bitti = true;
    });
    Ses.ornek.cal(SesTuru.dogum);
    Ses.ornek.titret(TitresimTuru.orta);
  }

  // Oyunu açar, oyun bitip dönülünce ana ekrana geri çıkar
  Future<void> _basla() async {
    await Navigator.push(
      context,
      yumusakGecis(KararEkrani(ulke: widget.hedef)),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dil = context.yerel.kod;
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: OyunSahnesi(
              yas: 0,
              ten: Color(0xFFF2C29B),
              gomlek: Color(0xFF3F51B5),
              tepeOrani: 0.62,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, mq.padding.top + 40, 20, 0),
            child: Column(
              children: [
                Text(
                  context.t(_bitti ? 'dogum_sonuc' : 'dogum_donuyor'),
                  textAlign: TextAlign.center,
                  style: Yazi.piksel(boyut: 20),
                ),
                const SizedBox(height: 16),
                AnimatedScale(
                  scale: _bitti ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.elasticOut,
                  child: OyunPanel(
                    renk: _bitti ? Renk.limon : Renk.kagit,
                    kenar: 4,
                    golge: 6,
                    yaricap: 16,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ClipRect(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 90),
                          transitionBuilder: (child, anim) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.6),
                              end: Offset.zero,
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: FittedBox(
                            key: ValueKey(_adim),
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _gosterilen.adi(dil),
                              style: Yazi.piksel(boyut: 38, kalinlik: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedOpacity(
                  opacity: _bitti ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: OyunPanel(
                    golge: 0,
                    yaricap: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${context.t('dogum_beklenen')} ',
                            style: Yazi.piksel(boyut: 15),
                          ),
                          TextSpan(
                            text: '${widget.hedef.omur.round()}',
                            style: Yazi.sayi(boyut: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: _bitti ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_bitti,
                    child: OyunDugme(
                      renk: Renk.mercan,
                      yukseklik: 66,
                      golge: 6,
                      onTap: _bitti ? _basla : null,
                      child: Text(
                        '${context.t('hayata_basla').toUpperCase()} ▶',
                        style: Yazi.piksel(boyut: 26, kalinlik: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 + mq.padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
