// Animasyon ayarı için birim testleri.
// Çalıştırma: flutter test test/hareket_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whereabouts/diller/en_oyun.dart';
import 'package:whereabouts/diller/tr_oyun.dart';
import 'package:whereabouts/hareket.dart';

void main() {
  test('Telefona göre: telefonun ayarını aynen izler', () {
    expect(hareketAzaltilsinMi(HareketModu.sistem, true), isTrue);
    expect(hareketAzaltilsinMi(HareketModu.sistem, false), isFalse);
  });

  test('Tam: telefonda Hareketi Azalt açık olsa da animasyon oynar', () {
    expect(hareketAzaltilsinMi(HareketModu.tam, true), isFalse);
    expect(hareketAzaltilsinMi(HareketModu.tam, false), isFalse);
  });

  test('Azaltılmış: telefon ayarı kapalı olsa da hareket azalır', () {
    expect(hareketAzaltilsinMi(HareketModu.azaltilmis, true), isTrue);
    expect(hareketAzaltilsinMi(HareketModu.azaltilmis, false), isTrue);
  });

  test('her mod için iki dilde de etiket var', () {
    for (final m in HareketModu.values) {
      expect(trOyun.containsKey('hareket_${m.name}'), isTrue, reason: m.name);
      expect(enOyun.containsKey('hareket_${m.name}'), isTrue, reason: m.name);
    }
    for (final k in ['hareket_baslik', 'hareket_aciklama']) {
      expect(trOyun.containsKey(k) && enOyun.containsKey(k), isTrue, reason: k);
    }
  });
}
