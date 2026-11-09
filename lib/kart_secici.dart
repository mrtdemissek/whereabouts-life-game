import 'dart:math';
import 'karar.dart';
import 'olaylar.dart';
import 'risk.dart';
import 'zincir.dart';

final _rastgele = Random();

// Son kaç kartın tekrar çıkmaması gerektiği
const int hatirlananKart = 5;

// TEST için: olay kartlarının sıklığını bu sayıyla çarpar. Normal oyunda 1.0.
const double olayCarpani = 1.0;

// Normal kartlar, zincir kartlar ve olay kartları birlikte
final List<Karar> _tumKartlar = [
  ...kararlar,
  ...zincirKartlari,
  ...olayKartlari,
];

// Yaşa, hayatın etiketlerine, ülkenin risk skorlarına ve geçmişe uygun,
// ağırlıklı rastgele bir kart seçer. Olay kartları yalnızca ülke için gerçek
// risk verisi varsa ve skor eşiği aşıyorsa çıkar.
// omur şimdilik kullanılmıyor; çağıranları değiştirmemek için duruyor.
Karar yeniKartSec(
  int yas,
  List<Karar> gecmis,
  Set<String> etiketler, {
  UlkeRiskleri? risk,
  double omur = 85,
}) {
  bool uygun(Karar k) {
    if (yas < k.minYas || yas > k.maxYas) return false;
    if (!k.gerek.every((e) => etiketler.contains(e))) return false;
    if (k.yasak.any((e) => etiketler.contains(e))) return false;
    if (k.tekSeferlik && gecmis.contains(k)) return false;
    if (k is OlayKarti) {
      final s = olayRiski(k.riskAlan, risk);
      if (s == null || s < k.riskEsik) return false;
    }
    return true;
  }

  // Olay kartlarının ağırlığı, risk skorunun karesiyle büyür
  double agirlik(Karar k) {
    if (k is OlayKarti) {
      final s = olayRiski(k.riskAlan, risk) ?? 0.0;
      return k.agirlik * s * s * olayCarpani;
    }
    return k.agirlik;
  }

  final yasaUygun = _tumKartlar.where(uygun).toList();
  if (yasaUygun.isEmpty) return kararlar.first;

  final son = gecmis.length > hatirlananKart
      ? gecmis.sublist(gecmis.length - hatirlananKart)
      : gecmis;

  var aday = yasaUygun.where((k) => !son.contains(k)).toList();
  if (aday.isEmpty) {
    // Hepsi yakın zamanda çıktıysa, en azından bir öncekini tekrar etme
    final sonKart = gecmis.isEmpty ? null : gecmis.last;
    aday = yasaUygun.where((k) => k != sonKart).toList();
  }
  if (aday.isEmpty) aday = yasaUygun;

  final toplam = aday.fold<double>(0, (t, k) => t + agirlik(k));
  var x = _rastgele.nextDouble() * toplam;
  for (final k in aday) {
    x -= agirlik(k);
    if (x <= 0) return k;
  }
  return aday.last;
}