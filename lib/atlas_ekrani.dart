import 'package:flutter/material.dart';
import 'atlas.dart';
import 'dil.dart';
import 'ulke.dart';
import 'ulke_adlari.dart';

// Yalnızca görüntülenen atlas: ülkeye dokununca oyun başlamaz
class AtlasEkrani extends StatefulWidget {
  const AtlasEkrani({super.key});

  @override
  State<AtlasEkrani> createState() => _AtlasEkraniState();
}

class _AtlasEkraniState extends State<AtlasEkrani> {
  late Future<List<Ulke>> _ulkeler;
  AtlasDurumu _atlas = const AtlasDurumu({}, {});
  String _arama = '';

  @override
  void initState() {
    super.initState();
    _ulkeler = ulkeleriYukle();
    atlasOku().then((a) {
      if (mounted) setState(() => _atlas = a);
    });
  }

  Icon _durumIkonu(String kod) {
    if (_atlas.tamamMi(kod)) return const Icon(Icons.check_circle);
    if (_atlas.denendiMi(kod)) return const Icon(Icons.adjust);
    return const Icon(Icons.circle_outlined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('atlas'))),
      body: FutureBuilder<List<Ulke>>(
        future: _ulkeler,
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
          final dil = context.yerel.kod;
          final ulkeler = snap.data!;
          final aranan = aramaMetni(_arama);
          final sirali = [...ulkeler]..sort(
              (a, b) => aramaMetni(a.adi(dil)).compareTo(aramaMetni(b.adi(dil))),
            );
          final liste = sirali
              .where(
                (u) =>
                    aramaMetni(u.ad).contains(aranan) ||
                    aramaMetni(u.adEn).contains(aranan),
              )
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  context.t('atlas_sayac', {
                    'n': _atlas.tamamSayisi,
                    'm': ulkeler.length,
                  }),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  context.t('atlas_aciklama'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.t('ulke_ara'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _arama = v),
                ),
              ),
              Expanded(
                child: liste.isEmpty
                    ? Center(child: Text(context.t('ulke_yok')))
                    : ListView.builder(
                        itemCount: liste.length,
                        itemBuilder: (context, i) {
                          final u = liste[i];
                          return ListTile(
                            leading: _durumIkonu(u.kod),
                            title: Text(u.adi(dil)),
                            subtitle: Text(
                              context.t('omur_alt', {'omur': u.omur}),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}