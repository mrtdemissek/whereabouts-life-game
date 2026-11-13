import 'dart:math';
import 'tohumlu.dart';
import 'package:flutter/material.dart';
import 'aile.dart';
import 'karar.dart';
import 'kart_secici.dart';
import 'olaylar.dart';
import 'parcalar.dart';
import 'kaydirmali_kart.dart';
import 'hayat_sonu.dart';
import 'ulke.dart';
import 'atlas.dart';
import 'rozet.dart';
import 'gunluk.dart';
import 'sahne.dart';
import 'dil.dart';
import 'olum.dart';
import 'oyuncak.dart';
import 'tema.dart';
import 'risk.dart';
import 'ses.dart';
import 'muzik.dart';
import 'piksel_karakter.dart';
import 'konfeti.dart';

const int baslangicYasi = 0;
const int kartBaslangicYasi = 5; // bundan önce kararları aile verir
const int yilAdimi = 3; // kartlı dönemde her karar kaç yıl ilerletir
const int sifirCezasi = 6; // sıfırdaki her ölçünün sağlığa adım başı zararı

// TEST için: true yapınca hayatın etiketleri kartın altında görünür
const bool etiketleriGoster = false;

// TEST için: true yapınca risk skorları ve olay kartı işareti görünür
const bool riskAyiklama = false;

// TEST için: true yapınca rozet kazanmasan da hayat sonunda konfeti ve rozet sesi çalar
const bool kutlamaDene = false;

const _tenler = [
  Color(0xFFF2C29B),
  Color(0xFFD9A066),
  Color(0xFFB07A4F),
  Color(0xFF8A5A3C),
  Color(0xFF5E3B27),
];

const _gomlekler = [
  Color(0xFF3F51B5),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFFEF6C00),
  Color(0xFF6A1B9A),
];

enum _Bitis { yok, olum, saglik }

enum _GunlukSonuc { yok, tamam, basarisiz }

class KararEkrani extends StatefulWidget {
  final Ulke ulke;
  final bool gunluk;
  const KararEkrani({required this.ulke, this.gunluk = false, super.key});

  @override
  State<KararEkrani> createState() => _KararEkraniState();
}

class _KararEkraniState extends State<KararEkrani> {
  final Random _r = Random();
  // Günlük meydan okumada herkes için aynı tohum
  late final int _tohum = gunlukTohum(widget.ulke.kod);
  int yas = baslangicYasi;
  int zaman = 50;
  int para = 50;
  int saglik = 50;
  int iliski = 50;
  _Bitis bitis = _Bitis.yok;
  int olumYas = 0;
  bool tamamlandi = false;
  OlumNedeni? olumNedeni;
  UlkeRiskleri? risk;
  _GunlukSonuc gunlukSonuc = _GunlukSonuc.yok;
  int seri = 0;
  List<Rozet> yeniRozetler = [];
  final List<Karar> gecmis = [];
  final Set<String> kullanilanOlaylar = {};
  final Set<String> etiketler = {};
  String? sonucAnahtari; // son seçimin sonuç cümlesinin çeviri anahtarı
  Karar? kart;
  bool aynali = false; // bu kartın sol ve sağ seçeneği yer değiştirdi mi
  AileOlayi? olay;
  Tepki tepki = Tepki.yok; // karakterin son karara tepkisi
  int tepkiNo = 0;
  bool kutlama = false; // rozet kutlaması başladı mı
  late final Color ten;
  late final Color gomlek;

  bool get bitti => bitis != _Bitis.yok;

  // Ülke, ölüm yaşı bu değere eşit ya da büyükse tamamlanır
  int get omurSuresi => widget.ulke.omur.round();

  // Rastgelelik kaynağı. Günlük meydan okumada seçilen amaç (tuz) ve yaş için
  // sabit; normal hayatta her seferinde rastgele.
  // tuz: 1 kart seçimi, 2 aile hikâyesi, 3 ölüm nedeni, 5 kart aynalama
  Random _rnd(int tuz, int y) =>
      widget.gunluk ? Tohumlu(_tohum + tuz * 100003 + y) : _r;

