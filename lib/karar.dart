// Bir kararın dört ölçüye etkisi
class Etki {
  final int zaman;
  final int para;
  final int saglik;
  final int iliski;
  const Etki({this.zaman = 0, this.para = 0, this.saglik = 0, this.iliski = 0});
}

// Bir karar kartı (minYas ve maxYas arasında çıkar).
// Metinler çeviri dosyalarında <id>_metin, <id>_sol, <id>_sag ve
// seçimin sonucu için <id>_sol_son, <id>_sag_son anahtarlarıyla durur.
class Karar {
  final String id;
  final Etki sol;
  final Etki sag;
  final int minYas;
  final int maxYas;
  final Set<String> solEtiket; // sol seçilince hayata eklenen etiketler
  final Set<String> sagEtiket; // sağ seçilince hayata eklenen etiketler
  final Set<String> gerek; // bu etiketlerin hepsi varsa çıkabilir
  final Set<String> yasak; // bu etiketlerden biri varsa çıkmaz
  final double agirlik; // seçilme ağırlığı
  final bool tekSeferlik; // bir hayatta en fazla bir kez çıkar
  const Karar({
    required this.id,
    required this.sol,
    required this.sag,
    this.minYas = 0,
    this.maxYas = 120,
    this.solEtiket = const {},
    this.sagEtiket = const {},
    this.gerek = const {},
    this.yasak = const {},
    this.agirlik = 1.0,
    this.tekSeferlik = false,
  });
}

