// Rozet koşulları ve rozet metinleri için birim testleri.
// Çalıştırma: flutter test test/rozet_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whereabouts/diller/en.dart';
import 'package:whereabouts/diller/en_rozet.dart';
import 'package:whereabouts/diller/tr.dart';
import 'package:whereabouts/diller/tr_rozet.dart';
import 'package:whereabouts/rozet.dart';

HayatOzeti _ozet({
  bool tamamlandi = false,
  double ulkeOmru = 75,
  int olumYas = 50,
  int zaman = 50,
  int para = 50,
  int saglik = 50,
  int iliski = 50,
  Set<String> etiketler = const {'orta', 'kent'},
  String hedefId = 'aile',
  bool hedefBasarildi = false,
  int yildiz = 0,
  int toplamYildiz = 0,
  int yasananUlke = 1,
  int tamamlananUlke = 0,
  bool ulkeDahaOnceDenendi = false,
  bool gunlukTamamlandi = false,
  int gunlukSeri = 0,
  int enDusukSaglik = 50,
}) =>
    HayatOzeti(
      tamamlandi: tamamlandi,
      ulkeOmru: ulkeOmru,
      olumYas: olumYas,
      zaman: zaman,
      para: para,
      saglik: saglik,
      iliski: iliski,
      etiketler: etiketler,
      hedefId: hedefId,
      hedefBasarildi: hedefBasarildi,
      yildiz: yildiz,
      toplamYildiz: toplamYildiz,
      yasananUlke: yasananUlke,
      tamamlananUlke: tamamlananUlke,
      ulkeDahaOnceDenendi: ulkeDahaOnceDenendi,
      gunlukTamamlandi: gunlukTamamlandi,
      gunlukSeri: gunlukSeri,
      enDusukSaglik: enDusukSaglik,
    );

void main() {
  group('hakEdilenRozetler', () {
    test('ilk hayat her zaman İlk Nefes verir', () {
      expect(hakEdilenRozetler(_ozet(), {}), contains('ilk_nefes'));
    });

    test('ülke sayısı eşikleri', () {
      expect(hakEdilenRozetler(_ozet(yasananUlke: 4), {}), isNot(contains('gezgin')));
      expect(hakEdilenRozetler(_ozet(yasananUlke: 5), {}), contains('gezgin'));
      expect(hakEdilenRozetler(_ozet(yasananUlke: 15), {}), contains('kasif'));
    });

    test('beklenen yaşa ulaşmadan Uzun Ömür yok', () {
      expect(hakEdilenRozetler(_ozet(), {}), isNot(contains('uzun_omur')));
      expect(
        hakEdilenRozetler(_ozet(tamamlandi: true), {}),
        containsAll(['uzun_omur', 'sehir_omru']),
      );
    });

    test('başarılan hedef kendi rozetini ve İlk Hedef rozetini verir', () {
      final h = hakEdilenRozetler(
        _ozet(hedefId: 'gezgin', hedefBasarildi: true),
        {},
      );
      expect(h, containsAll(['ilk_hedef', 'hedef_gezgin']));
      expect(h, isNot(contains('hedef_ustasi')));
    });

    test('dokuz hedefin sonuncusu Hedef Ustası verir', () {
      final oncekiler = {
        'hedef_girisim', 'hedef_aile', 'hedef_gezgin', 'hedef_saglik',
        'hedef_bilgi', 'hedef_iyilik', 'hedef_sanat', 'hedef_sevilen',
      };
      final h = hakEdilenRozetler(
        _ozet(hedefId: 'birikim', hedefBasarildi: true),
        oncekiler,
      );
      expect(h, contains('hedef_ustasi'));
    });

    test('gizli rozetler', () {
      final h = hakEdilenRozetler(
        _ozet(
          tamamlandi: true,
          ulkeDahaOnceDenendi: true,
          enDusukSaglik: 8,
          olumYas: 75,
          ulkeOmru: 74.6,
        ),
        {},
      );
      expect(h, containsAll(['deja_vu', 'dar_kurtulus', 'tam_vaktinde']));
    });

    test('genç ölümde denge rozetleri verilmez', () {
      final h = hakEdilenRozetler(
        _ozet(olumYas: 20, zaman: 95, para: 95, saglik: 95, iliski: 95),
        {},
      );
      expect(h, isNot(contains('kusursuz_denge')));
      expect(h, isNot(contains('varlikli')));
    });
  });

  group('Rozet listesi', () {
    test('kimlikler benzersiz', () {
      final idler = tumRozetler.map((r) => r.id).toList();
      expect(idler.toSet().length, idler.length);
    });

    test('her rozetin TR ve EN adı ve açıklaması var', () {
      final tr = {...trMetin, ...trRozet};
      final en = {...enMetin, ...enRozet};
      for (final r in tumRozetler) {
        for (final a in ['ad', 'acik']) {
          expect(tr['rozet_${r.id}_$a'], isNotNull, reason: 'TR ${r.id}_$a');
          expect(en['rozet_${r.id}_$a'], isNotNull, reason: 'EN ${r.id}_$a');
        }
      }
    });

    test('her rozet türünün başlığı var', () {
      for (final t in RozetTuru.values) {
        expect(trRozet['rozet_tur_${t.name}'], isNotNull);
        expect(enRozet['rozet_tur_${t.name}'], isNotNull);
      }
    });
  });
}
