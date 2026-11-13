// Whereabouts kart dogrulayici ve kapsam raporu.
// Calistirma:  dart run tools/kart_dogrula.dart
// Hata varsa cikis kodu 1 olur. Cikti ASCII tutulur (terminal uyumu icin).
// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';

import '../lib/karar.dart';
import '../lib/kartlar2.dart';
import '../lib/kartlar3.dart';
import '../lib/baglam_kartlari.dart';
import '../lib/zincir.dart';
import '../lib/olaylar.dart';
import '../lib/olaylar2.dart';
import '../lib/diller/tr_kartlar.dart';
import '../lib/diller/tr_kartlar2.dart';
import '../lib/diller/tr_kartlar3.dart';
import '../lib/diller/tr_baglam.dart';
import '../lib/diller/tr_zincir.dart';
import '../lib/diller/tr_olay.dart';
import '../lib/diller/tr_olay2.dart';
import '../lib/diller/tr_sonuc.dart';
import '../lib/diller/en_kartlar.dart';
import '../lib/diller/en_kartlar2.dart';
import '../lib/diller/en_kartlar3.dart';
import '../lib/diller/en_baglam.dart';
import '../lib/diller/en_zincir.dart';
import '../lib/diller/en_olay.dart';
import '../lib/diller/en_olay2.dart';
import '../lib/diller/en_sonuc.dart';

const dogumEtiketleri = {'zor', 'orta', 'refah', 'kent', 'kir'};
const turler = ['zor', 'orta', 'refah'];
const yerler = ['kent', 'kir'];
// (ad, en kucuk yas, en buyuk yas, hedef kart sayisi). Hedef, bir hayatta o
// bantta cekilen kart sayisinin yaklasik 8 kati: ayni kartlarin tekrar
// gelme ihtimali dusuk kalsin.
const bantlar = <(String, int, int, int)>[
  ('5-12', 5, 12, 32),
  ('13-18', 13, 18, 24),
  ('19-29', 19, 29, 44),
  ('30-44', 30, 44, 40),
  ('45-64', 45, 64, 56),
  ('65+', 65, 120, 40),
];

final hatalar = <String>[];
final uyarilar = <String>[];

void hata(String m) => hatalar.add(m);
void uyari(String m) => uyarilar.add(m);

