import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'diller/tr.dart';
import 'diller/tr_kartlar.dart';
import 'diller/tr_kartlar2.dart';
import 'diller/tr_kartlar3.dart';
import 'diller/tr_baglam.dart';
import 'diller/tr_aile.dart';
import 'diller/tr_sonuc.dart';
import 'diller/tr_zincir.dart';
import 'diller/tr_neden.dart';
import 'diller/tr_olay.dart';
import 'diller/tr_olay2.dart';
import 'diller/tr_ses.dart';
import 'diller/tr_gunluk.dart';
import 'diller/en.dart';
import 'diller/en_kartlar.dart';
import 'diller/en_kartlar2.dart';
import 'diller/en_kartlar3.dart';
import 'diller/en_baglam.dart';
import 'diller/en_aile.dart';
import 'diller/en_sonuc.dart';
import 'diller/en_zincir.dart';
import 'diller/en_neden.dart';
import 'diller/en_olay.dart';
import 'diller/en_olay2.dart';
import 'diller/en_ses.dart';
import 'diller/en_gunluk.dart';

// Desteklenen bir dil: kod ve dilin kendi adı
class DilBilgisi {
  final String kod;
  final String ad;
  const DilBilgisi(this.kod, this.ad);
}

const desteklenenDiller = [
  DilBilgisi('tr', 'Türkçe'),
  DilBilgisi('en', 'English'),
];

const Map<String, Map<String, String>> _metinler = {
  'tr': {
    ...trMetin,
    ...trKartlar,
    ...trKartlar2,
    ...trKartlar3,
    ...trBaglam,
    ...trAile,
    ...trSonuc,
    ...trZincir,
    ...trNeden,
    ...trOlay,
    ...trOlay2,
    ...trSes,
    ...trGunluk,
  },
  'en': {
    ...enMetin,
    ...enKartlar,
    ...enKartlar2,
    ...enKartlar3,
    ...enBaglam,
    ...enAile,
    ...enSonuc,
    ...enZincir,
    ...enNeden,
    ...enOlay,
    ...enOlay2,
    ...enSes,
    ...enGunluk,
  },
};

const String _dilAnahtari = 'dil_kodu';

class Yerellestirme extends ChangeNotifier {
  String _kod = 'en';
  String get kod => _kod;

  // Kayıtlı dili okur; yoksa cihaz diline bakar, o da yoksa İngilizce
  Future<void> yukle() async {
    final t = await SharedPreferences.getInstance();
    final kayitli = t.getString(_dilAnahtari);
    if (kayitli != null && _metinler.containsKey(kayitli)) {
      _kod = kayitli;
      return;
    }
    final cihaz =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _kod = _metinler.containsKey(cihaz) ? cihaz : 'en';
  }

  Future<void> dilSec(String kod) async {
    if (!_metinler.containsKey(kod) || kod == _kod) return;
    _kod = kod;
    notifyListeners();
    final t = await SharedPreferences.getInstance();
    await t.setString(_dilAnahtari, kod);
  }

  // Anahtarı çevirir. Seçili dilde yoksa İngilizceye, o da yoksa anahtarın
  // kendisine düşer. {ad} gibi yer tutucuları değerlerle doldurur.
  String cevir(String anahtar, [Map<String, Object> degerler = const {}]) {
    String s =
        _metinler[_kod]?[anahtar] ?? _metinler['en']![anahtar] ?? anahtar;
    for (final e in degerler.entries) {
      s = s.replaceAll('{${e.key}}', '${e.value}');
    }
    return s;
  }
}

// Dil değişince onu kullanan ekranları otomatik yeniler
class YerelKapsam extends InheritedNotifier<Yerellestirme> {
  const YerelKapsam({
    required Yerellestirme yerel,
    required super.child,
    super.key,
  }) : super(notifier: yerel);

  static Yerellestirme of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<YerelKapsam>()!
        .notifier!;
  }
}

extension YerelUzanti on BuildContext {
  Yerellestirme get yerel => YerelKapsam.of(this);
  String t(String anahtar, [Map<String, Object> degerler = const {}]) =>
      YerelKapsam.of(this).cevir(anahtar, degerler);
}