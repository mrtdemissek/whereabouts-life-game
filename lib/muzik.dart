import 'dart:async';
import 'dart:math';
import 'tohumlu.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MuzikTuru { ana, oyun }

const int _hiz = 22050; // örnekleme hızı (Hz)
const String _muzikAnahtari = 'muzik_acik';
const double _muzikSesi = 0.30; // 0 ile 1 arası; efektlerin altında kalır

// Bir akor: bas notası, pad (yastık) notaları ve melodinin seçeceği notalar
class _Akor {
  final double bas;
  final List<double> pad;
  final List<double> melodi; // alçaktan yükseğe
  const _Akor(this.bas, this.pad, this.melodi);
}

// Bir parçanın tarifi
class _Plan {
  final double bpm;
  final List<_Akor> akorlar;
  final int olcuPerAkor; // her akor kaç ölçü sürer
  final double melodiCarpani; // 1: aynı oktav, 0.5: bir oktav aşağı
  final double vurus; // vuruş üstündeki notaların çalınma olasılığı
  final double ara; // vuruş arası notaların çalınma olasılığı
  final double tau; // melodi notalarının sönüm süresi (sn)
  final int tohum;
  const _Plan({
    required this.bpm,
    required this.akorlar,
    required this.olcuPerAkor,
    required this.melodiCarpani,
    required this.vurus,
    required this.ara,
    required this.tau,
    required this.tohum,
  });
}

const _akorC = _Akor(
  130.81,
  [261.63, 329.63, 392.00],
  [392.00, 523.25, 587.33, 659.25, 783.99, 1046.50],
);
const _akorAm = _Akor(
  110.00,
  [220.00, 261.63, 329.63],
  [329.63, 440.00, 523.25, 587.33, 659.25, 880.00],
);
const _akorF = _Akor(
  87.31,
  [174.61, 220.00, 261.63],
  [349.23, 440.00, 523.25, 698.46, 783.99, 880.00],
);
const _akorG = _Akor(
  98.00,
  [196.00, 246.94, 293.66],
  [392.00, 493.88, 587.33, 783.99, 880.00, 987.77],
);

const _anaPlan = _Plan(
  bpm: 78,
  akorlar: [_akorC, _akorAm, _akorF, _akorG],
  olcuPerAkor: 2,
  melodiCarpani: 1.0,
  vurus: 0.9,
  ara: 0.5,
  tau: 0.65,
  tohum: 11,
);

const _oyunPlan = _Plan(
  bpm: 66,
  akorlar: [_akorAm, _akorF, _akorC, _akorG],
  olcuPerAkor: 2,
  melodiCarpani: 0.5,
  vurus: 0.7,
  ara: 0.25,
  tau: 0.9,
  tohum: 29,
);

// Müzik kutusu sesi: temel nota ve hızla sönen iki üst ses.
// Notanın kuyruğu başa sarılır, böylece döngü kesintisiz olur.
void _kutuNota(Float64List buf, double bas, double hz, double ses, double tau) {
  final n = buf.length;
  final baslangic = (bas * _hiz).round();
  final uzunluk = (tau * 5 * _hiz).round();
  final d1 = exp(-1 / (tau * _hiz));
  final d2 = exp(-1 / (tau * 0.5 * _hiz));
  final d3 = exp(-1 / (tau * 0.25 * _hiz));
  final kapanisSure = 0.05 * _hiz;
  var f1 = 1.0;
  var f2 = 1.0;
  var f3 = 1.0;
  for (var i = 0; i < uzunluk; i++) {
    final t = i / _hiz;
    final atak = min(1.0, t / 0.004);
    final kapanis =
        i > uzunluk - kapanisSure ? (uzunluk - i) / kapanisSure : 1.0;
    final w = 2 * pi * hz * t;
    final v = (sin(w) * f1 + 0.30 * sin(2 * w) * f2 + 0.10 * sin(3 * w) * f3) *
        ses *
        atak *
        kapanis;
    buf[(baslangic + i) % n] += v;
    f1 *= d1;
    f2 *= d2;
    f3 *= d3;
  }
}

// Yavaş girip yavaş çıkan yumuşak yastık sesi
void _padNota(Float64List buf, double bas, double sure, double hz, double ses) {
  final n = buf.length;
  final baslangic = (bas * _hiz).round();
  final toplam = ((sure + 1.2) * _hiz).round();
  for (var i = 0; i < toplam; i++) {
    final t = i / _hiz;
    final atak = min(1.0, t / 1.2);
    final son = t < sure ? 1.0 : max(0.0, 1 - (t - sure) / 1.2);
    final w = 2 * pi * hz * t;
    final v = (sin(w) + 0.5 * sin(w * 1.003)) * ses * atak * son;
    buf[(baslangic + i) % n] += v;
  }
}

// Yumuşak bas notası
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

// 16 bit mono WAV dosyası. ornekler carpan ile ölçeklenir.
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
  veri.setUint16(20, 1, Endian.little); // PCM
  veri.setUint16(22, 1, Endian.little); // mono
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