  // Bir yaş için ölüm zarı: günlükte yaşa göre sabit, normalde rastgele
  double _zar(int y) => widget.gunluk
      ? Tohumlu(_tohum + 4 * 100003 + y).nextDouble()
      : _r.nextDouble();

  @override
  void initState() {
    super.initState();
    final g = widget.gunluk ? Tohumlu(_tohum) : _r;
    ten = _tenler[g.nextInt(_tenler.length)];
    gomlek = _gomlekler[g.nextInt(_gomlekler.length)];
    riskleriYukle().then((harita) {
      risk = harita[widget.ulke.kod];
    });
    _olayiSec();
    Muzik.ornek.cal(MuzikTuru.oyun);
  }

  int _sinirla(int v) => v.clamp(0, 100).toInt();

  // Hayatı y yaşında bitirir. setState içinde çağrılmalı.
  void _bitir(_Bitis tur, int y) {
    bitis = tur;
    olumYas = y;
    yas = y;
    tamamlandi = y >= omurSuresi;
    olumNedeni = tur == _Bitis.olum
        ? olumNedeniSec(y, widget.ulke.omur, risk, _rnd(3, y))
        : null;
  }

  void _sonrakiKart() {
    final k = yeniKartSec(
      yas,
      gecmis,
      etiketler,
      risk: risk,
      omur: widget.ulke.omur,
      rnd: _rnd(1, yas),
    );
    kart = k;
    // Yarı yarıya aynala: hangi yönün neyi verdiği her kartta değişir
    aynali = _rnd(5, yas).nextBool();
    gecmis.add(k);
  }

  // Bu yaşın aile hikâyesini seçer ve etkisini ölçülere uygular
  void _olayiSec() {
    final o = aileOlayiSec(
      yas,
      widget.ulke.omur,
      kullanilanOlaylar,
      _rnd(2, yas),
    );
    olay = o;
    kullanilanOlaylar.add(o.id);
    zaman = _sinirla(zaman + o.etki.zaman);
    para = _sinirla(para + o.etki.para);
    saglik = _sinirla(saglik + o.etki.saglik);
    iliski = _sinirla(iliski + o.etki.iliski);
  }

  // Dört ölçüdeki net değişime göre tek bir ses, titreşim ve karakter tepkisi
  void _olcuSesi(List<int> onceki) {
    final simdi = [zaman, para, saglik, iliski];
    var net = 0;
    for (var i = 0; i < 4; i++) {
      net += simdi[i] - onceki[i];
    }
    final ses = Ses.ornek;
    if (net > 0) {
      ses.cal(SesTuru.artis);
      ses.titret(TitresimTuru.hafif);
    } else if (net < 0) {
      ses.cal(SesTuru.azalis);
      ses.titret(net <= -15 ? TitresimTuru.orta : TitresimTuru.hafif);
    } else {
      ses.cal(SesTuru.secim);
    }
    setState(() {
      tepki = net > 0
          ? Tepki.sevinc
          : net < 0
              ? Tepki.uzuntu
              : Tepki.yok;
      tepkiNo++;
    });
  }

  // Hayat bitince: kapanış sesi, güçlü titreşim, müzik yavaşça kısılır
  void _sonSesi() {
    Ses.ornek.cal(SesTuru.son);
    Ses.ornek.titret(TitresimTuru.guclu);
    Muzik.ornek.durdur();
  }

  // Bebeklik ve erken çocukluk: kararları aile verir, oyuncu yalnızca devam eder
  void bebeklikDevam() {
    final onceki = [zaman, para, saglik, iliski];
    final olum = olumYasi(yas, 1, widget.ulke.omur, saglik, _zar);
    setState(() {
      if (olum != null) {
        _bitir(_Bitis.olum, olum);
      } else {
        yas += 1;
        if (yas >= kartBaslangicYasi) {
          _sonrakiKart();
        } else {
          _olayiSec();
        }
      }
    });
    if (bitti) {
      _sonSesi();
      _hayatiKaydet();
    } else {
      _olcuSesi(onceki);
    }
  }

