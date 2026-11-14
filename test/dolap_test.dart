// Kıyafet dolabı için birim testleri.
// Çalıştırma: flutter test test/dolap_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whereabouts/diller/en_oyun.dart';
import 'package:whereabouts/diller/tr_oyun.dart';
import 'package:whereabouts/dolap.dart';

void main() {
  test('her türün ilk seçeneği bedava (0 yıldız)', () {
    for (final t in KozmetikTuru.values) {
      expect(kozmetiklerTuru(t).first.esik, 0, reason: t.name);
    }
  });

  test('eşikler her türde artan sırada', () {
    for (final t in KozmetikTuru.values) {
      final esikler = kozmetiklerTuru(t).map((k) => k.esik).toList();
      final sirali = [...esikler]..sort();
      expect(esikler, sirali, reason: t.name);
    }
  });

  test('kimlikler benzersiz', () {
    final idler = tumKozmetikler.map((k) => k.id).toList();
    expect(idler.toSet().length, idler.length);
  });

  test('her seçeneğin ve türün TR/EN adı var', () {
    for (final k in tumKozmetikler) {
      expect(trOyun['kozmetik_${k.id}'], isNotNull, reason: 'TR ${k.id}');
      expect(enOyun['kozmetik_${k.id}'], isNotNull, reason: 'EN ${k.id}');
    }
    for (final t in KozmetikTuru.values) {
      expect(trOyun['dolap_${t.name}'], isNotNull);
      expect(enOyun['dolap_${t.name}'], isNotNull);
    }
  });

  test('yıldız eşiğine ulaşınca açılır', () {
    final altin = tumKozmetikler.firstWhere((k) => k.id == 'altin');
    expect(acikMi(altin, altin.esik - 1), isFalse);
    expect(acikMi(altin, altin.esik), isTrue);
  });
}
