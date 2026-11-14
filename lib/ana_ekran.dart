import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'acilis_ekrani.dart';
import 'atlas.dart';
import 'ayarlar_ekrani.dart';
import 'dil.dart';
import 'dogum_ekrani.dart';
import 'gecis.dart';
import 'gunluk.dart';
import 'hayat_karnesi.dart';
import 'karar_ekrani.dart';
import 'kaynaklar_ekrani.dart';
import 'koleksiyon_ekrani.dart';
import 'muzik.dart';
import 'nasil_oynanir.dart';
import 'oyun_sahnesi.dart';
import 'oyun_ui.dart';
import 'oyuncak.dart';
import 'ses.dart';
import 'tema.dart';
import 'ulke.dart';
import 'yildiz.dart';

// Seri alevi: O çerçeve, M turuncu, W sarı iç
const _alev = [
  '...OO...',
  '..OMMO..',
  '..OMMMO.',
  '.OMMMMO.',
  'OMMWWMMO',
  'OMWWWWMO',
  'OMWWWWMO',
  '.OMWWMO.',
  '..OOOO..',
];

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  late Future<List<Ulke>> _ulkeler;
  AtlasDurumu _atlas = const AtlasDurumu({}, {});
  GunlukDurum _gunluk = const GunlukDurum(bugunTamam: false, seri: 0);
  int _yildiz = 0;

  @override
  void initState() {
    super.initState();
    _ulkeler = ulkeleriYukle();
    _durumuYenile();
    Muzik.ornek.cal(MuzikTuru.ana);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ilkAnlatim());
  }

  // Oyun ilk kez açıldığında "Nasıl oynanır" kendiliğinden bir kez gösterilir
  Future<void> _ilkAnlatim() async {
    if (await nasilGorulduMu()) return;
    if (!mounted) return;
    await nasilGoruldu();
    if (!mounted) return;
    _git(const NasilOynanirEkrani());
  }

  Future<void> _durumuYenile() async {
    final a = await atlasOku();
    final g = await gunlukDurumOku();
    final y = await toplamYildiz();
    if (!mounted) return;
    setState(() {
      _atlas = a;
      _gunluk = g;
      _yildiz = y;
    });
  }

  // Bir ekrana gider, dönünce atlası, seriyi ve yıldızları yeniler
  Future<void> _git(Widget sayfa) async {
    await Navigator.push(context, yumusakGecis(sayfa));
    Muzik.ornek.cal(MuzikTuru.ana);
    _durumuYenile();
  }

  // Her ülke eşit şansla seçilir
  void _dog(List<Ulke> ulkeler) {
    Ses.ornek.cal(SesTuru.tik);
    final hedef = ulkeler[Random().nextInt(ulkeler.length)];
    _git(DogumEkrani(ulkeler: ulkeler, hedef: hedef));
  }

  // Üstteki küçük sayaç (yıldız, seri)
  Widget _sayac(Widget simge, String sayi, [String? ek]) {
    return OyunPanel(
      golge: 3,
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      yaricap: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          simge,
          const SizedBox(width: 6),
          Text(sayi, style: Yazi.sayi(boyut: 18)),
          if (ek != null) ...[
            const SizedBox(width: 4),
            Text(ek, style: Yazi.piksel(boyut: 16)),
          ],
        ],
      ),
    );
  }

  Widget _kucukDugme(IconData simge, String anlam, VoidCallback onTap) {
    return SizedBox(
      width: 46,
      child: OyunDugme(
        yukseklik: 44,
        golge: 3,
        anlam: anlam,
        onTap: onTap,
        child: Icon(simge, size: 22, color: Renk.murekkep),
      ),
    );
  }

  // Kalın mürekkep kenarlı piksel logo
  Widget _logo(BuildContext context) {
    final govde = GoogleFonts.pixelifySans(
      fontSize: 50,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            children: [
              Transform.translate(
                offset: const Offset(0, 6),
                child: Text(
                  oyunAdi,
                  style: govde.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 8
                      ..color = Renk.murekkep,
                  ),
                ),
              ),
              Text(
                oyunAdi,
                style: govde.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 8
                    ..color = Renk.murekkep,
                ),
              ),
              Text(oyunAdi, style: govde.copyWith(color: Renk.kagit)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Transform.rotate(
          angle: -0.035,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Renk.limon,
              border: Border.all(color: Renk.murekkep, width: 3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              context.t('oyun_alt_baslik'),
              style: Yazi.piksel(boyut: 20),
            ),
          ),
        ),
      ],
    );
  }

  // Alt sıradaki kare oyun düğmesi
  Widget _kareDugme({
    required IconData simge,
    required String yazi,
    String? sayi,
    required VoidCallback? onTap,
    Color renk = Renk.kagit,
  }) {
    return Expanded(
      child: OyunDugme(
        yukseklik: 74,
        renk: renk,
        anlam: yazi,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(simge, size: 26, color: Renk.murekkep),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: yazi, style: Yazi.piksel(boyut: 15)),
                  if (sayi != null)
                    TextSpan(text: ' $sayi', style: Yazi.sayi(boyut: 13)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final ust = mq.padding.top + 8;
    return Scaffold(
      body: FutureBuilder<List<Ulke>>(
        future: _ulkeler,
        builder: (context, snap) {
          final ulkeler = snap.data;
          final dil = context.yerel.kod;
          final gunun = ulkeler == null ? null : gununUlkesi(ulkeler);
          return Stack(
            children: [
              // Gökyüzü, dönen dünya ve "Bugün nerede doğacaksın?" diyen karakter
              Positioned.fill(
                child: OyunSahnesi(
                  yas: 30,
                  ten: const Color(0xFFD9A066),
                  gomlek: const Color(0xFFEF6C00),
                  balon: context.t('ana_balon'),
                  balonKalici: true,
                  tepeOrani: 0.58,
                  ustBosluk: ust + 230,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, ust, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _sayac(
                          const PikselYildiz(dolu: true, boyut: 22),
                          '$_yildiz',
                        ),
                        const SizedBox(width: 8),
                        _sayac(
                          PikselSimge(
                            sprite: _alev,
                            renk: const Color(0xFFFF8A5B),
                            piksel: 2.4,
                          ),
                          '${_gunluk.seri}',
                          context.t('gun'),
                        ),
                        const Spacer(),
                        _kucukDugme(
                          Icons.help_outline,
                          dil == 'tr' ? 'Nasıl oynanır?' : 'How to play',
                          () => _git(const NasilOynanirEkrani()),
                        ),
                        const SizedBox(width: 6),
                        _kucukDugme(
                          Icons.info_outline,
                          context.t('kaynaklar'),
                          () => _git(const KaynaklarEkrani()),
                        ),
                        const SizedBox(width: 6),
                        _kucukDugme(
                          Icons.settings,
                          context.t('ayarlar'),
                          () => _git(const AyarlarEkrani()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    _logo(context),
                    const Spacer(),
                    if (snap.hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OyunPanel(
                          child: Text(
                            context.t('veri_okunamadi', {
                              'hata': '${snap.error}',
                            }),
                          ),
                        ),
                      ),
                    OyunDugme(
                      renk: Renk.mercan,
                      yukseklik: 66,
                      golge: 6,
                      anlam: context.t('dog'),
                      onTap: ulkeler == null ? null : () => _dog(ulkeler),
                      child: Text(
                        context.t('yeni_hayat_dugme'),
                        style: Yazi.piksel(
                          boyut: 28,
                          kalinlik: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _kareDugme(
                          simge: _gunluk.bugunTamam
                              ? Icons.check_circle
                              : Icons.calendar_month,
                          yazi: context.t('gunluk_kisa'),
                          renk: _gunluk.bugunTamam ? Renk.nane : Renk.kagit,
                          onTap: gunun == null
                              ? null
                              : () => _git(
                                    KararEkrani(ulke: gunun, gunluk: true),
                                  ),
                        ),
                        const SizedBox(width: 10),
                        _kareDugme(
                          simge: Icons.public,
                          yazi: context.t('atlas'),
                          sayi: ulkeler == null
                              ? null
                              : '${_atlas.yasananSayisi}/${ulkeler.length}',
                          onTap: () => _git(const KoleksiyonEkrani()),
                        ),
                        const SizedBox(width: 10),
                        _kareDugme(
                          simge: Icons.workspace_premium,
                          yazi: context.t('rozetler'),
                          onTap: () => _git(const KoleksiyonEkrani(baslangic: 1)),
                        ),
                      ],
                    ),
                    SizedBox(height: 24 + mq.padding.bottom),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
