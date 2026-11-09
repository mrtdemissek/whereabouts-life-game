import 'karar.dart';

// Ülkenin risk skoruna bağlı olay kartı. riskAlan alanındaki skor riskEsik
// değerine ulaşan ülkelerde çıkabilir; skor yükseldikçe daha sık çıkar.
// Metinler genel tutulur, hiçbir ülke ya da hükümet adı geçmez.
class OlayKarti extends Karar {
  final String riskAlan;
  final double riskEsik;
  const OlayKarti({
    required super.id,
    required this.riskAlan,
    required super.sol,
    required super.sag,
    super.minYas,
    super.maxYas,
    this.riskEsik = 0.5,
  }) : super(tekSeferlik: true);
}

const olayKartlari = [
  // Su
  OlayKarti(
    id: 'e01',
    riskAlan: 'su',
    sol: Etki(zaman: -10, saglik: -2, iliski: 3),
    sag: Etki(saglik: -9, zaman: 3),
    minYas: 5,
    maxYas: 65,
  ),
  // Sıtma
  OlayKarti(
    id: 'e02',
    riskAlan: 'sitma',
    sol: Etki(para: -6, saglik: 4),
    sag: Etki(saglik: -11),
    minYas: 5,
    maxYas: 60,
  ),
  // Verem
  OlayKarti(
    id: 'e03',
    riskAlan: 'verem',
    sol: Etki(para: -5, zaman: -4, saglik: 6),
    sag: Etki(saglik: -13),
    minYas: 15,
    maxYas: 70,
  ),
  // Açlık
  OlayKarti(
    id: 'e04',
    riskAlan: 'aclik',
    sol: Etki(saglik: -8, para: 3),
    sag: Etki(para: -10, saglik: 2),
    minYas: 5,
    maxYas: 70,
  ),
  // Enflasyon
  OlayKarti(
    id: 'e05',
    riskAlan: 'enflasyon',
    sol: Etki(zaman: -10, para: 8, saglik: -3),
    sag: Etki(para: -2, iliski: -5, saglik: -2),
    minYas: 19,
    maxYas: 70,
  ),
  // İşsizlik
  OlayKarti(
    id: 'e06',
    riskAlan: 'issizlik',
    sol: Etki(zaman: -8, para: -5, iliski: 2),
    sag: Etki(para: -8, zaman: -10, saglik: -2),
    minYas: 19,
    maxYas: 60,
  ),
  // Yoksulluk
  OlayKarti(
    id: 'e07',
    riskAlan: 'yoksulluk',
    sol: Etki(para: 10, zaman: -8, iliski: -3),
    sag: Etki(para: 6, iliski: -4),
    minYas: 13,
    maxYas: 25,
  ),
  // Şiddet
  OlayKarti(
    id: 'e08',
    riskAlan: 'siddet',
    sol: Etki(zaman: -3, saglik: 1),
    sag: Etki(saglik: -10, iliski: 6),
    minYas: 15,
    maxYas: 60,
  ),
  // Çatışma
  OlayKarti(
    id: 'e09',
    riskAlan: 'catisma',
    sol: Etki(para: -10, iliski: -8, zaman: -6, saglik: 3),
    sag: Etki(saglik: -12, iliski: 3),
    minYas: 5,
    maxYas: 70,
  ),
  OlayKarti(
    id: 'e10',
    riskAlan: 'catisma',
    sol: Etki(zaman: -6, para: -3),
    sag: Etki(zaman: -6, iliski: 8, saglik: -4),
    minYas: 5,
    maxYas: 30,
  ),
  // Siyasi baskı (algı göstergesinden türeyen genel olaylar)
  OlayKarti(
    id: 'e11',
    riskAlan: 'siyasi_baski',
    sol: Etki(para: -12, zaman: -6, iliski: 2),
    sag: Etki(iliski: -8, zaman: 2),
    minYas: 19,
    maxYas: 70,
  ),
  OlayKarti(
    id: 'e12',
    riskAlan: 'siyasi_baski',
    sol: Etki(iliski: 4, saglik: -6, para: -4),
    sag: Etki(saglik: 2, iliski: -6),
    minYas: 16,
    maxYas: 60,
  ),
  // İstikrarsızlık
  OlayKarti(
    id: 'e13',
    riskAlan: 'istikrarsizlik',
    sol: Etki(iliski: 4, zaman: -5, para: -3),
    sag: Etki(saglik: -4, zaman: 2),
    minYas: 10,
    maxYas: 70,
  ),
  // Trafik
  OlayKarti(
    id: 'e14',
    riskAlan: 'trafik',
    sol: Etki(zaman: -6, saglik: 3),
    sag: Etki(saglik: -6, zaman: 3),
    minYas: 10,
    maxYas: 70,
  ),
];