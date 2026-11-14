import 'dart:math';

// Hayat hedefi: doğumda rastgele seçilir. Oyuncu kartlarla ona yaklaşır.
// etiketler: hedefe götüren seçimlerin bıraktığı etiketler. Bu etiketleri
// veren kartlar, hedef varken daha sık çıkar (kart_secici.dart).
// Ad ve açıklama çeviri dosyalarında hedef_<id>_ad ve hedef_<id>_acik.
class Hedef {
  final String id;
  final Set<String> etiketler;
  final int enAzIliski; // hayat sonunda ilişki ölçüsü en az bu olmalı
  final int enAzSaglik; // hayat sonunda sağlık ölçüsü en az bu olmalı
  final int enAzPara; // hayat sonunda para ölçüsü en az bu olmalı
  final bool omurGerek; // ülkenin beklenen yaşına ulaşmak da gerekir mi
  const Hedef(
    this.id,
    this.etiketler, {
    this.enAzIliski = 0,
    this.enAzSaglik = 0,
    this.enAzPara = 0,
    this.omurGerek = false,
  });

  // Hayat bittiğinde hedef başarıldı mı
  bool basarildiMi({
    required Set<String> hayatEtiketleri,
    required int saglik,
    required int para,
    required int iliski,
    required bool tamamlandi,
  }) {
    if (!etiketler.any(hayatEtiketleri.contains)) return false;
    if (iliski < enAzIliski || saglik < enAzSaglik || para < enAzPara) {
      return false;
    }
    if (omurGerek && !tamamlandi) return false;
    return true;
  }
}

const tumHedefler = [
  Hedef('girisim', {'girisimci', 'yatirimci'}),
  Hedef('aile', {'ailevi'}, enAzIliski: 50),
  Hedef('gezgin', {'gezgin'}),
  Hedef('saglik', {'sporcu', 'bakimli'}, enAzSaglik: 50, omurGerek: true),
  Hedef('bilgi', {'okur', 'burslu'}),
  Hedef('iyilik', {'yardimsever', 'gonullu'}, enAzIliski: 40),
  Hedef('sanat', {'sanatci', 'hobi'}),
  Hedef('sevilen', {'sosyal', 'lider', 'kaptan'}, enAzIliski: 60),
  Hedef('birikim', {'tutumlu', 'yatirimci', 'ev_sahibi'}, enAzPara: 55),
];

Hedef hedefSec(Random r) => tumHedefler[r.nextInt(tumHedefler.length)];
