import 'dart:math';
import 'package:flutter/material.dart';
import 'dil.dart';
import 'gecis.dart';
import 'karar_ekrani.dart';
import 'oyuncak.dart';
import 'sahne.dart';
import 'ses.dart';
import 'tema.dart';
import 'ulke.dart';

// Ülke adlarının döndüğü, yavaşlayıp birinde durduğu doğum ekranı
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

  @override
  void initState() {
    super.initState();
    _gosterilen = widget.ulkeler[Random().nextInt(widget.ulkeler.length)];
    _dondur();
  }

  Future<void> _dondur() async {
    final r = Random();
    const adim = 22;
    for (var i = 0; i < adim; i++) {
      await Future.delayed(Duration(milliseconds: 40 + (i * i) ~/ 2));
      if (!mounted) return;
      setState(() {
        _gosterilen = widget.ulkeler[r.nextInt(widget.ulkeler.length)];
      });
      Ses.ornek.cal(SesTuru.tik);
    }
    if (!mounted) return;
    setState(() {
      _gosterilen = widget.hedef;
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t(_bitti ? 'dogum_sonuc' : 'dogum_donuyor'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                AnimatedScale(
                  scale: _bitti ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  child: OyuncakKart(
                    renk: _bitti ? Renk.lavanta : Renk.kagit,
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 16,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _gosterilen.adi(dil),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: _bitti ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    context.t('omur_alt', {'omur': widget.hedef.omur}),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                const Sahne(
                  yas: 5,
                  ten: Color(0xFFF2C29B),
                  gomlek: Color(0xFF3F51B5),
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  opacity: _bitti ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_bitti,
                    child: ElevatedButton(
                      onPressed: _basla,
                      child: Text(context.t('hayata_basla')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}