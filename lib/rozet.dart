import 'package:shared_preferences/shared_preferences.dart';

// Rozet türleri; koleksiyon ekranında bu sırayla gruplanır.
enum RozetTuru { kesif, omur, denge, hedef, yildiz, gunluk, karakter, gizli }

// Bir rozet: kimlik, tür. Ad ve açıklama çeviri dosyalarında
// rozet_<id>_ad ve rozet_<id>_acik anahtarlarıyla tutulur. Gizli rozetin adı
// ve koşulu kazanılana kadar görünmez.
class Rozet {
  final String id;
  final RozetTuru tur;
  const Rozet(this.id, this.tur);
  bool get gizli => tur == RozetTuru.gizli;
}

const tumRozetler = [
  // Keşif
  Rozet('ilk_nefes', RozetTuru.kesif),
  Rozet('gezgin', RozetTuru.kesif),
  Rozet('kasif', RozetTuru.kesif),
  Rozet('dunya_vatandasi', RozetTuru.kesif),
  Rozet('yuz_ulke', RozetTuru.kesif),
  Rozet('tamamlayici', RozetTuru.kesif),
  // Ömür
  Rozet('uzun_omur', RozetTuru.omur),
  Rozet('zor_baslangic', RozetTuru.omur),
  Rozet('doksan', RozetTuru.omur),
  Rozet('asirlik', RozetTuru.omur),
  Rozet('kirsal_omur', RozetTuru.omur),
  Rozet('sehir_omru', RozetTuru.omur),
  // Denge
  Rozet('dengeli', RozetTuru.denge),
  Rozet('kusursuz_denge', RozetTuru.denge),
  Rozet('varlikli', RozetTuru.denge),
  Rozet('dinc', RozetTuru.denge),
  Rozet('sevgi_dolu', RozetTuru.denge),
  Rozet('ozgur', RozetTuru.denge),
  // Hedef
  Rozet('ilk_hedef', RozetTuru.hedef),
  Rozet('hedef_girisim', RozetTuru.hedef),
  Rozet('hedef_aile', RozetTuru.hedef),
  Rozet('hedef_gezgin', RozetTuru.hedef),
  Rozet('hedef_saglik', RozetTuru.hedef),
  Rozet('hedef_bilgi', RozetTuru.hedef),
  Rozet('hedef_iyilik', RozetTuru.hedef),
  Rozet('hedef_sanat', RozetTuru.hedef),
  Rozet('hedef_sevilen', RozetTuru.hedef),
  Rozet('hedef_birikim', RozetTuru.hedef),
  Rozet('hedef_ustasi', RozetTuru.hedef),
  // Yıldız
  Rozet('uc_yildiz', RozetTuru.yildiz),
  Rozet('yildiz_25', RozetTuru.yildiz),
  Rozet('yildiz_100', RozetTuru.yildiz),
  // Günlük
  Rozet('gunluk_ilk', RozetTuru.gunluk),
  Rozet('seri_7', RozetTuru.gunluk),
  Rozet('seri_30', RozetTuru.gunluk),
  // Karakter (seçimlerin bıraktığı izler)
  Rozet('cesur_yurek', RozetTuru.karakter),
  Rozet('durust_insan', RozetTuru.karakter),
  Rozet('gonul_eri', RozetTuru.karakter),
  Rozet('kitap_kurdu', RozetTuru.karakter),
  Rozet('kaptan', RozetTuru.karakter),
  // Gizli
  Rozet('deja_vu', RozetTuru.gizli),
  Rozet('dar_kurtulus', RozetTuru.gizli),
  Rozet('tam_vaktinde', RozetTuru.gizli),
];

// Biten bir hayatın rozetler için gereken özeti
class HayatOzeti {
  final bool tamamlandi; // ülkenin beklenen yaşına ulaşıldı mı
  final double ulkeOmru;
  final int olumYas;
  final int zaman;
  final int para;
  final int saglik;
  final int iliski;
  final Set<String> etiketler; // hayatın etiketleri (kir/kent dahil)
  final String hedefId;
  final bool hedefBasarildi;
  final int yildiz; // bu hayatın yıldızı (0-3)
  final int toplamYildiz; // tüm ülkelerin en iyileri toplamı (kayıttan sonra)
  final int yasananUlke; // kayıttan sonra
  final int tamamlananUlke; // kayıttan sonra
  final bool ulkeDahaOnceDenendi; // bu ülkede daha önce doğulmuş muydu
  final bool gunlukTamamlandi;
  final int gunlukSeri;
  final int enDusukSaglik; // hayat boyunca sağlığın en düşük değeri
  const HayatOzeti({
    required this.tamamlandi,
    required this.ulkeOmru,
    required this.olumYas,
    required this.zaman,
    required this.para,
    required this.saglik,
    required this.iliski,
    required this.etiketler,
    required this.hedefId,
    required this.hedefBasarildi,
    required this.yildiz,
    required this.toplamYildiz,
    required this.yasananUlke,
    required this.tamamlananUlke,
    required this.ulkeDahaOnceDenendi,
    required this.gunlukTamamlandi,
    required this.gunlukSeri,
    required this.enDusukSaglik,
  });
}

