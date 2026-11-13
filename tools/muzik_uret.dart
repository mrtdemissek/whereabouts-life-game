// Fon muziklerini bir kez uretip assets/muzik icine WAV olarak yazar.
// Calistirma (proje klasorunde):  dart run tools/muzik_uret.dart
// Eskiden bu hesap uygulama acilirken telefonda yapiliyordu ve acilisi
// cok yavaslatiyordu; artik uygulama hazir dosyalari calar.
// ignore_for_file: avoid_relative_lib_imports, avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../lib/tohumlu.dart';

const int _hiz = 22050;

class _Akor {
  final double bas;
  final List<double> pad;
  final List<double> melodi;
  const _Akor(this.bas, this.pad, this.melodi);
}

class _Plan {
  final double bpm;
  final List<_Akor> akorlar;
  final int olcuPerAkor;
  final double melodiCarpani;
  final double vurus;
  final double ara;
  final double tau;
  final int tohum;
  const _Plan(this.bpm, this.akorlar, this.olcuPerAkor, this.melodiCarpani,
      this.vurus, this.ara, this.tau, this.tohum);
}

const _akorC = _Akor(130.81, [261.63, 329.63, 392.00],
    [392.00, 523.25, 587.33, 659.25, 783.99, 1046.50]);
const _akorAm = _Akor(110.00, [220.00, 261.63, 329.63],
    [329.63, 440.00, 523.25, 587.33, 659.25, 880.00]);
const _akorF = _Akor(87.31, [174.61, 220.00, 261.63],
    [349.23, 440.00, 523.25, 698.46, 783.99, 880.00]);
const _akorG = _Akor(98.00, [196.00, 246.94, 293.66],
    [392.00, 493.88, 587.33, 783.99, 880.00, 987.77]);

const _anaPlan =
    _Plan(78, [_akorC, _akorAm, _akorF, _akorG], 2, 1.0, 0.9, 0.5, 0.65, 11);
const _oyunPlan =
    _Plan(66, [_akorAm, _akorF, _akorC, _akorG], 2, 0.5, 0.7, 0.25, 0.9, 29);

void _kutuNota(Float64List buf, double bas, double hz, double ses, double tau) {
  final n = buf.length;
  final baslangic = (bas * _hiz).round();
  final uzunluk = (tau * 5 * _hiz).round();
  final d1 = exp(-1 / (tau * _hiz));
  final d2 = exp(-1 / (tau * 0.5 * _hiz));
  final d3 = exp(-1 / (tau * 0.25 * _hiz));
  final kapanisSure = 0.05 * _hiz;
  var f1 = 1.0, f2 = 1.0, f3 = 1.0;
  for (var i = 0; i < uzunluk; i++) {
    final t = i / _hiz;
    final atak = min(1.0, t / 0.004);
    final kapanis =
        i > uzunluk - kapanisSure ? (uzunluk - i) / kapanisSure : 1.0;
    final w = 2 * pi * hz * t;
    final v = (sin(w) * f1 + 0.30 * sin(2 * w) * f2 + 0.10 * sin(3 * w) * f3) *
        ses * atak * kapanis;
    buf[(baslangic + i) % n] += v;
    f1 *= d1;
    f2 *= d2;
    f3 *= d3;
  }
}

void _padNota(Float64List buf, double bas, double sure, double hz, double ses) {
  final n = buf.length;
  final baslangic = (bas * _hiz).round();
  final toplam = ((sure + 1.2) * _hiz).round();
  for (var i = 0; i < toplam; i++) {
    final t = i / _hiz;
    final atak = min(1.0, t / 1.2);
    final son = t < sure ? 1.0 : max(0.0, 1 - (t - sure) / 1.2);
    final w = 2 * pi * hz * t;
    buf[(baslangic + i) % n] +=
        (sin(w) + 0.5 * sin(w * 1.003)) * ses * atak * son;
  }
}

