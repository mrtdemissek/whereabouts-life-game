import 'dart:math';
import 'karar.dart';

enum OlayTuru { iyi, zor, sakin }

// Bebeklik ve erken çocukluktaki aile hikâyesi. Oyuncu karar vermez.
// Metin çeviri dosyalarında aile_<id> anahtarıyla durur.
class AileOlayi {
  final String id;
  final OlayTuru tur;
  final Etki etki;
  final int minYas;
  final int maxYas;
  const AileOlayi({
    required this.id,
    required this.tur,
    this.etki = const Etki(),
    this.minYas = 0,
    this.maxYas = 4,
  });
}

const aileOlaylari = [
  // Sıcak anlar
  AileOlayi(
    id: 'i01',
    tur: OlayTuru.iyi,
    etki: Etki(iliski: 8, saglik: 2),
    minYas: 0,
    maxYas: 2,
  ),
  AileOlayi(
    id: 'i02',
    tur: OlayTuru.iyi,
    etki: Etki(saglik: 8, para: -2),
    minYas: 0,
    maxYas: 3,
  ),
  AileOlayi(
    id: 'i03',
    tur: OlayTuru.iyi,
    etki: Etki(iliski: 8, saglik: 3),
    minYas: 1,
    maxYas: 3,
  ),
  AileOlayi(
    id: 'i04',
    tur: OlayTuru.iyi,
    etki: Etki(iliski: 6, zaman: 2),
    minYas: 2,
    maxYas: 4,
  ),
  AileOlayi(
    id: 'i05',
    tur: OlayTuru.iyi,
    etki: Etki(iliski: 5),
    minYas: 1,
    maxYas: 3,
  ),
  AileOlayi(
    id: 'i06',
    tur: OlayTuru.iyi,
    etki: Etki(saglik: 5, iliski: 4),
    minYas: 3,
    maxYas: 4,
  ),
  AileOlayi(
    id: 'i07',
    tur: OlayTuru.iyi,
    etki: Etki(iliski: 4, para: -1),
    minYas: 2,
    maxYas: 4,
  ),
  // Zorluklar
  AileOlayi(
    id: 'z01',
    tur: OlayTuru.zor,
    etki: Etki(saglik: -8, para: -5),
  ),
  AileOlayi(
    id: 'z02',
    tur: OlayTuru.zor,
    etki: Etki(saglik: -6, para: -6, iliski: 3),
  ),
  AileOlayi(
    id: 'z03',
    tur: OlayTuru.zor,
    etki: Etki(zaman: -6, saglik: -4),
    minYas: 1,
  ),
  AileOlayi(
    id: 'z04',
    tur: OlayTuru.zor,
    etki: Etki(iliski: -8, para: 6),
  ),
  AileOlayi(
    id: 'z05',
    tur: OlayTuru.zor,
    etki: Etki(iliski: -3, saglik: -2),
  ),
  AileOlayi(
    id: 'z06',
    tur: OlayTuru.zor,
    etki: Etki(saglik: -6),
  ),
  AileOlayi(
    id: 'z07',
    tur: OlayTuru.zor,
    etki: Etki(para: -8, iliski: -3),
    minYas: 2,
  ),
  // Sakin yıl
  AileOlayi(id: 's01', tur: OlayTuru.sakin),
];

// 0 (zorluk yok) ile 1 (en zor) arasında bir ölçü; yalnızca yaşam süresinden
double _zorluk(double omur) => ((85 - omur) / 35).clamp(0.0, 1.0).toDouble();

double _agirlik(AileOlayi o, double z) {
  return switch (o.tur) {
    OlayTuru.iyi => 1.0 - 0.3 * z,
    OlayTuru.zor => 2.0 * z + 0.05,
    OlayTuru.sakin => 1.5,
  };
}

// Yaşa uygun, bu hayatta henüz çıkmamış bir hikâyeyi ağırlıklı rastgele seçer.
// Yaşam süresi düşük ülkelerde zorluk hikâyeleri daha sık çıkar.
AileOlayi aileOlayiSec(
  int yas,
  double omur,
  Set<String> kullanilan,
  Random r,
) {
  final yasaUygun =
      aileOlaylari.where((o) => yas >= o.minYas && yas <= o.maxYas).toList();
  var liste = yasaUygun.where((o) => !kullanilan.contains(o.id)).toList();
  if (liste.isEmpty) liste = yasaUygun;

  final z = _zorluk(omur);
  final toplam = liste.fold<double>(0, (t, o) => t + _agirlik(o, z));
  var x = r.nextDouble() * toplam;
  for (final o in liste) {
    x -= _agirlik(o, z);
    if (x <= 0) return o;
  }
  return liste.last;
}