  // kaydirilanSag: oyuncu kartı ekranda sağa mı kaydırdı.
  // Kart aynalıysa ekranın sağı kartın sol seçeneğidir.
  void kararVer(bool kaydirilanSag) {
    final sag = aynali ? !kaydirilanSag : kaydirilanSag;
    final k = kart!;
    final e = sag ? k.sag : k.sol;
    final onceki = [zaman, para, saglik, iliski];
    etiketler.addAll(sag ? k.sagEtiket : k.solEtiket);
    sonucAnahtari = '${k.id}_${sag ? 'sag' : 'sol'}_son';

    setState(() {
      zaman = _sinirla(zaman + e.zaman);
      para = _sinirla(para + e.para);
      saglik = _sinirla(saglik + e.saglik);
      iliski = _sinirla(iliski + e.iliski);

      // Sıfırdaki ölçüler sağlığı yıpratır
      final sifirda =
          (zaman == 0 ? 1 : 0) + (para == 0 ? 1 : 0) + (iliski == 0 ? 1 : 0);
      saglik = _sinirla(saglik - sifirCezasi * sifirda);

      if (saglik == 0) {
        _bitir(_Bitis.saglik, yas);
      } else {
        final olum = olumYasi(yas, yilAdimi, widget.ulke.omur, saglik, _zar);
        if (olum != null) {
          _bitir(_Bitis.olum, olum);
        } else {
          yas += yilAdimi;
          _sonrakiKart();
        }
      }
    });
    if (bitti) {
      _sonSesi();
      _hayatiKaydet();
    } else {
      _olcuSesi(onceki);
    }
  }

