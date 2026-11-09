import 'package:flutter/material.dart';
import 'dil.dart';

class KaynaklarEkrani extends StatelessWidget {
  const KaynaklarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    const baslik = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('kaynaklar'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(context.t('kay_veri_baslik'), style: baslik),
          const SizedBox(height: 8),
          Text(context.t('kay_veri_metin')),
          const SizedBox(height: 8),
          const Text('data.worldbank.org/indicator/SP.DYN.LE00.IN'),
          const SizedBox(height: 24),
          Text(context.t('kay_risk_baslik'), style: baslik),
          const SizedBox(height: 8),
          Text(context.t('kay_risk_metin')),
          const SizedBox(height: 24),
          Text(context.t('kay_lisans_baslik'), style: baslik),
          const SizedBox(height: 8),
          Text(context.t('kay_lisans_metin')),
          const SizedBox(height: 8),
          const Text('creativecommons.org/licenses/by/4.0'),
          const SizedBox(height: 24),
          Text(context.t('kay_degisiklik_baslik'), style: baslik),
          const SizedBox(height: 8),
          Text(context.t('kay_degisiklik_metin')),
          const SizedBox(height: 24),
          Text(context.t('kay_not_baslik'), style: baslik),
          const SizedBox(height: 8),
          Text(context.t('kay_not_metin')),
        ],
      ),
    );
  }
}