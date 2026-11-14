import 'dart:math';
import 'tohumlu.dart';
import 'package:flutter/material.dart';
import 'aile.dart';
import 'karar.dart';
import 'kart_secici.dart';
import 'olaylar.dart';
import 'olcu_paneli.dart';
import 'oyun_ui.dart';
import 'oyun_sahnesi.dart';
import 'kaydirmali_kart.dart';
import 'hayat_sonu.dart';
import 'ulke.dart';
import 'atlas.dart';
import 'rozet.dart';
import 'gunluk.dart';
import 'dil.dart';
import 'olum.dart';
import 'tema.dart';
import 'risk.dart';
import 'ses.dart';
import 'muzik.dart';
import 'piksel_karakter.dart';
import 'konfeti.dart';
import 'baglam.dart';
import 'hedef.dart';
import 'yildiz.dart';

const int baslangicYasi = 0;
const int kartBaslangicYasi = 5; // bundan önce kararları aile verir
const int yilAdimi = 3; // 30 yaşından sonra her karar kaç yıl ilerletir
const int genclikAdimi = 2; // 30 yaşına kadar her karar kaç yıl ilerletir
const int sifirCezasi = 6; // sıfırdaki her ölçünün sağlığa adım başı zararı

// Bu yaştayken bir karar kaç yıl ilerletir
int adimBul(int yas) => yas < 30 ? genclikAdimi : yilAdimi;

// Hayatın dönüm noktaları: yaş eşiği ve kısa anahtarı
const Map<int, String> _donumNoktalari = {
  6: 'okul',
  13: 'ergen',
  18: 'yetiskin',
  30: 'otuz',
  40: 'kirk',
  50: 'elli',
  65: 'emekli',
};

const Map<String, String> _donumTr = {
  'okul': 'Okul yıllarındasın.',
  'ergen': 'Ergenlik başladı.',
  'yetiskin': 'Artık yetişkinsin.',
  'otuz': 'Otuzlu yaşlara girdin.',
  'kirk': 'Kırklı yaşlara girdin.',
  'elli': 'Ellili yaşlara girdin.',
  'emekli': 'Emeklilik çağına geldin.',
};

const Map<String, String> _donumEn = {
  'okul': 'You are in your school years.',
  'ergen': 'Your teenage years begin.',
  'yetiskin': 'You are an adult now.',
  'otuz': 'You enter your thirties.',
  'kirk': 'You enter your forties.',
  'elli': 'You enter your fifties.',
  'emekli': 'You reach retirement age.',
};

