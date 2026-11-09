import 'tohumlu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ulke.dart';

const _sonGunAnahtar = 'gunluk_son_tamamlanan';
const _seriAnahtar = 'gunluk_seri';

String _gunAnahtari(DateTime d) {
  final ay = d.month.toString().padLeft(2, '0');
  final gun = d.day.toString().padLeft(2, '0');
  return '${d.year}-$ay-$gun';
}

// Aynı gün herkes için aynı ülkeyi seçer. Liste ülke koduna göre
// sıralanır, böylece dil değişse de günün ülkesi aynı kalır.
Ulke gununUlkesi(List<Ulke> ulkeler) {
  final d = DateTime.now();
  final tohum = d.year * 10000 + d.month * 100 + d.day;
  final sirali = [...ulkeler]..sort((a, b) => a.kod.compareTo(b.kod));
  return sirali[Tohumlu(tohum).nextInt(sirali.length)];
}

// Günün meydan okuması için ortak tohum: aynı gün ve aynı ülke için herkeste
// aynıdır. Zarlar, kartlar ve karakterin görünümü bundan türetilir.
int gunlukTohum(String ulkeKodu) {
  final d = DateTime.now();
  final gun = d.year * 10000 + d.month * 100 + d.day;
  var h = 17;
  for (final c in ulkeKodu.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return gun * 1000003 + h;
}

class GunlukDurum {
  final bool bugunTamam;
  final int seri;
  const GunlukDurum({required this.bugunTamam, required this.seri});
}

// Bugün tamamlandı mı ve seri kaç gün
Future<GunlukDurum> gunlukDurumOku() async {
  final t = await SharedPreferences.getInstance();
  final son = t.getString(_sonGunAnahtar);
  final seri = t.getInt(_seriAnahtar) ?? 0;
  final simdi = DateTime.now();
  final bugun = _gunAnahtari(simdi);
  final dun = _gunAnahtari(DateTime(simdi.year, simdi.month, simdi.day - 1));
  if (son == bugun) return GunlukDurum(bugunTamam: true, seri: seri);
  if (son == dun) return GunlukDurum(bugunTamam: false, seri: seri);
  return const GunlukDurum(bugunTamam: false, seri: 0);
}

// Günün meydan okuması tamamlandı: seriyi günceller, yeni seriyi döndürür
Future<int> gunlukTamamla() async {
  final t = await SharedPreferences.getInstance();
  final simdi = DateTime.now();
  final bugun = _gunAnahtari(simdi);
  final dun = _gunAnahtari(DateTime(simdi.year, simdi.month, simdi.day - 1));
  final son = t.getString(_sonGunAnahtar);
  var seri = t.getInt(_seriAnahtar) ?? 0;
  if (son == bugun) return seri;
  seri = (son == dun) ? seri + 1 : 1;
  await t.setString(_sonGunAnahtar, bugun);
  await t.setInt(_seriAnahtar, seri);
  return seri;
}