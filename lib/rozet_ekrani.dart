import 'package:flutter/material.dart';
import 'dil.dart';
import 'rozet.dart';

class RozetEkrani extends StatelessWidget {
  const RozetEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('rozetler'))),
      body: FutureBuilder<Set<String>>(
        future: kazanilanRozetleriOku(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                context.t('veri_okunamadi', {'hata': '${snap.error}'}),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final kazanilan = snap.data!;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.t('rozet_sayac', {
                    'n': kazanilan.length,
                    'm': tumRozetler.length,
                  }),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              for (final r in tumRozetler)
                ListTile(
                  leading: Icon(
                    kazanilan.contains(r.id)
                        ? Icons.emoji_events
                        : Icons.lock_outline,
                  ),
                  title: Text(context.t('rozet_${r.id}_ad')),
                  subtitle: Text(context.t('rozet_${r.id}_acik')),
                ),
            ],
          );
        },
      ),
    );
  }
}