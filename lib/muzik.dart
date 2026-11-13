import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MuzikTuru { ana, oyun }

const String _muzikAnahtari = 'muzik_acik';
const double _muzikSesi = 0.30; // 0 ile 1 arası; efektlerin altında kalır

// Parçalar önceden üretilip assets/muzik içine konmuş WAV dosyaları.
// (Eskiden açılışta telefonda hesaplanıyordu; bu, açılışı ve ilk dakikaları
// ciddi biçimde yavaşlatıyordu.)
const Map<MuzikTuru, String> _dosyalar = {
  MuzikTuru.ana: 'muzik/muzik_ana.wav',
  MuzikTuru.oyun: 'muzik/muzik_oyun.wav',
};

// Fon müziği yöneticisi. Her yerden Muzik.ornek ile erişilir.
class Muzik with WidgetsBindingObserver {
  Muzik._();
  static final Muzik ornek = Muzik._();

  bool acik = true;
  final AudioPlayer _oyn = AudioPlayer();
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

  // Eski arayüzle uyum için duruyor; parçalar artık hazır dosya.
  Future<void> hazirla() async {}

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
    if (no != _islemNo || !acik) return;
    await _oyn.setVolume(0);
    await _oyn.play(AssetSource(_dosyalar[tur]!));
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
