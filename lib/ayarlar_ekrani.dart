import 'package:flutter/material.dart';
import 'dil.dart';
import 'muzik.dart';
import 'oyuncak.dart';
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

  @override
  Widget build(BuildContext context) {
    final yerel = context.yerel;
    const baslik = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('ayarlar'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(context.t('dil'), style: baslik),
          const SizedBox(height: 12),
          for (final d in desteklenenDiller)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => yerel.dilSec(d.kod),
                child: OyuncakKart(
                  renk: d.kod == yerel.kod ? Renk.lavanta : Renk.kagit,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.ad,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (d.kod == yerel.kod) const Icon(Icons.check),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(context.t('ses_baslik'), style: baslik),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.t('ses_efekt')),
            value: ses.sesAcik,
            onChanged: (v) async {
              await ses.sesAyarla(v);
              setState(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.t('muzik')),
            value: muzik.acik,
            onChanged: (v) async {
              await muzik.ayarla(v);
              setState(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.t('titresim')),
            value: ses.titresimAcik,
            onChanged: (v) async {
              await ses.titresimAyarla(v);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Text(context.t('ses_dene'), style: baslik),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in SesTuru.values)
                ElevatedButton(
                  onPressed: () => ses.cal(t),
                  child: Text(context.t('ses_${t.name}')),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ses.titret(TitresimTuru.orta),
            child: Text(context.t('titresim_dene')),
          ),
          const SizedBox(height: 24),
          Text(context.t('muzik_dene'), style: baslik),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => muzik.cal(MuzikTuru.ana),
                child: Text(context.t('muzik_ana')),
              ),
              ElevatedButton(
                onPressed: () => muzik.cal(MuzikTuru.oyun),
                child: Text(context.t('muzik_oyun')),
              ),
              ElevatedButton(
                onPressed: () => muzik.durdur(),
                child: Text(context.t('muzik_durdur')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}