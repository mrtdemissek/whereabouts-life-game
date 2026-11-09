import 'dart:math';
import 'package:flutter/material.dart';
import 'acilis_ekrani.dart';
import 'atlas.dart';
import 'atlas_ekrani.dart';
import 'ayarlar_ekrani.dart';
import 'dil.dart';
import 'dogum_ekrani.dart';
import 'gecis.dart';
import 'gunluk.dart';
import 'karar_ekrani.dart';
import 'kaynaklar_ekrani.dart';
import 'muzik.dart';
import 'oyuncak.dart';
import 'rozet_ekrani.dart';
import 'sahne.dart';
import 'ses.dart';
import 'tema.dart';
import 'ulke.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  late Future<List<Ulke>> _ulkeler;
  AtlasDurumu _atlas = const AtlasDurumu({}, {});
  GunlukDurum _gunluk = const GunlukDurum(bugunTamam: false, seri: 0);

  @override
  void initState() {
    super.initState();
    _ulkeler = ulkeleriYukle();
    _durumuYenile();
    Muzik.ornek.cal(MuzikTuru.ana);
  }

  Future<void> _durumuYenile() async {
    final a = await atlasOku();
    final g = await gunlukDurumOku();
    if (!mounted) return;
    setState(() {
      _atlas = a;
      _gunluk = g;
    });
  }

  // Bir ekrana gider, dönünce atlası ve seriyi yeniler, ana müziği geri getirir
  Future<void> _git(Widget sayfa) async {
    await Navigator.push(context, yumusakGecis(sayfa));
    Muzik.ornek.cal(MuzikTuru.ana);
    _durumuYenile();
  }

  // Her ülke eşit şansla seçilir
  void _dog(List<Ulke> ulkeler) {
    Ses.ornek.cal(SesTuru.tik);
    Ses.ornek.titret(TitresimTuru.hafif);
    final hedef = ulkeler[Random().nextInt(ulkeler.length)];
    _git(DogumEkrani(ulkeler: ulkeler, hedef: hedef));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(oyunAdi),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: context.t('rozetler'),
            onPressed: () => _git(const RozetEkrani()),
          ),
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: context.t('atlas'),
            onPressed: () => _git(const AtlasEkrani()),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: context.t('kaynaklar'),
            onPressed: () => _git(const KaynaklarEkrani()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: context.t('ayarlar'),
            onPressed: () => _git(const AyarlarEkrani()),
          ),
        ],
      ),
      body: FutureBuilder<List<Ulke>>(
        future: _ulkeler,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                context.t('veri_okunamadi', {'hata': '${snap.error}'}),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final dil = context.yerel.kod;
          final ulkeler = snap.data!;
          final gunun = gununUlkesi(ulkeler);
          final ek = _gunluk.bugunTamam ? ' · ${context.t('bugun_tamam')}' : '';
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OyuncakKart(
                    renk: Renk.limon,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Text(
                      context.t('atlas_sayac', {
                        'n': _atlas.tamamSayisi,
                        'm': ulkeler.length,
                      }),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Sahne(
                    yas: 30,
                    ten: Color(0xFFD9A066),
                    gomlek: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.t('ana_alt'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 56,
                        vertical: 18,
                      ),
                    ),
                    onPressed: () => _dog(ulkeler),
                    child: Text(
                      context.t('dog'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _git(KararEkrani(ulke: gunun, gunluk: true)),
                    child: OyuncakKart(
                      renk: Renk.nane,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _gunluk.bugunTamam
                                ? Icons.check_circle
                                : Icons.today,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t('gunluk_baslik', {
                                    'ulke': gunun.adi(dil),
                                  }),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${context.t('gunluk_alt', {'seri': _gunluk.seri})}$ek',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}