// Bir hayatın hak ettiği rozetler (saf hesap; kayıt yapmaz).
// mevcut: daha önce kazanılmış rozetler (hedef ustası için gerekir).
Set<String> hakEdilenRozetler(HayatOzeti o, Set<String> mevcut) {
  final h = <String>{'ilk_nefes'};
  if (o.yasananUlke >= 5) h.add('gezgin');
  if (o.yasananUlke >= 15) h.add('kasif');
  if (o.yasananUlke >= 50) h.add('dunya_vatandasi');
  if (o.yasananUlke >= 100) h.add('yuz_ulke');
  if (o.tamamlananUlke >= 10) h.add('tamamlayici');

  if (o.tamamlandi) {
    h.add('uzun_omur');
    if (o.ulkeOmru < 65) h.add('zor_baslangic');
    if (o.etiketler.contains('kir')) h.add('kirsal_omur');
    if (o.etiketler.contains('kent')) h.add('sehir_omru');
  }
  if (o.olumYas >= 90) h.add('doksan');
  if (o.olumYas >= 100) h.add('asirlik');

  final yetiskin = o.olumYas >= 30;
  final olculer = [o.zaman, o.para, o.saglik, o.iliski];
  if (yetiskin && o.tamamlandi && olculer.every((v) => v > 40)) {
    h.add('dengeli');
  }
  if (yetiskin && olculer.every((v) => v >= 70)) h.add('kusursuz_denge');
  if (yetiskin && o.para >= 90) h.add('varlikli');
  if (o.olumYas >= 60 && o.saglik >= 90) h.add('dinc');
  if (yetiskin && o.iliski >= 90) h.add('sevgi_dolu');
  if (yetiskin && o.zaman >= 90) h.add('ozgur');

  if (o.hedefBasarildi) {
    h.add('ilk_hedef');
    h.add('hedef_${o.hedefId}');
  }
  final hedefRozetleri = tumRozetler
      .where((r) => r.id.startsWith('hedef_') && r.id != 'hedef_ustasi')
      .map((r) => r.id);
  if (hedefRozetleri.every((id) => mevcut.contains(id) || h.contains(id))) {
    h.add('hedef_ustasi');
  }

  if (o.yildiz >= 3) h.add('uc_yildiz');
  if (o.toplamYildiz >= 25) h.add('yildiz_25');
  if (o.toplamYildiz >= 100) h.add('yildiz_100');

  if (o.gunlukTamamlandi) h.add('gunluk_ilk');
  if (o.gunlukSeri >= 7) h.add('seri_7');
  if (o.gunlukSeri >= 30) h.add('seri_30');

  if (o.etiketler.contains('cesur')) h.add('cesur_yurek');
  if (o.etiketler.contains('durust')) h.add('durust_insan');
  if (o.etiketler.contains('gonullu') && o.etiketler.contains('yardimsever')) {
    h.add('gonul_eri');
  }
  if (o.etiketler.contains('okur') && o.etiketler.contains('burslu')) {
    h.add('kitap_kurdu');
  }
  if (o.etiketler.contains('kaptan') || o.etiketler.contains('lider')) {
    h.add('kaptan');
  }

  if (o.ulkeDahaOnceDenendi) h.add('deja_vu');
  if (o.tamamlandi && o.enDusukSaglik <= 10) h.add('dar_kurtulus');
  if (o.olumYas == o.ulkeOmru.round()) h.add('tam_vaktinde');

  // Yalnızca tanımlı rozetler
  final tanimli = tumRozetler.map((r) => r.id).toSet();
  return h.intersection(tanimli);
}

const _anahtar = 'kazanilan_rozetler';

// Kazanılmış rozetlerin kimliklerini telefondan okur
Future<Set<String>> kazanilanRozetleriOku() async {
  final tercihler = await SharedPreferences.getInstance();
  return (tercihler.getStringList(_anahtar) ?? <String>[]).toSet();
}

// Biten bir hayata göre rozetleri değerlendirir, yeni kazanılanları
// telefona kaydeder ve döndürür.
Future<List<Rozet>> rozetleriDegerlendir(HayatOzeti o) async {
  final tercihler = await SharedPreferences.getInstance();
  final mevcut = (tercihler.getStringList(_anahtar) ?? <String>[]).toSet();
  final hak = hakEdilenRozetler(o, mevcut);
  final yeniler = tumRozetler
      .where((r) => hak.contains(r.id) && !mevcut.contains(r.id))
      .toList();
  if (yeniler.isNotEmpty) {
    mevcut.addAll(yeniler.map((r) => r.id));
    await tercihler.setStringList(_anahtar, mevcut.toList());
  }
  return yeniler;
}