// eski yaştan yeni yaşa geçerken aşılan en yüksek dönüm noktası, yoksa null
String? _donumBul(int eski, int yeni) {
  String? bulunan;
  for (final e in _donumNoktalari.entries) {
    if (eski < e.key && yeni >= e.key) bulunan = e.value;
  }
  return bulunan;
}

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
  int gecenYil = 0; // son seçimden sonra geçen yıl
  String? donumAnahtari; // son seçimde aşılan dönüm noktası
  Karar? kart;
  bool aynali = false; // bu kartın sol ve sağ seçeneği yer değiştirdi mi
  AileOlayi? olay;
  Tepki tepki = Tepki.yok; // karakterin son karara tepkisi
  int tepkiNo = 0;
  bool kutlama = false; // rozet kutlaması başladı mı
  final _kartAnahtari = GlobalKey<KaydirmaliKartDurumu>();
  late final Hedef hedef; // bu hayatın hedefi (doğumda seçilir)
  bool hedefAdimi = false; // son seçim hedefe ilk kez yaklaştırdı mı
  HayatYildizi? yildiz; // hayat bitince hesaplanır
  int oncekiEnIyi = 0; // bu ülkedeki önceki en iyi yıldız sayısı
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
    // Hayatın bağlamı: ülkenin koşulları ve yaşanılan yer
    etiketler.add(ulkeTuru(widget.ulke.omur));
    etiketler.add(g.nextBool() ? 'kent' : 'kir');
    hedef = hedefSec(g);
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
      oncelik: hedef.etiketler,
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
    final eskiYas = yas;
    final adim = adimBul(yas);
    final yeniEtiketler = sag ? k.sagEtiket : k.solEtiket;
    hedefAdimi = yeniEtiketler.any(hedef.etiketler.contains) &&
        !etiketler.any(hedef.etiketler.contains);
    etiketler.addAll(yeniEtiketler);
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
        final olum = olumYasi(yas, adim, widget.ulke.omur, saglik, _zar);
        if (olum != null) {
          _bitir(_Bitis.olum, olum);
        } else {
          yas += adim;
          gecenYil = adim;
          donumAnahtari = _donumBul(eskiYas, yas);
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
    final hedefOk = hedef.basarildiMi(
      hayatEtiketleri: etiketler,
      saglik: saglik,
      para: para,
      iliski: iliski,
      tamamlandi: tamamlandi,
    );
    final y = HayatYildizi(
      omur: tamamlandi,
      hedef: hedefOk,
      denge: olumYas >= 30 &&
          zaman >= 40 &&
          para >= 40 &&
          saglik >= 40 &&
          iliski >= 40,
    );
    final onceki = await yildizKaydet(widget.ulke.kod, y.sayi);
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
      yildiz = y;
      oncekiEnIyi = onceki;
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
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        metin,
        textAlign: TextAlign.center,
        style: Yazi.govde(boyut: 13, kalinlik: FontWeight.w800, renk: renk ?? Renk.murekkep),
      ),
    );
  }

  // Konuşma balonundaki sonuç cümlesi (yoksa null)
  String? _balonMetni(BuildContext context) {
    final goster = sonucAnahtari != null && !bitti && yas >= kartBaslangicYasi;
    return goster ? context.t(sonucAnahtari!) : null;
  }

  // Balonun altındaki küçük yazı: geçen yıl ve varsa dönüm noktası
  String _altYazi(BuildContext context) {
    final tr = context.yerel.kod == 'tr';
    final parcalar = <String>[];
    if (gecenYil > 0) {
      parcalar.add(tr ? '+$gecenYil yıl geçti' : '+$gecenYil years pass');
    }
    final donum = donumAnahtari;
    if (donum != null) {
      final m = tr ? _donumTr[donum] : _donumEn[donum];
      if (m != null) parcalar.add(m);
    }
    if (hedefAdimi) parcalar.add('★ ${context.t('hedef_yaklastin')}');
    return parcalar.join(' · ');
  }

  // Hedef çubuğuna dokununca hedefin açıklaması
  void _hedefAcikla() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.t('hedef_${hedef.id}_ad')),
        content: Text(ctx.t('hedef_${hedef.id}_acik')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Ölçülerin altındaki küçük hedef bayrağı
  Widget _hedefCubugu(BuildContext context) {
    final yaklasti = etiketler.any(hedef.etiketler.contains);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: _hedefAcikla,
          child: Container(
            constraints: const BoxConstraints(minHeight: 30),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: yaklasti ? Renk.limon : Renk.kagit,
              border: Border.all(color: Renk.murekkep, width: 3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  yaklasti ? Icons.flag : Icons.outlined_flag,
                  size: 16,
                  color: Renk.murekkep,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.t('hedef_etiket', {
                      'ad': context.t('hedef_${hedef.id}_ad'),
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Yazi.piksel(boyut: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Günlük meydan okuma rozetine dokununca uzun açıklama
  void _gunlukAcikla() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ctx.t('gunluk_banner'), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              ctx.t('gunluk_zar'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Üst çubuk: geri, ülke ve yaş, varsa günlük rozeti
  Widget _ustCubuk(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: OyunDugme(
            yukseklik: 44,
            golge: 3,
            anlam: context.t('geri'),
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, size: 24),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: OyunPanel(
              golge: 3,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 38,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.ulke.adi(context.yerel.kod),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Yazi.piksel(boyut: 17, kalinlik: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Renk.murekkep,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.t('yas_kisa'),
                            style: Yazi.piksel(boyut: 13, renk: Renk.kagit),
                          ),
                          const SizedBox(width: 4),
                          Text('$yas', style: Yazi.sayi(boyut: 14, renk: Renk.kagit)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.gunluk) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: OyunDugme(
              yukseklik: 44,
              golge: 3,
              anlam: context.t('gunluk_banner'),
              onTap: _gunlukAcikla,
              child: const Icon(Icons.calendar_month, size: 22),
            ),
          ),
        ],
      ],
    );
  }

  // Kart ve iki seçim düğmesi
  Widget _kartBolumu(BuildContext context, Karar k) {
    final solYazi = context.t('${k.id}_${aynali ? 'sag' : 'sol'}');
    final sagYazi = context.t('${k.id}_${aynali ? 'sol' : 'sag'}');
    Widget secim(String yazi, bool sag) => Expanded(
          child: OyunDugme(
            yukseklik: 58,
            anlam: yazi,
            onTap: () => _kartAnahtari.currentState?.secimYap(sag),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment:
                    sag ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!sag) Text('◀', style: Yazi.piksel(boyut: 18)),
                  if (!sag) const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      yazi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: sag ? TextAlign.right : TextAlign.left,
                      style: Yazi.govde(boyut: 14, kalinlik: FontWeight.w800),
                    ),
                  ),
                  if (sag) const SizedBox(width: 6),
                  if (sag) Text('▶', style: Yazi.piksel(boyut: 18)),
                ],
              ),
            ),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: KaydirmaliKart(
            key: _kartAnahtari,
            karar: k,
            anahtar: yas,
            aynali: aynali,
            evre: context.t('evre_${evreBul(yas).name}'),
            secildi: kararVer,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            secim(solYazi, false),
            const SizedBox(width: 12),
            secim(sagYazi, true),
          ],
        ),
        if (riskAyiklama && k is OlayKarti)
          Text(
            '[AYIKLAMA] olay kartı: ${k.id} (${k.riskAlan})',
            style: const TextStyle(fontSize: 12),
          ),
        if (etiketleriGoster)
          Text(
            'Etiketler: ${etiketler.join(', ')}',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  // İlk yıllar: aile anısı kartı ve "bir yıl geçsin" düğmesi
  Widget _ilkYillar(BuildContext context) {
    final o = olay!;
    final etkiler = <(String, int)>[
      ('zaman', o.etki.zaman),
      ('para', o.etki.para),
      ('saglik', o.etki.saglik),
      ('iliski', o.etki.iliski),
    ].where((e) => e.$2 != 0).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OyunPanel(
          golge: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          yaricap: 999,
          child: Text(context.t('ilk_yillar'), style: Yazi.piksel(boyut: 14)),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '$yas / $kartBaslangicYasi',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < kartBaslangicYasi; i++)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i <= yas ? Renk.mercan : Renk.kagit,
                    border: Border.all(color: Renk.murekkep, width: 2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OyunPanel(
          renk: Renk.krem,
          kenar: 4,
          golge: 6,
          yaricap: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: Renk.pembe,
                    border: Border.all(color: Renk.murekkep, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(context.t('aile_anisi'), style: Yazi.piksel(boyut: 12)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.t('aile_${o.id}'),
                textAlign: TextAlign.center,
                style: Yazi.govde(boyut: 18, kalinlik: FontWeight.w700),
              ),
              if (etkiler.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final e in etkiler)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: e.$2 > 0
                              ? const Color(0xFFDFF5E6)
                              : const Color(0xFFFFE1E1),
                          border: Border.all(color: Renk.murekkep, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${context.t('olcu_${e.$1}')} ',
                                style: Yazi.govde(boyut: 13, kalinlik: FontWeight.w800),
                              ),
                              TextSpan(
                                text: e.$2 > 0 ? '+${e.$2}' : '−${-e.$2}',
                                style: Yazi.sayi(boyut: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        OyunDugme(
          renk: Renk.lavanta,
          yukseklik: 60,
          golge: 5,
          onTap: bebeklikDevam,
          child: Text(
            context.t('bir_yil_gecsin'),
            style: Yazi.piksel(boyut: 21, kalinlik: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sifirda = zaman == 0 || para == 0 || iliski == 0;
    final k = kart;
    final mq = MediaQuery.of(context);
    final ust = mq.padding.top + 6;
    // üst çubuk (47) + boşluk (8) + ölçü paneli (~94) + hedef (~36)
    const ustAlan = 47.0 + 8 + 94 + 36;
    return Scaffold(
      body: Stack(
        children: [
          // Tam ekran sahne: gökyüzü, dönen dünya, karakter, konuşma balonu
          Positioned.fill(
            child: OyunSahnesi(
              yas: yas,
              ten: ten,
              gomlek: gomlek,
              tepki: tepki,
              tepkiNo: tepkiNo,
              bitti: bitti,
              balon: _balonMetni(context),
              altYazi: _altYazi(context),
              balonNo: tepkiNo,
              tepeOrani: 0.56,
              ustBosluk: ust + ustAlan + 4,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, ust, 12, 0),
            child: Column(
              children: [
                _ustCubuk(context),
                const SizedBox(height: 8),
                OlcuPaneli(
                  zaman: zaman,
                  para: para,
                  saglik: saglik,
                  iliski: iliski,
                ),
                if (!bitti) _hedefCubugu(context),
                if (!bitti && sifirda)
                  _uyari(context.t('sifir_uyari'), renk: Renk.azalis),
                if (!bitti && yas >= omurSuresi)
                  _uyari(context.t('omur_asildi')),
                Expanded(
                  child: bitti
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16, bottom: 24),
                          child: HayatSonuKarti(
                            mesaj: _bitisMesaji(context),
                            yeniRozetler: yeniRozetler,
                            rozetleriGoster: kutlama,
                            yildiz: yildiz,
                            oncekiEnIyi: oncekiEnIyi,
                            hedefAd: context.t('hedef_${hedef.id}_ad'),
                            yenidenBasla: () => Navigator.pop(context),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (yas < kartBaslangicYasi)
                              _ilkYillar(context)
                            else
                              _kartBolumu(context, k!),
                            SizedBox(height: 14 + mq.padding.bottom),
                          ],
                        ),
                ),
              ],
            ),
          ),
          if (kutlama) const Positioned.fill(child: Konfeti()),
        ],
      ),
    );
  }
}