  // Ülkeyi atlasa işler, rozetleri ve günlük seriyi değerlendirir
  Future<void> _hayatiKaydet() async {
    await ulkeyiIsaretle(widget.ulke.kod, tamamlandi: tamamlandi);
    final sayi = await yasananUlkeSayisi();
    final yeniler = await rozetleriDegerlendir(
      dogalSon: tamamlandi,
      ulkeOmru: widget.ulke.omur,
      zaman: zaman,
      para: para,
      saglik: saglik,
      iliski: iliski,
      yasananUlkeSayisi: sayi,
    );
    var sonuc = _GunlukSonuc.yok;
    var yeniSeri = 0;
    if (widget.gunluk) {
      if (tamamlandi) {
        yeniSeri = await gunlukTamamla();
        sonuc = _GunlukSonuc.tamam;
      } else {
        sonuc = _GunlukSonuc.basarisiz;
      }
    }
    if (!mounted) return;
    setState(() {
      yeniRozetler = yeniler;
      gunlukSonuc = sonuc;
      seri = yeniSeri;
    });
    if (yeniler.isNotEmpty || kutlamaDene) {
      // Hayatın sonu sesinin bitmesini bekleyip kutlamayı başlat
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => kutlama = true);
        Ses.ornek.cal(SesTuru.rozet);
        Ses.ornek.titret(TitresimTuru.guclu);
      });
    }
  }

  String _bitisMesaji(BuildContext context) {
    String m;
    if (bitis == _Bitis.saglik) {
      m = context.t('bitis_olcu', {'yas': olumYas});
    } else if (olumYas < kartBaslangicYasi) {
      m = context.t('bitis_bebek', {'yas': olumYas});
    } else {
      m = context.t('bitis_dogal', {'yas': olumYas});
    }
    final neden = olumNedeni;
    if (neden != null) {
      m += '\n${context.t('neden_etiket', {
            'neden': context.t('neden_${neden.name}'),
          })}';
    }
    m += '\n\n${context.t('omur_alt', {'omur': widget.ulke.omur})}';
    m += '\n${context.t(tamamlandi ? 'ulke_tamamlandi' : 'ulke_tamamlanmadi')}';
    if (gunlukSonuc == _GunlukSonuc.tamam) {
      m += '\n\n${context.t('gunluk_tamam', {'seri': seri})}';
    } else if (gunlukSonuc == _GunlukSonuc.basarisiz) {
      m += '\n\n${context.t('gunluk_basarisiz')}';
    }
    if (riskAyiklama) {
      final r = risk;
      m += '\n\n[AYIKLAMA] ';
      m += r == null
          ? 'risk verisi YOK'
          : r.skorlar.entries
              .map((e) => '${e.key}: ${e.value ?? '-'}')
              .join(', ');
    }
    return m;
  }

  Widget _uyari(String metin, {Color? renk}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        metin,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: renk,
        ),
      ),
    );
  }

  // Son seçimin sonucunu anlatan küçük kutu
  Widget _sonucKutusu(BuildContext context) {
    final goster = sonucAnahtari != null && !bitti && yas >= kartBaslangicYasi;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !goster
          ? const SizedBox.shrink(key: ValueKey('bos'))
          : Padding(
              key: ValueKey('$sonucAnahtari$yas'),
              padding: const EdgeInsets.only(bottom: 12),
              child: OyuncakKart(
                renk: Renk.gokMavisi,
                padding: const EdgeInsets.all(12),
                child: Text(
                  context.t(sonucAnahtari!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sifirda = zaman == 0 || para == 0 || iliski == 0;
    final k = kart;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.t('oyun_baslik', {
            'ulke': widget.ulke.adi(context.yerel.kod),
            'yas': yas,
          }),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.gunluk)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Text(
                            context.t('gunluk_banner'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.t('gunluk_zar'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  Olcu(OlcuTuru.zaman, zaman),
                  Olcu(OlcuTuru.para, para),
                  Olcu(OlcuTuru.saglik, saglik),
                  Olcu(OlcuTuru.iliski, iliski),
                  const SizedBox(height: 16),
                  Sahne(
                    yas: yas,
                    ten: ten,
                    gomlek: gomlek,
                    tepki: tepki,
                    tepkiNo: tepkiNo,
                    bitti: bitti,
                  ),
                  if (!bitti && sifirda)
                    _uyari(
                      context.t('sifir_uyari'),
                      renk: const Color(0xFFE0524D),
                    ),
                  if (!bitti && yas >= omurSuresi)
                    _uyari(context.t('omur_asildi')),
                  const SizedBox(height: 16),
                  _sonucKutusu(context),
                  if (bitti)
                    HayatSonuKarti(
                      mesaj: _bitisMesaji(context),
                      yeniRozetler: yeniRozetler,
                      rozetleriGoster: kutlama,
                      yenidenBasla: () => Navigator.pop(context),
                    )
                  else if (yas < kartBaslangicYasi) ...[
                    Text(
                      context.t('bebeklik_metin'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    OyuncakKart(
                      child: Text(
                        context.t('aile_${olay!.id}'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: bebeklikDevam,
                      child: Text(context.t('devam')),
                    ),
                  ] else ...[
                    KaydirmaliKart(
                      karar: k!,
                      anahtar: yas,
                      aynali: aynali,
                      secildi: kararVer,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '← ${context.t('${k.id}_${aynali ? 'sag' : 'sol'}')}',
                        ),
                        Text(
                          '${context.t('${k.id}_${aynali ? 'sol' : 'sag'}')} →',
                        ),
                      ],
                    ),
                    if (riskAyiklama && k is OlayKarti)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '[AYIKLAMA] olay kartı: ${k.id} (${k.riskAlan})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    if (etiketleriGoster)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Etiketler: ${etiketler.join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (kutlama) const Positioned.fill(child: Konfeti()),
        ],
      ),
    );
  }
}