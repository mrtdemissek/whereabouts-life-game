import 'karar.dart';

// Önceki seçimlerin etiketlerine bağlı zincir kartlar.
// Normal kartlardan daha sık çıkar, bir hayatta yalnızca bir kez.
const zincirKartlari = [
  // Spor: takım kaptanlığı
  Karar(
    id: 'c01',
    gerek: {'sporcu'},
    sol: Etki(zaman: -8, iliski: 12, saglik: 5),
    sag: Etki(zaman: 5, iliski: -4),
    solEtiket: {'kaptan'},
    minYas: 13,
    maxYas: 25,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Çalışkan ve okur: burs
  Karar(
    id: 'c02',
    gerek: {'okur', 'calisgan'},
    sol: Etki(zaman: -8, para: 20),
    sag: Etki(zaman: 5, para: -2),
    solEtiket: {'burslu'},
    minYas: 16,
    maxYas: 24,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Cesur: büyük yatırım
  Karar(
    id: 'c03',
    gerek: {'cesur'},
    sol: Etki(para: 20, zaman: -12, saglik: -6),
    sag: Etki(para: 4, zaman: 4),
    solEtiket: {'girisimci'},
    minYas: 25,
    maxYas: 50,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Yardımsever: geri dönüş
  Karar(
    id: 'c04',
    gerek: {'yardimsever'},
    sol: Etki(iliski: 12, para: 8),
    sag: Etki(iliski: 6, zaman: 3),
    minYas: 25,
    maxYas: 70,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Tutumlu: birikimi değerlendirme
  Karar(
    id: 'c05',
    gerek: {'tutumlu'},
    sol: Etki(para: 15, zaman: -5),
    sag: Etki(para: 4),
    solEtiket: {'yatirimci'},
    minYas: 30,
    maxYas: 60,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // İhmalkar: ertelenen kontrolün sonucu
  Karar(
    id: 'c06',
    gerek: {'ihmalkar'},
    sol: Etki(saglik: 10, para: -8, zaman: -5),
    sag: Etki(saglik: -18, zaman: 2),
    minYas: 35,
    maxYas: 75,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Bakımlı: erken fark edilen sorun
  Karar(
    id: 'c07',
    gerek: {'bakimli'},
    sol: Etki(saglik: 12, zaman: -4),
    sag: Etki(saglik: 4),
    minYas: 40,
    maxYas: 80,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Gezgin: eski dostun daveti
  Karar(
    id: 'c08',
    gerek: {'gezgin'},
    sol: Etki(iliski: 12, para: -8, zaman: -6),
    sag: Etki(iliski: 3),
    minYas: 25,
    maxYas: 60,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Kaptan (c01'in devamı): liderlik tecrübesi
  Karar(
    id: 'c09',
    gerek: {'kaptan'},
    sol: Etki(para: 12, iliski: 5),
    sag: Etki(iliski: 5, para: 4),
    solEtiket: {'lider'},
    minYas: 20,
    maxYas: 45,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Ev sahibi: çatı sızıntısı
  Karar(
    id: 'c10',
    gerek: {'ev_sahibi'},
    sol: Etki(para: -12, zaman: -4, saglik: 2),
    sag: Etki(para: 2, saglik: -5, iliski: -3),
    minYas: 35,
    maxYas: 70,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Hobi: atölyeye davet
  Karar(
    id: 'c11',
    gerek: {'hobi'},
    sol: Etki(iliski: 12, zaman: -8, para: 5),
    sag: Etki(zaman: 4, saglik: 2),
    minYas: 35,
    maxYas: 80,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
  // Ailevi: buluşmada ev sahipliği
  Karar(
    id: 'c12',
    gerek: {'ailevi'},
    sol: Etki(iliski: 15, para: -8, zaman: -8),
    sag: Etki(zaman: 5, iliski: -6),
    minYas: 30,
    maxYas: 75,
    agirlik: 3.0,
    tekSeferlik: true,
  ),
];