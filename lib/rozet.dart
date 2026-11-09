import 'package:shared_preferences/shared_preferences.dart';

// Bir rozet yalnızca kimlik taşır. Ad ve açıklama çeviri dosyalarında
// rozet_<id>_ad ve rozet_<id>_acik anahtarlarıyla tutulur.
class Rozet {
  final String id;
  const Rozet(this.id);
}

const tumRozetler = [
  Rozet('ilk_nefes'),
  Rozet('gezgin'),
  Rozet('uzun_omur'),
  Rozet('dengeli'),
  Rozet('zor_baslangic'),
];

const _anahtar = 'kazanilan_rozetler';

// Kazanılmış rozetlerin kimliklerini telefondan okur
Future<Set<String>> kazanilanRozetleriOku() async {
  final tercihler = await SharedPreferences.getInstance();
  return (tercihler.getStringList(_anahtar) ?? <String>[]).toSet();
}

// Biten bir hayata göre rozetleri değerlendirir, yeni kazanılanları
// telefona kaydeder ve döndürür.
Future<List<Rozet>> rozetleriDegerlendir({
  required bool dogalSon, // hayat yaşam süresine ulaşarak mı bitti
  required double ulkeOmru,
  required int zaman,
  required int para,
  required int saglik,
  required int iliski,
  required int yasananUlkeSayisi,
}) async {
  final tercihler = await SharedPreferences.getInstance();
  final mevcut = (tercihler.getStringList(_anahtar) ?? <String>[]).toSet();

  final hak = <String>{'ilk_nefes'};
  if (yasananUlkeSayisi >= 5) hak.add('gezgin');
  if (dogalSon) {
    hak.add('uzun_omur');
    if (ulkeOmru < 65) hak.add('zor_baslangic');
    if (zaman > 40 && para > 40 && saglik > 40 && iliski > 40) {
      hak.add('dengeli');
    }
  }

  final yeniler = tumRozetler
      .where((r) => hak.contains(r.id) && !mevcut.contains(r.id))
      .toList();
  if (yeniler.isNotEmpty) {
    mevcut.addAll(yeniler.map((r) => r.id));
    await tercihler.setStringList(_anahtar, mevcut.toList());
  }
  return yeniler;
}