void _basNota(Float64List buf, double bas, double hz, double ses) {
  final n = buf.length;
  final baslangic = (bas * _hiz).round();
  final uzunluk = (2.6 * _hiz).round();
  final sonum = exp(-1 / (1.1 * _hiz));
  final kapanisSure = 0.05 * _hiz;
  var zarf = 1.0;
  for (var i = 0; i < uzunluk; i++) {
    final t = i / _hiz;
    final atak = min(1.0, t / 0.02);
    final kapanis =
        i > uzunluk - kapanisSure ? (uzunluk - i) / kapanisSure : 1.0;
    buf[(baslangic + i) % n] +=
        sin(2 * pi * hz * t) * ses * zarf * atak * kapanis;
    zarf *= sonum;
  }
}

Uint8List _wavYap(Float64List ornekler, double carpan) {
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
  veri.setUint16(20, 1, Endian.little);
  veri.setUint16(22, 1, Endian.little);
  veri.setUint32(24, _hiz, Endian.little);
  veri.setUint32(28, _hiz * 2, Endian.little);
  veri.setUint16(32, 2, Endian.little);
  veri.setUint16(34, 16, Endian.little);
  yaz(36, 'data');
  veri.setUint32(40, n * 2, Endian.little);
  for (var i = 0; i < n; i++) {
    final v = (ornekler[i] * carpan).clamp(-1.0, 1.0).toDouble();
    veri.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
  }
  return veri.buffer.asUint8List();
}

Uint8List _muzikUret(_Plan plan) {
  final vurusSn = 60.0 / plan.bpm;
  final olcuSn = vurusSn * 4;
  final olcuSayisi = plan.akorlar.length * plan.olcuPerAkor;
  final n = (olcuSn * olcuSayisi * _hiz).round();
  final buf = Float64List(n);
  final r = Tohumlu(plan.tohum);
  for (var a = 0; a < plan.akorlar.length; a++) {
    final akor = plan.akorlar[a];
    final bas = a * plan.olcuPerAkor * olcuSn;
    final sure = plan.olcuPerAkor * olcuSn;
    for (final hz in akor.pad) {
      _padNota(buf, bas, sure, hz, 0.055);
    }
    for (var b = 0; b < plan.olcuPerAkor; b++) {
      _basNota(buf, bas + b * olcuSn, akor.bas, 0.16);
    }
  }
  var idx = 2;
  for (var o = 0; o < olcuSayisi; o++) {
    final havuz = plan.akorlar[o ~/ plan.olcuPerAkor].melodi;
    for (var s = 0; s < 8; s++) {
      final vurusUstu = s.isEven;
      final akorBasi = o % plan.olcuPerAkor == 0 && s == 0;
      if (!akorBasi) {
        final p = vurusUstu ? plan.vurus : plan.ara;
        if (r.nextDouble() > p) continue;
      }
      if (akorBasi) {
        idx = r.nextBool() ? 1 : 3;
      } else {
        idx = (idx + r.nextInt(5) - 2).clamp(0, havuz.length - 1).toInt();
      }
      final hz = havuz[idx] * plan.melodiCarpani;
      final ses = (vurusUstu ? 0.22 : 0.15) * (0.85 + 0.3 * r.nextDouble());
      _kutuNota(buf, o * olcuSn + s * vurusSn / 2, hz, ses, plan.tau);
    }
  }
  var tepe = 0.0;
  for (final v in buf) {
    if (v.abs() > tepe) tepe = v.abs();
  }
  return _wavYap(buf, tepe > 0 ? 0.8 / tepe : 1.0);
}

void main() {
  final klasor = Directory('assets/muzik')..createSync(recursive: true);
  for (final (ad, plan) in [('muzik_ana.wav', _anaPlan), ('muzik_oyun.wav', _oyunPlan)]) {
    final bayt = _muzikUret(plan);
    File('${klasor.path}/$ad').writeAsBytesSync(bayt);
    print('$ad yazildi (${bayt.length ~/ 1024} KB)');
  }
}