void main() {
  final gruplar = <String, List<Karar>>{
    'kararlar': kararlar,
    'yeniKararlar': yeniKararlar,
    'kartlar3': kartlar3,
    'baglamKararlari': baglamKararlari,
    'zincirKartlari': zincirKartlari,
    'olayKartlari': olayKartlari,
    'olayKartlari2': olayKartlari2,
  };
  final tr = <String, String>{
    ...trKartlar, ...trKartlar2, ...trKartlar3, ...trSonuc, ...trBaglam, ...trZincir, ...trOlay, ...trOlay2,
  };
  final en = <String, String>{
    ...enKartlar, ...enKartlar2, ...enKartlar3, ...enSonuc, ...enBaglam, ...enZincir, ...enOlay, ...enOlay2,
  };

  final tum = <Karar>[];
  final kaynak = <String, String>{};
  for (final g in gruplar.entries) {
    for (final k in g.value) {
      if (kaynak.containsKey(k.id)) {
        hata('${k.id}: kimlik iki kez kullanilmis (${kaynak[k.id]} ve ${g.key})');
      }
      kaynak[k.id] = g.key;
      tum.add(k);
    }
  }

  // Uretilebilen etiketler
  final uretilen = <String>{...dogumEtiketleri};
  for (final k in tum) {
    uretilen.addAll(k.solEtiket);
    uretilen.addAll(k.sagEtiket);
  }

  const anahtarlar = ['metin', 'sol', 'sag', 'sol_son', 'sag_son'];
  for (final k in tum) {
    for (final a in anahtarlar) {
      final key = '${k.id}_$a';
      if (!tr.containsKey(key)) hata('${k.id}: TR ceviri eksik ($key)');
      if (!en.containsKey(key)) hata('${k.id}: EN ceviri eksik ($key)');
    }
    for (final dil in [('TR', tr), ('EN', en)]) {
      final m = dil.$2['${k.id}_metin'];
      if (m != null && m.trim().isEmpty) hata('${k.id}: ${dil.$1} metin bos');
      if (m != null && m.length > 170) {
        uyari('${k.id}: ${dil.$1} metin uzun (${m.length} karakter)');
      }
      for (final a in ['sol', 'sag']) {
        final e = dil.$2['${k.id}_$a'];
        if (e != null && e.length > 28) {
          uyari('${k.id}: ${dil.$1} $a etiketi uzun (${e.length}): "$e"');
        }
      }
    }
    if (k.minYas > k.maxYas) hata('${k.id}: minYas > maxYas');
    if (k.minYas < 5) uyari('${k.id}: minYas 5 altinda (kart ekrani 5 yasindan baslar)');
    for (final g in k.gerek) {
      if (!uretilen.contains(g)) {
        hata('${k.id}: gerek etiketi "$g" hicbir secimle uretilmiyor');
      }
    }
    for (final y in k.yasak) {
      if (!uretilen.contains(y)) uyari('${k.id}: yasak etiketi "$y" hic uretilmiyor');
    }
    for (final e in [('sol', k.sol), ('sag', k.sag)]) {
      final v = [e.$2.zaman, e.$2.para, e.$2.saglik, e.$2.iliski];
      if (v.every((x) => x == 0)) hata('${k.id}: ${e.$1} secimin etkisi sifir');
      if (v.any((x) => x.abs() > 25)) {
        uyari('${k.id}: ${e.$1} secimde buyuk etki ($v)');
      }
    }
  }

  // Yon dengesi: hangi tarafta zaman artisi daha buyuk
  var solZaman = 0, sagZaman = 0;
  for (final k in tum) {
    if (k.sol.zaman > k.sag.zaman) solZaman++;
    if (k.sag.zaman > k.sol.zaman) sagZaman++;
  }

  // Kapsam: baglam x yas bandi. Zincir (gerek icinde baglam disi etiket olan)
  // kartlar sayilmaz; yalnizca dogrudan uygun olanlar.
  final kapsam = <String, int>{};
  for (final t in turler) {
    for (final y in yerler) {
      final ctx = {t, y};
      for (final b in bantlar) {
        var n = 0;
        for (final k in tum) {
          if (k is OlayKarti) continue;
          if (!k.gerek.every(ctx.contains)) continue;
          if (k.yasak.any(ctx.contains)) continue;
          if (k.maxYas < b.$2 || k.minYas > b.$3) continue;
          n++;
        }
        kapsam['$t/$y/${b.$1}'] = n;
      }
    }
  }

  // Rapor
  final s = StringBuffer();
  s.writeln('=== KART RAPORU ===');
  s.writeln('Toplam kart: ${tum.length}');
  for (final g in gruplar.entries) {
    s.writeln('  ${g.key}: ${g.value.length}');
  }
  s.writeln('Yon dengesi (zaman artisi): sol $solZaman, sag $sagZaman');
  final alanlar = <String, int>{};
  for (final k in tum) {
    if (k is OlayKarti) alanlar[k.riskAlan] = (alanlar[k.riskAlan] ?? 0) + 1;
  }
  s.writeln('Olay kartlari risk alanina gore: $alanlar');
  s.writeln('');
  s.writeln('Kapsam (baglam/yas bandi basina uygun kart sayisi; * = hedefin altinda):');
  s.write('tur/yer'.padRight(12));
  for (final b in bantlar) {
    s.write('${b.$1}/${b.$4}'.padLeft(10));
  }
  s.writeln();
  final eksik = <String, int>{for (final b in bantlar) b.$1: 0};
  var zayif = 0;
  for (final t in turler) {
    for (final y in yerler) {
      s.write('$t/$y'.padRight(12));
      for (final b in bantlar) {
        final n = kapsam['$t/$y/${b.$1}']!;
        s.write((n < b.$4 ? '$n*' : '$n').padLeft(10));
        if (n < b.$4) {
          zayif++;
          final fark = b.$4 - n;
          if (fark > eksik[b.$1]!) eksik[b.$1] = fark;
        }
      }
      s.writeln();
    }
  }
  s.writeln('Zayif hucre: $zayif / ${turler.length * yerler.length * bantlar.length}');
  s.writeln('Yas bandina gore en az gereken yeni kart (en zayif hucreye gore): $eksik');
  s.writeln('');
  s.writeln('Uyarilar: ${uyarilar.length}');
  for (final u in uyarilar.take(40)) {
    s.writeln('  uyari: $u');
  }
  if (uyarilar.length > 40) s.writeln('  ... ve ${uyarilar.length - 40} uyari daha');
  s.writeln('Hatalar: ${hatalar.length}');
  for (final h in hatalar.take(60)) {
    s.writeln('  HATA: $h');
  }
  if (hatalar.length > 60) s.writeln('  ... ve ${hatalar.length - 60} hata daha');
  s.writeln(hatalar.isEmpty ? 'SONUC: TAMAM' : 'SONUC: HATA VAR');
  stdout.write(s);
  exit(hatalar.isEmpty ? 0 : 1);
}
