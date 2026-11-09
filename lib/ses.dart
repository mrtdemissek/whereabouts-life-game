import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SesTuru { tik, secim, artis, azalis, rozet, dogum, son }

enum TitresimTuru { secim, hafif, orta, guclu }

const int _hiz = 22050; // örnekleme hızı (Hz)
const String _sesAnahtari = 'ses_acik';
const String _titresimAnahtari = 'titresim_acik';

// Bir nota: hz frekansından hzSon frekansına kayan, kısa zarflı sinüs dalgası
List<double> _nota(
  double hz,
  double sure, {
  double hzSon = 0,
  double ses = 0.45,
}) {
  final n = (sure * _hiz).round();
  final cikti = List<double>.filled(n, 0.0);
  final hedef = hzSon > 0 ? hzSon : hz;
  var faz = 0.0;
  for (var i = 0; i < n; i++) {
    final t = i / n;
    final f = hz + (hedef - hz) * t;
    faz += 2 * pi * f / _hiz;
    final atak = min(1.0, i / (_hiz * 0.005)); // ilk 5 ms'de yumuşak başlangıç
    final sonum = pow(1 - t, 1.5).toDouble(); // sona doğru sönüm
    cikti[i] = sin(faz) * ses * atak * sonum;
  }
  return cikti;
}

// Örnekleri 16 bit mono WAV dosyasına çevirir
Uint8List _wav(List<double> ornekler) {
  final n = ornekler.length;
  final veri = ByteData(44 + n * 2);
  void yaz(int konum, String s) {
    for (var i = 0; i < s.length; i++) {
      veri.setUint8(konum + i, s.codeUnitAt(i));
    }
  }

  yaz(0, 'RIFF');
  veri.setUint32(4, 36 + n * 2, Endian.little);
  yaz(8, 'WAVE');
  yaz(12, 'fmt ');
  veri.setUint32(16, 16, Endian.little);
  veri.setUint16(20, 1, Endian.little); // PCM
  veri.setUint16(22, 1, Endian.little); // mono
  veri.setUint32(24, _hiz, Endian.little);
  veri.setUint32(28, _hiz * 2, Endian.little);
  veri.setUint16(32, 2, Endian.little);
  veri.setUint16(34, 16, Endian.little);
  yaz(36, 'data');
  veri.setUint32(40, n * 2, Endian.little);
  for (var i = 0; i < n; i++) {
    final v = (ornekler[i].clamp(-1.0, 1.0) * 32767).round();
    veri.setInt16(44 + i * 2, v, Endian.little);
  }
  return veri.buffer.asUint8List();
}

Uint8List _uret(SesTuru tur) {
  final ornekler = switch (tur) {
    SesTuru.tik => _nota(900, 0.03, ses: 0.35),
    SesTuru.secim => [..._nota(520, 0.07), ..._nota(780, 0.09)],
    SesTuru.artis => [..._nota(660, 0.08), ..._nota(880, 0.12)],
    SesTuru.azalis => [..._nota(440, 0.08), ..._nota(330, 0.14)],
    SesTuru.rozet => [
        ..._nota(523.25, 0.10),
        ..._nota(659.25, 0.10),
        ..._nota(783.99, 0.10),
        ..._nota(1046.5, 0.30),
      ],
    SesTuru.dogum => [
        ..._nota(600, 0.06),
        ..._nota(800, 0.06),
        ..._nota(1000, 0.06),
        ..._nota(1300, 0.22),
      ],
    SesTuru.son => [
        ..._nota(392, 0.25, ses: 0.4),
        ..._nota(330, 0.30, ses: 0.4),
        ..._nota(262, 0.55, ses: 0.4),
      ],
  };
  return _wav(ornekler);
}

// Ses ve titreşim yöneticisi. Her yerden Ses.ornek ile erişilir.
class Ses {
  Ses._();
  static final Ses ornek = Ses._();

  bool sesAcik = true;
  bool titresimAcik = true;
  final Map<SesTuru, Uint8List> _onbellek = {};
  late final List<AudioPlayer> _havuz =
      List.generate(4, (_) => AudioPlayer());
  int _sira = 0;

  Future<void> yukle() async {
    final t = await SharedPreferences.getInstance();
    sesAcik = t.getBool(_sesAnahtari) ?? true;
    titresimAcik = t.getBool(_titresimAnahtari) ?? true;
  }

  Future<void> sesAyarla(bool v) async {
    sesAcik = v;
    final t = await SharedPreferences.getInstance();
    await t.setBool(_sesAnahtari, v);
  }

  Future<void> titresimAyarla(bool v) async {
    titresimAcik = v;
    final t = await SharedPreferences.getInstance();
    await t.setBool(_titresimAnahtari, v);
  }

  // Bir sesi çalar. Seslerin üst üste binmesi için dört oynatıcı sırayla kullanılır.
  void cal(SesTuru tur) {
    if (!sesAcik) return;
    final bytes = _onbellek.putIfAbsent(tur, () => _uret(tur));
    final p = _havuz[_sira % _havuz.length];
    _sira++;
    p.play(BytesSource(bytes)).catchError((_) {});
  }

  void titret(TitresimTuru tur) {
    if (!titresimAcik) return;
    switch (tur) {
      case TitresimTuru.secim:
        HapticFeedback.selectionClick();
      case TitresimTuru.hafif:
        HapticFeedback.lightImpact();
      case TitresimTuru.orta:
        HapticFeedback.mediumImpact();
      case TitresimTuru.guclu:
        HapticFeedback.heavyImpact();
    }
  }
}