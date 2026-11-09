import 'package:shared_preferences/shared_preferences.dart';

const _denenenAnahtar = 'atlas_denenen';
const _tamamAnahtar = 'atlas_tamamlanan';

// Atlasın durumu: denenen (doğulup tamamlanamayan) ve tamamlanan
// (beklenen yaşa ulaşılan) ülkeler
class AtlasDurumu {
  final Set<String> denenen;
  final Set<String> tamamlanan;
  const AtlasDurumu(this.denenen, this.tamamlanan);

  bool tamamMi(String kod) => tamamlanan.contains(kod);
  bool denendiMi(String kod) =>
      denenen.contains(kod) || tamamlanan.contains(kod);
  int get tamamSayisi => tamamlanan.length;
  int get yasananSayisi => {...denenen, ...tamamlanan}.length;
}

Future<AtlasDurumu> atlasOku() async {
  final t = await SharedPreferences.getInstance();
  return AtlasDurumu(
    (t.getStringList(_denenenAnahtar) ?? <String>[]).toSet(),
    (t.getStringList(_tamamAnahtar) ?? <String>[]).toSet(),
  );
}

// Bir hayat bitince ülkeyi işler. tamamlandi: beklenen yaşa ulaşıldı mı
Future<void> ulkeyiIsaretle(String kod, {required bool tamamlandi}) async {
  final t = await SharedPreferences.getInstance();
  final denenen = (t.getStringList(_denenenAnahtar) ?? <String>[]).toSet();
  final tamam = (t.getStringList(_tamamAnahtar) ?? <String>[]).toSet();
  if (tamamlandi) {
    tamam.add(kod);
    denenen.remove(kod);
  } else if (!tamam.contains(kod)) {
    denenen.add(kod);
  }
  await t.setStringList(_denenenAnahtar, denenen.toList());
  await t.setStringList(_tamamAnahtar, tamam.toList());
}

// Hayat yaşanan (denenen ya da tamamlanan) farklı ülke sayısı
Future<int> yasananUlkeSayisi() async => (await atlasOku()).yasananSayisi;