// Bir parçayı hesaplayıp WAV baytları olarak döndürür. compute ile ayrı bir
// iş parçacığında çalıştırılır, bu yüzden üst düzey bir fonksiyon olmalı.
Uint8List _muzikUret(int tur) {
  final plan = tur == MuzikTuru.ana.index ? _anaPlan : _oyunPlan;
  final vurusSn = 60.0 / plan.bpm;
  final olcuSn = vurusSn * 4;
  final olcuSayisi = plan.akorlar.length * plan.olcuPerAkor;
  final n = (olcuSn * olcuSayisi * _hiz).round();
  final buf = Float64List(n);
  final r = Tohumlu(plan.tohum);

  // Yastık ve bas
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

  // Melodi: her ölçüde sekiz sekizlik dilim, akorun notalarından seçilir
  var idx = 2;
  for (var o = 0; o < olcuSayisi; o++) {
    final akor = plan.akorlar[o ~/ plan.olcuPerAkor];
    final havuz = akor.melodi;
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

  // Tepe değeri sabitle
  var tepe = 0.0;
  for (final v in buf) {
    final a = v.abs();
    if (a > tepe) tepe = a;
  }
  final k = tepe > 0 ? 0.8 / tepe : 1.0;
  return _wavYap(buf, k);
}

// Fon müziği yöneticisi. Her yerden Muzik.ornek ile erişilir.
class Muzik with WidgetsBindingObserver {
  Muzik._();
  static final Muzik ornek = Muzik._();

  bool acik = true;
  final AudioPlayer _oyn = AudioPlayer();
  // Hesaplanan ya da hesaplanmakta olan parçalar. Aynı parça iki kez
  // hesaplanmasın diye sonuç değil, hesaplamanın kendisi saklanır.
  final Map<MuzikTuru, Future<Uint8List>> _uretim = {};
  MuzikTuru? _calan; // şu an çalan ya da çalması istenen parça
  bool _caliyor = false;
  bool _arkaPlanda = false;
  int _islemNo = 0; // eski asenkron işlemleri iptal etmek için

  Future<void> yukle() async {
    final t = await SharedPreferences.getInstance();
    acik = t.getBool(_muzikAnahtari) ?? true;
    await _oyn.setReleaseMode(ReleaseMode.loop);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<Uint8List> _bytes(MuzikTuru tur) => _uretim.putIfAbsent(
        tur,
        () => compute<int, Uint8List>(_muzikUret, tur.index),
      );

  // Parçaları önceden hesaplar, böylece geçişlerde bekleme olmaz
  Future<void> hazirla() async {
    for (final tur in MuzikTuru.values) {
      await _bytes(tur);
    }
  }

  // Uygulama arka plana geçince müziği duraklatır, dönünce sürdürür
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _arkaPlanda = true;
      if (_caliyor) _oyn.pause();
    } else if (state == AppLifecycleState.resumed) {
      _arkaPlanda = false;
      if (_caliyor && acik) _oyn.resume();
    }
  }

  // Sesi bas değerinden son değerine sure içinde kaydırır
  Future<void> _sesiAyarla(
    double bas,
    double son,
    Duration sure,
    int no,
  ) async {
    const adim = 12;
    final bekle = sure.inMilliseconds ~/ adim;
    for (var i = 1; i <= adim; i++) {
      await Future.delayed(Duration(milliseconds: bekle));
      if (no != _islemNo) return;
      await _oyn.setVolume(bas + (son - bas) * i / adim);
    }
  }

  // Ayarlardaki açma/kapama anahtarı
  Future<void> ayarla(bool v) async {
    acik = v;
    final t = await SharedPreferences.getInstance();
    await t.setBool(_muzikAnahtari, v);
    if (v) {
      await cal(_calan ?? MuzikTuru.ana);
    } else {
      final no = ++_islemNo;
      if (_caliyor) {
        await _sesiAyarla(_muzikSesi, 0, const Duration(milliseconds: 300), no);
        if (no != _islemNo) return;
        await _oyn.stop();
        _caliyor = false;
      }
    }
  }

  // Bir parçayı başlatır. Başka bir parça çalıyorsa önce kısa bir süre kısılır.
  Future<void> cal(MuzikTuru tur) async {
    if (_calan == tur && _caliyor) return;
    _calan = tur;
    if (!acik) return;
    final no = ++_islemNo;
    if (_caliyor) {
      await _sesiAyarla(_muzikSesi, 0, const Duration(milliseconds: 400), no);
      if (no != _islemNo) return;
      await _oyn.stop();
      _caliyor = false;
    }

    final bytes = await _bytes(tur);

    if (no != _islemNo || !acik) return;
    await _oyn.setVolume(0);
    await _oyn.play(BytesSource(bytes));
    _caliyor = true;
    if (_arkaPlanda) {
      await _oyn.pause();
      return;
    }
    await _sesiAyarla(0, _muzikSesi, const Duration(milliseconds: 1000), no);
  }

  // Müziği yavaşça kısıp durdurur
  Future<void> durdur({
    Duration sure = const Duration(milliseconds: 2500),
  }) async {
    _calan = null;
    final no = ++_islemNo;
    if (!_caliyor) return;
    await _sesiAyarla(_muzikSesi, 0, sure, no);
    if (no != _islemNo) return;
    await _oyn.stop();
    _caliyor = false;
  }
}