const kararlar = [
  // ---- Çocukluk (5-12) ----
  Karar(
    id: 'k01',
    sol: Etki(zaman: -5, para: 5),
    sag: Etki(zaman: -5, saglik: 10, iliski: 10),
    solEtiket: {'calisgan'},
    sagEtiket: {'sosyal'},
    minYas: 5,
    maxYas: 12,
  ),
  Karar(
    id: 'k02',
    sol: Etki(zaman: -5, iliski: 10),
    sag: Etki(zaman: 5, iliski: -10),
    solEtiket: {'yardimsever'},
    minYas: 5,
    maxYas: 12,
  ),
  Karar(
    id: 'k03',
    sol: Etki(zaman: -5, iliski: 15),
    sag: Etki(zaman: 5, iliski: -5),
    solEtiket: {'yardimsever', 'sosyal'},
    minYas: 5,
    maxYas: 12,
  ),
  Karar(
    id: 'k04',
    sol: Etki(para: 10, iliski: -5),
    sag: Etki(para: -10, iliski: 5),
    solEtiket: {'tutumlu'},
    sagEtiket: {'harcayan'},
    minYas: 5,
    maxYas: 12,
  ),
  Karar(
    id: 'k05',
    sol: Etki(zaman: -5, para: 5),
    sag: Etki(zaman: 5, saglik: -5),
    solEtiket: {'okur'},
    minYas: 5,
    maxYas: 12,
  ),
  Karar(
    id: 'k06',
    sol: Etki(zaman: -5, saglik: 10),
    sag: Etki(zaman: 5, saglik: -5, iliski: 5),
    solEtiket: {'sporcu'},
    minYas: 5,
    maxYas: 12,
  ),
  // ---- Ergenlik (13-18) ----
  Karar(
    id: 'k07',
    sol: Etki(zaman: -10, para: 10, iliski: -10),
    sag: Etki(zaman: -5, para: -10, iliski: 15),
    solEtiket: {'calisgan', 'okur'},
    sagEtiket: {'sosyal'},
    minYas: 13,
    maxYas: 18,
  ),
  Karar(
    id: 'k08',
    sol: Etki(zaman: -10, iliski: 15),
    sag: Etki(zaman: 10, iliski: -5),
    solEtiket: {'sosyal'},
    minYas: 13,
    maxYas: 18,
  ),
  Karar(
    id: 'k09',
    sol: Etki(zaman: -10, para: 15, saglik: -5),
    sag: Etki(zaman: 10, para: -15, iliski: 10),
    solEtiket: {'calisgan'},
    minYas: 13,
    maxYas: 18,
  ),
  Karar(
    id: 'k10',
    sol: Etki(zaman: -10, iliski: 15),
    sag: Etki(zaman: 5, iliski: -10),
    solEtiket: {'yardimsever'},
    minYas: 13,
    maxYas: 18,
  ),
  Karar(
    id: 'k11',
    sol: Etki(iliski: 5, saglik: -10),
    sag: Etki(saglik: 10, iliski: -5),
    minYas: 13,
    maxYas: 18,
  ),
  Karar(
    id: 'k12',
    sol: Etki(zaman: -10, saglik: 10, iliski: 5),
    sag: Etki(zaman: 10, saglik: -5),
    solEtiket: {'sporcu', 'sosyal'},
    minYas: 13,
    maxYas: 18,
  ),
  // ---- Genç yetişkin (19-30) ----
  Karar(
    id: 'k13',
    sol: Etki(zaman: -10, para: 20, iliski: -15),
    sag: Etki(zaman: 5, para: -5, iliski: 10),
    solEtiket: {'cesur'},
    minYas: 19,
    maxYas: 30,
  ),
  Karar(
    id: 'k14',
    sol: Etki(para: 15, zaman: -5),
    sag: Etki(para: -20, saglik: 10, iliski: 10),
    solEtiket: {'tutumlu'},
    sagEtiket: {'gezgin'},
    minYas: 19,
    maxYas: 60,
  ),
  Karar(
    id: 'k15',
    sol: Etki(zaman: -10, para: 10, saglik: -5),
    sag: Etki(zaman: 10, para: -5),
    solEtiket: {'okur', 'calisgan'},
    minYas: 19,
    maxYas: 30,
  ),
  Karar(
    id: 'k16',
    sol: Etki(zaman: -5, iliski: 15),
    sag: Etki(zaman: 5, iliski: -10),
    solEtiket: {'sosyal'},
    minYas: 19,
    maxYas: 30,
  ),
  Karar(
    id: 'k17',
    sol: Etki(zaman: -10, para: 10, iliski: -5),
    sag: Etki(zaman: 5, para: -15),
    minYas: 19,
    maxYas: 35,
  ),
  Karar(
    id: 'k18',
    sol: Etki(zaman: -15, para: 15, iliski: 5, saglik: -5),
    sag: Etki(zaman: 5, para: -5),
    solEtiket: {'cesur'},
    minYas: 22,
    maxYas: 45,
  ),
  // ---- Yetişkin (25-60) ----
  Karar(
    id: 'k19',
    sol: Etki(zaman: -15, para: 20, saglik: -10),
    sag: Etki(zaman: 10, para: -10, saglik: 5),
    solEtiket: {'calisgan'},
    minYas: 25,
    maxYas: 60,
  ),
  Karar(
    id: 'k20',
    sol: Etki(para: 10, iliski: -15),
    sag: Etki(para: -10, iliski: 15),
    solEtiket: {'calisgan'},
    sagEtiket: {'ailevi'},
    minYas: 25,
    maxYas: 60,
  ),
  Karar(
    id: 'k21',
    sol: Etki(zaman: -15, para: 20, saglik: -10),
    sag: Etki(zaman: 10, para: -5, saglik: 5),
    solEtiket: {'calisgan'},
    minYas: 28,
    maxYas: 58,
  ),
  Karar(
    id: 'k22',
    sol: Etki(zaman: -5, para: -10, iliski: 10),
    sag: Etki(zaman: 5, para: 5, iliski: -5),
    solEtiket: {'ev_sahibi'},
    minYas: 28,
    maxYas: 55,
  ),
  Karar(
    id: 'k23',
    sol: Etki(zaman: -10, saglik: 10, iliski: 5),
    sag: Etki(zaman: 5, saglik: -5),
    solEtiket: {'hobi'},
    minYas: 25,
    maxYas: 75,
  ),
  // ---- Her yaşta ----
  Karar(
    id: 'k24',
    sol: Etki(zaman: -10, para: -5, iliski: 15),
    sag: Etki(zaman: 10, iliski: -10),
    solEtiket: {'ailevi'},
  ),
  Karar(
    id: 'k25',
    sol: Etki(zaman: -5, iliski: 10),
    sag: Etki(zaman: 5, iliski: -5),
    solEtiket: {'yardimsever'},
    minYas: 19,
    maxYas: 120,
  ),
  Karar(
    id: 'k26',
    sol: Etki(zaman: -5, para: -5, saglik: 15),
    sag: Etki(zaman: 5, saglik: -10),
    solEtiket: {'bakimli'},
    sagEtiket: {'ihmalkar'},
    minYas: 31,
    maxYas: 120,
  ),
  // ---- Yaşlılık (50+) ----
  Karar(
    id: 'k27',
    sol: Etki(zaman: -5, saglik: 15),
    sag: Etki(zaman: 5, saglik: -10),
    solEtiket: {'sporcu'},
    minYas: 50,
    maxYas: 120,
  ),
  Karar(
    id: 'k28',
    sol: Etki(zaman: -10, para: 15, saglik: -10),
    sag: Etki(zaman: 15, para: -10, saglik: 5),
    solEtiket: {'calisgan'},
    minYas: 58,
    maxYas: 75,
  ),
  Karar(
    id: 'k29',
    sol: Etki(zaman: -5, para: -5, iliski: 15),
    sag: Etki(zaman: 5, iliski: -10),
    solEtiket: {'sosyal'},
    minYas: 50,
    maxYas: 120,
  ),
  Karar(
    id: 'k30',
    sol: Etki(zaman: -5, para: -5, iliski: 15),
    sag: Etki(zaman: 5, saglik: 5, iliski: -5),
    solEtiket: {'ailevi'},
    minYas: 55,
    maxYas: 120,
  ),
  Karar(
    id: 'k31',
    sol: Etki(zaman: -5, iliski: 15),
    sag: Etki(zaman: 5, iliski: -5),
    solEtiket: {'okur'},
    minYas: 60,
    maxYas: 120,
  ),
];