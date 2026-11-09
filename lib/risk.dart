import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'olum.dart';

// Bir ülkenin 0 (düşük) ile 1 (yüksek) arası risk skorları. Veri yoksa null.
class UlkeRiskleri {
  final Map<String, double?> skorlar;
  const UlkeRiskleri(this.skorlar);

  double? operator [](String alan) => skorlar[alan];
}

Map<String, UlkeRiskleri>? _onbellek;

// assets/riskler.json dosyasını okur. Dosya yoksa ya da bozuksa boş harita
// döner; bu durumda genel zorluk (yaşam süresinden) kullanılır.
Future<Map<String, UlkeRiskleri>> riskleriYukle() async {
  final onbellek = _onbellek;
  if (onbellek != null) return onbellek;
  try {
    final metin = await rootBundle.loadString('assets/riskler.json');
    final liste = jsonDecode(metin) as List<dynamic>;
    final harita = <String, UlkeRiskleri>{};
    for (final e in liste) {
      final m = e as Map<String, dynamic>;
      final skorlar = <String, double?>{};
      m.forEach((alan, v) {
        if (alan != 'kod') skorlar[alan] = (v as num?)?.toDouble();
      });
      harita[m['kod'] as String] = UlkeRiskleri(skorlar);
    }
    _onbellek = harita;
    return harita;
  } catch (_) {
    _onbellek = <String, UlkeRiskleri>{};
    return _onbellek!;
  }
}

enum OlumNedeni {
  yaslilik,
  enfeksiyon,
  kronik,
  trafik,
  siddet,
  catisma,
  beslenme,
  dogum,
}

// Ülkenin genel zorluğu: yaşam süresinden (0 kolay, 1 zor)
double genelZorluk(double omur) =>
    ((85 - omur) / 35).clamp(0.0, 1.0).toDouble();

// Bir olay kartının risk skoru. Veri yoksa null döner ve olay hiç çıkmaz.
// Çatışma için veri yoksa risk 0 sayılır (yalnızca olay olan ülkelerde raporlanır).
double? olayRiski(String alan, UlkeRiskleri? r) {
  final v = r?[alan];
  if (v != null) return v;
  return alan == 'catisma' ? 0.0 : null;
}

// Her nedenin ağırlığı: yaşa ve ülkenin risk skorlarına göre
Map<OlumNedeni, double> nedenAgirliklari(
  int yas,
  double omur,
  UlkeRiskleri? r,
) {
  final z = genelZorluk(omur);
  double s(String alan) => r?[alan] ?? z;
  // Çatışma verisi yoksa risk yok sayılır (yalnızca olay olan ülkelerde raporlanır)
  final catisma = r?['catisma'] ?? 0.0;

  final enfeksiyon = (s('sitma') + s('verem') + s('su') + s('aclik')) / 4;
  final beslenme = (s('aclik') + s('su')) / 2;

  if (yas < 5) {
    return {
      OlumNedeni.dogum: 1.5,
      OlumNedeni.enfeksiyon: 1.0 + 3.0 * enfeksiyon,
      OlumNedeni.beslenme: 0.5 + 3.0 * beslenme,
      OlumNedeni.catisma: 0.4 * catisma * catisma,
    };
  }

  final genc = (yas >= 15 && yas <= 40) ? 1.5 : 1.0;
  final orta = yas > 30 ? 0.02 * (yas - 30) : 0.0;
  return {
    OlumNedeni.enfeksiyon: 0.2 + 1.6 * enfeksiyon,
    OlumNedeni.kronik: 0.6 + orta,
    OlumNedeni.trafik: (0.2 + 1.0 * s('trafik')) * genc,
    OlumNedeni.siddet: (0.05 + 1.2 * s('siddet') * s('siddet')) * genc,
    OlumNedeni.catisma: 2.0 * catisma * catisma,
    OlumNedeni.beslenme: 0.1 + 1.4 * beslenme,
  };
}

// Önce ölümün yaşlanmaya bağlı olup olmadığını, değilse hangi dış nedenle
// olduğunu seçer.
OlumNedeni olumNedeniSec(int yas, double omur, UlkeRiskleri? r, Random rnd) {
  if (rnd.nextDouble() < yaslanmaPayi(yas, omur)) return OlumNedeni.yaslilik;
  final a = nedenAgirliklari(yas, omur, r);
  final toplam = a.values.fold<double>(0, (t, v) => t + v);
  var x = rnd.nextDouble() * toplam;
  for (final e in a.entries) {
    x -= e.value;
    if (x <= 0) return e.key;
  }
  return a.keys.last;
}