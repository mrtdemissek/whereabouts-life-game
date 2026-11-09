import 'dart:async';
import 'package:flutter/material.dart';
import 'ana_ekran.dart';
import 'ayarlar_ekrani.dart';
import 'dil.dart';
import 'gecis.dart';
import 'muzik.dart';
import 'oyuncak.dart';
import 'sahne.dart';
import 'tema.dart';

const String oyunAdi = 'Whereabouts'; // marka adı, buradan değiştirilir

class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  static const _yaslar = [5, 12, 16, 30, 65];
  int _i = 0;
  Timer? _zamanlayici;

  @override
  void initState() {
    super.initState();
    _zamanlayici = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) setState(() => _i = (_i + 1) % _yaslar.length);
    });
    // Ana müziği başlat, iki parçayı da arka planda hazırla
    Muzik.ornek.cal(MuzikTuru.ana);
    Muzik.ornek.hazirla();
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  void _basla() {
    Navigator.pushReplacement(context, yumusakGecis(const AnaEkran()));
  }

  void _ayarlariAc() {
    Navigator.push(context, yumusakGecis(const AyarlarEkrani()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OyuncakKart(
                      renk: Renk.lavanta,
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              oyunAdi,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.t('oyun_alt_baslik'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.t('acilis_slogan'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Sahne(
                      yas: _yaslar[_i],
                      ten: const Color(0xFFF2C29B),
                      gomlek: const Color(0xFF3F51B5),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _basla,
                      child: Text(context.t('basla')),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings),
                tooltip: context.t('ayarlar'),
                onPressed: _ayarlariAc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}