import 'package:shared_preferences/shared_preferences.dart';

// Bir hayatın yıldızları (0-3):
//   1. Ülkenin beklenen yaşına ulaşmak
//   2. Hayat hedefini başarmak
//   3. Dengeli bir son: 30 yaşını geçip dört ölçüyü de 40 üzerinde tutmak
class HayatYildizi {
  final bool omur;
  final bool hedef;
  final bool denge;
  const HayatYildizi({
    required this.omur,
    required this.hedef,
    required this.denge,
  });

  int get sayi => (omur ? 1 : 0) + (hedef ? 1 : 0) + (denge ? 1 : 0);
}

const _anahtar = 'ulke_en_iyi_yildiz'; // "TR:2" biçiminde liste

Future<Map<String, int>> enIyiYildizlariOku() async {
  final t = await SharedPreferences.getInstance();
  final m = <String, int>{};
  for (final s in t.getStringList(_anahtar) ?? <String>[]) {
    final p = s.split(':');
    if (p.length == 2) m[p[0]] = int.tryParse(p[1]) ?? 0;
  }
  return m;
}

// Toplam yıldız: her ülkenin en iyi sonucu toplanır (en fazla 3 x ülke)
Future<int> toplamYildiz() async =>
    (await enIyiYildizlariOku()).values.fold<int>(0, (a, b) => a + b);

// Ülkenin en iyi sonucunu günceller. Dönüş: önceki en iyi sonuç.
Future<int> yildizKaydet(String ulkeKod, int yildiz) async {
  final m = await enIyiYildizlariOku();
  final onceki = m[ulkeKod] ?? 0;
  if (yildiz > onceki) {
    m[ulkeKod] = yildiz;
    final t = await SharedPreferences.getInstance();
    await t.setStringList(
      _anahtar,
      [for (final e in m.entries) '${e.key}:${e.value}'],
    );
  }
  return onceki;
}
