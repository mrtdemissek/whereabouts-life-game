// Hayat hedefi, yildizlar ve hedefe gore kart onceligi icin birim testleri.
// Calistirma: flutter test test/oyunlastirma_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereabouts/baglam_kartlari.dart';
import 'package:whereabouts/diller/en_oyun.dart';
import 'package:whereabouts/diller/tr_oyun.dart';
import 'package:whereabouts/hedef.dart';
import 'package:whereabouts/karar.dart';
import 'package:whereabouts/kart_secici.dart';
import 'package:whereabouts/kartlar2.dart';
import 'package:whereabouts/kartlar3.dart';
import 'package:whereabouts/tohumlu.dart';
import 'package:whereabouts/yildiz.dart';
import 'package:whereabouts/zincir.dart';

const _aile = Hedef('aile', {'ailevi'}, enAzIliski: 50);
const _saglik =
    Hedef('saglik', {'sporcu', 'bakimli'}, enAzSaglik: 50, omurGerek: true);

bool _basari(
  Hedef h,
  Set<String> e, {
  int saglik = 50,
  int para = 50,
  int iliski = 50,
  bool tamamlandi = true,
}) =>
    h.basarildiMi(
      hayatEtiketleri: e,
      saglik: saglik,
      para: para,
      iliski: iliski,
      tamamlandi: tamamlandi,
    );

void main() {
  group('Hedef.basarildiMi', () {
    test('hedef etiketi yoksa basarisiz', () {
      expect(_basari(_aile, {'sosyal'}), isFalse);
    });

    test('etiket var ve esik saglaniyorsa basarili', () {
      expect(_basari(_aile, {'ailevi', 'kent'}, iliski: 50), isTrue);
    });

    test('etiket var ama olcu esigin altindaysa basarisiz', () {
      expect(_basari(_aile, {'ailevi'}, iliski: 49), isFalse);
    });

    test('omur gereken hedef, beklenen yasa ulasilmadan basarilmaz', () {
      expect(_basari(_saglik, {'sporcu'}, tamamlandi: false), isFalse);
      expect(_basari(_saglik, {'sporcu'}, tamamlandi: true), isTrue);
    });
  });

  group('Hedef listesi', () {
    final tumKartlar = <Karar>[
      ...kararlar,
      ...yeniKararlar,
      ...kartlar3,
      ...baglamKararlari,
      ...zincirKartlari,
    ];
    final uretilen = <String>{
      for (final k in tumKartlar) ...k.solEtiket,
      for (final k in tumKartlar) ...k.sagEtiket,
    };

    test('her hedefe en az bir kartla ulasilabilir', () {
      for (final h in tumHedefler) {
        expect(
          h.etiketler.any(uretilen.contains),
          isTrue,
          reason: '${h.id} hedefinin etiketlerini veren kart yok',
        );
      }
    });

    test('her hedefin TR ve EN metinleri var', () {
      for (final h in tumHedefler) {
        for (final a in ['ad', 'acik']) {
          expect(trOyun['hedef_${h.id}_$a'], isNotNull, reason: 'TR ${h.id}_$a');
          expect(enOyun['hedef_${h.id}_$a'], isNotNull, reason: 'EN ${h.id}_$a');
        }
      }
    });

    test('hedef kimlikleri benzersiz', () {
      final idler = tumHedefler.map((h) => h.id).toList();
      expect(idler.toSet().length, idler.length);
    });
  });

  group('HayatYildizi', () {
    test('yildiz sayisi kosullarin toplamidir', () {
      expect(
        const HayatYildizi(omur: false, hedef: false, denge: false).sayi,
        0,
      );
      expect(const HayatYildizi(omur: true, hedef: false, denge: true).sayi, 2);
      expect(const HayatYildizi(omur: true, hedef: true, denge: true).sayi, 3);
    });
  });

  group('yildizKaydet', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('ilk kayitta onceki en iyi 0 doner ve kaydeder', () async {
      expect(await yildizKaydet('TR', 2), 0);
      expect((await enIyiYildizlariOku())['TR'], 2);
    });

    test('daha dusuk sonuc rekoru dusurmez', () async {
      await yildizKaydet('TR', 3);
      expect(await yildizKaydet('TR', 1), 3);
      expect((await enIyiYildizlariOku())['TR'], 3);
    });

    test('toplam yildiz ulkelerin en iyilerinin toplamidir', () async {
      await yildizKaydet('TR', 2);
      await yildizKaydet('JP', 3);
      await yildizKaydet('TR', 1);
      expect(await toplamYildiz(), 5);
    });
  });

  group('Hedefe gore kart onceligi', () {
    int hedefKartSayisi(Set<String> oncelik) {
      final r = Tohumlu(2026);
      var n = 0;
      for (var i = 0; i < 2000; i++) {
        final k = yeniKartSec(30, const [], {'orta', 'kent'},
            rnd: r, oncelik: oncelik);
        if (k.solEtiket.contains('ailevi') || k.sagEtiket.contains('ailevi')) {
          n++;
        }
      }
      return n;
    }

    test('hedef etiketini veren kartlar daha sik cikar', () {
      final normal = hedefKartSayisi(const {});
      final oncelikli = hedefKartSayisi(const {'ailevi'});
      expect(oncelikli, greaterThan(normal));
    });
  });
}
