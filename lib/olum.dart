import 'dart:math';

// TEST için: tüm ölüm risklerini bu sayıyla çarpar. Normal oyunda 1.0 olmalı.
const double riskOlcegi = 1.0;

const double _g = 0.085; // yaşlanma riskinin artış hızı

// 5 yaşından önceki ölümlerin yaşlara dağılımı (0, 1, 2, 3, 4 yaş)
const List<double> _erkenDagilim = [0.55, 0.20, 0.12, 0.08, 0.05];

// Yaşam süresi 50, 55, ..., 85 için kalibre edilmiş ln(A) değerleri.
// Dengeli bir oyuncuda ortalama ölüm yaşı ülkenin yaşam süresine yakın çıkar.
const List<double> _lnA = [
  -8.562,
  -8.754,
  -8.948,
  -9.158,
  -9.395,
  -9.672,
  -10.003,
  -10.405,
];

double _lnAHesapla(double omur) {
  final x = ((omur - 50) / 5).clamp(0.0, 7.0).toDouble();
  final i = x.floor();
  if (i >= 7) return _lnA[7];
  final t = x - i;
  return _lnA[i] * (1 - t) + _lnA[i + 1] * t;
}

// Yaşam süresi 85'ten uzaklaştıkça artan bir ölçü (85 ve üstünde 0)
double _uzaklik(double omur) {
  final d = (85 - omur).clamp(0.0, 100.0).toDouble() / 35.0;
  return d * d;
}

// 5 yaşına gelmeden ölme olasılığı
double _besYasOlumu(double omur) => 0.0025 + 0.11 * _uzaklik(omur);

// Her yaşta bulunan arka plan riski (kaza, enfeksiyon, şiddet gibi)
double _arkaPlan(double omur) => 0.0005 + 0.005 * _uzaklik(omur);

// Sağlık ölçüsünün risk çarpanı: 50'de 1, 100'de yaklaşık 0.5, 0'da yaklaşık 2
double saglikCarpani(int saglik) => exp(-(saglik - 50) / 50 * 0.7);

// Belirli bir yaştaki yıllık ölüm olasılığı
double yillikRisk(int yas, double omur, int saglik) {
  double h;
  if (yas < 5) {
    h = _besYasOlumu(omur) * _erkenDagilim[yas];
  } else {
    final yaslanma = exp(_lnAHesapla(omur)) * exp(_g * yas);
    h = (_arkaPlan(omur) + yaslanma) * saglikCarpani(saglik);
  }
  return min(h * riskOlcegi, 1.0);
}

// Bir ölümün yaşlanmaya bağlı olma payı (0 ile 1 arası): yaşlanma riskinin
// toplam risk içindeki oranı. 5 yaşından küçüklerde 0.
double yaslanmaPayi(int yas, double omur) {
  if (yas < 5) return 0.0;
  final yaslanma = exp(_lnAHesapla(omur)) * exp(_g * yas);
  final toplam = _arkaPlan(omur) + yaslanma;
  return toplam <= 0 ? 0.0 : yaslanma / toplam;
}

// Bir yaş için 0 ile 1 arasında bir zar değeri döndüren fonksiyon.
// Normal hayatta her çağrıda rastgele; günlük meydan okumada yaşa göre sabittir.
typedef Zar = double Function(int yas);

// yas yaşından başlayan adim yıl içinde ölüm olur mu? Olursa ölüm yaşını,
// olmazsa null döndürür. Zar değeri ölüm olasılığından küçükse ölünür.
int? olumYasi(int yas, int adim, double omur, int saglik, Zar zar) {
  for (var i = 0; i < adim; i++) {
    final y = yas + i;
    if (zar(y) < yillikRisk(y, omur, saglik)) return y;
  }
  return null;
}