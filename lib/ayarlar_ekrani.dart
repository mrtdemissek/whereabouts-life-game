import 'package:flutter/material.dart';
import 'dil.dart';
import 'hareket.dart';
import 'muzik.dart';
import 'oyun_ui.dart';
import 'ses.dart';
import 'tema.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  final Ses ses = Ses.ornek;
  final Muzik muzik = Muzik.ornek;

  Widget _baslik(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 6),
        child: Text(s, style: Yazi.piksel(boyut: 19, kalinlik: FontWeight.w700)),
      );

  Widget _anahtar(String yazi, bool deger, Future<void> Function(bool) degisti) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(yazi, style: Yazi.govde(boyut: 16, kalinlik: FontWeight.w800)),
      value: deger,
      thumbColor: const WidgetStatePropertyAll(Renk.kagit),
      trackColor: WidgetStateProperty.resolveWith(
        (d) => d.contains(WidgetState.selected) ? Renk.artis : Renk.soluk,
      ),
      onChanged: (v) async {
        await degisti(v);
        if (mounted) setState(() {});
      },
    );
  }

  Widget _kucukDugme(String yazi, VoidCallback onTap) => OyunDugme(
        yukseklik: 44,
        golge: 3,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(yazi, style: Yazi.govde(boyut: 14, kalinlik: FontWeight.w800)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final yerel = context.yerel;
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, mq.padding.top + 8, 16, 32 + mq.padding.bottom),
        children: [
          Row(
            children: [
              SizedBox(
                width: 48,
                child: OyunDugme(
                  yukseklik: 44,
                  golge: 3,
                  anlam: context.t('geri'),
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.t('ayarlar'),
                style: Yazi.piksel(boyut: 26, kalinlik: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OyunPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _baslik(context.t('dil')),
                Row(
                  children: [
                    for (final d in desteklenenDiller) ...[
                      if (d != desteklenenDiller.first) const SizedBox(width: 10),
                      Expanded(
                        child: OyunDugme(
                          yukseklik: 52,
                          renk: d.kod == yerel.kod ? Renk.lavanta : Renk.kagit,
                          anlam: d.ad,
                          onTap: () => yerel.dilSec(d.kod),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(d.ad, style: Yazi.govde(boyut: 16, kalinlik: FontWeight.w800)),
                              if (d.kod == yerel.kod) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OyunPanel(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _baslik(context.t('ses_baslik')),
                _anahtar(context.t('ses_efekt'), ses.sesAcik, ses.sesAyarla),
                _anahtar(context.t('muzik'), muzik.acik, muzik.ayarla),
                _anahtar(context.t('titresim'), ses.titresimAcik, ses.titresimAyarla),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OyunPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _baslik(context.t('hareket_baslik')),
                Row(
                  children: [
                    for (final m in HareketModu.values) ...[
                      if (m != HareketModu.values.first) const SizedBox(width: 8),
                      Expanded(
                        child: OyunDugme(
                          yukseklik: 48,
                          renk: m == HareketAyari.ornek.mod
                              ? Renk.lavanta
                              : Renk.kagit,
                          anlam: context.t('hareket_${m.name}'),
                          onTap: () async {
                            await HareketAyari.ornek.sec(m);
                            if (mounted) setState(() {});
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                context.t('hareket_${m.name}'),
                                style: Yazi.govde(boyut: 15, kalinlik: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('hareket_aciklama'),
                  style: Yazi.govde(boyut: 13, renk: Renk.soluk),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OyunPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _baslik(context.t('ses_dene')),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in SesTuru.values)
                      _kucukDugme(context.t('ses_${t.name}'), () => ses.cal(t)),
                    _kucukDugme(
                      context.t('titresim_dene'),
                      () => ses.titret(TitresimTuru.orta),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _baslik(context.t('muzik_dene')),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _kucukDugme(context.t('muzik_ana'), () => muzik.cal(MuzikTuru.ana)),
                    _kucukDugme(context.t('muzik_oyun'), () => muzik.cal(MuzikTuru.oyun)),
                    _kucukDugme(context.t('muzik_durdur'), () => muzik.durdur()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
