import 'package:flutter/material.dart';
import 'atlas.dart';
import 'dil.dart';
import 'hayat_karnesi.dart';
import 'oyun_ui.dart';
import 'rozet.dart';
import 'tema.dart';
import 'ulke.dart';
import 'ulke_adlari.dart';
import 'yildiz.dart';

// Atlas ve rozetler tek ekranda, sekmeyle. baslangic: 0 atlas, 1 rozetler
class KoleksiyonEkrani extends StatefulWidget {
  final int baslangic;
  const KoleksiyonEkrani({this.baslangic = 0, super.key});

  @override
  State<KoleksiyonEkrani> createState() => _KoleksiyonEkraniState();
}

class _KoleksiyonEkraniState extends State<KoleksiyonEkrani> {
  late int _sekme = widget.baslangic;
  late final Future<List<Ulke>> _ulkeler = ulkeleriYukle();
  AtlasDurumu _atlas = const AtlasDurumu({}, {});
  Map<String, int> _yildizlar = {};
  Set<String> _rozetler = {};
  String _arama = '';
  bool _yalnizYasanan = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final a = await atlasOku();
    final y = await enIyiYildizlariOku();
    final r = await kazanilanRozetleriOku();
    if (!mounted) return;
    setState(() {
      _atlas = a;
      _yildizlar = y;
      _rozetler = r;
    });
  }

  int get _toplamYildiz => _yildizlar.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(12, mq.padding.top + 8, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                  child: Text(
                    context.t('koleksiyon'),
                    style: Yazi.piksel(boyut: 26, kalinlik: FontWeight.w700),
                  ),
                ),
                OyunPanel(
                  golge: 0,
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                  yaricap: 10,
                  child: Row(
                    children: [
                      const PikselYildiz(dolu: true, boyut: 20),
                      const SizedBox(width: 6),
                      Text('$_toplamYildiz', style: Yazi.sayi(boyut: 17)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sekmeler(context),
            const SizedBox(height: 12),
            Expanded(
              child: _sekme == 0 ? _atlasSekmesi(context) : _rozetSekmesi(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sekmeler(BuildContext context) {
    Widget sekme(int i, String yazi) => Expanded(
          child: Semantics(
            selected: _sekme == i,
            button: true,
            child: GestureDetector(
              onTap: () => setState(() => _sekme = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _sekme == i ? Renk.kagit : Colors.transparent,
                  border: Border.all(
                    color: _sekme == i ? Renk.murekkep : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(yazi, style: Yazi.piksel(boyut: 17)),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DFF7),
        border: Border.all(color: Renk.murekkep, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          sekme(0, context.t('atlas')),
          const SizedBox(width: 4),
          sekme(1, context.t('rozetler')),
        ],
      ),
    );
  }

  // ---------------- Atlas ----------------
  Widget _atlasSekmesi(BuildContext context) {
    return FutureBuilder<List<Ulke>>(
      future: _ulkeler,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(context.t('veri_okunamadi', {'hata': '${snap.error}'})),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final dil = context.yerel.kod;
        final ulkeler = snap.data!;
        final aranan = aramaMetni(_arama);
        final liste = ([...ulkeler]
              ..sort((a, b) =>
                  aramaMetni(a.adi(dil)).compareTo(aramaMetni(b.adi(dil)))))
            .where((u) =>
                (aramaMetni(u.ad).contains(aranan) ||
                    aramaMetni(u.adEn).contains(aranan)) &&
                (!_yalnizYasanan || _atlas.denendiMi(u.kod)))
            .toList();
        final oran = ulkeler.isEmpty ? 0.0 : _atlas.yasananSayisi / ulkeler.length;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: OyunPanel(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.t('yasanan_ulkeler'),
                            style: Yazi.piksel(boyut: 16),
                          ),
                        ),
                        Text(
                          '${_atlas.yasananSayisi} / ${ulkeler.length}',
                          style: Yazi.sayi(boyut: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Renk.bos,
                        border: Border.all(color: Renk.murekkep, width: 2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: oran.clamp(0.0, 1.0),
                            child: Container(color: const Color(0xFF7ED69A)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t('atlas_aciklama'),
                      style: Yazi.govde(boyut: 13, renk: Renk.soluk),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: Yazi.govde(boyut: 15),
                        decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: const Icon(Icons.search),
                          hintText: context.t('ulke_ara'),
                          filled: true,
                          fillColor: Renk.kagit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Renk.murekkep, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Renk.murekkep, width: 2),
                          ),
                        ),
                        onChanged: (v) => setState(() => _arama = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(context.t('filtre_yasanan'), style: Yazi.piksel(boyut: 14)),
                      selected: _yalnizYasanan,
                      onSelected: (v) => setState(() => _yalnizYasanan = v),
                      selectedColor: Renk.limon,
                      backgroundColor: Renk.kagit,
                      side: const BorderSide(color: Renk.murekkep, width: 2),
                      showCheckmark: false,
                    ),
                  ],
                ),
              ),
            ),
            if (liste.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.t('ulke_yok'),
                    textAlign: TextAlign.center,
                    style: Yazi.govde(),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).padding.bottom),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 70,
                  ),
                  itemCount: liste.length,
                  itemBuilder: (context, i) => _UlkeKarti(
                    ad: liste[i].adi(dil),
                    yildiz: _yildizlar[liste[i].kod] ?? 0,
                    tamam: _atlas.tamamMi(liste[i].kod),
                    denendi: _atlas.denendiMi(liste[i].kod),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ---------------- Rozetler ----------------
  Widget _rozetSekmesi(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${context.t('rozetler')} · ', style: Yazi.piksel(boyut: 16)),
                  TextSpan(
                    text: '${_rozetler.length} / ${tumRozetler.length}',
                    style: Yazi.sayi(boyut: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final tur in RozetTuru.values) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                context.t('rozet_tur_${tur.name}'),
                style: Yazi.piksel(boyut: 15, renk: Renk.soluk),
              ),
            ),
          ),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              mainAxisExtent: 104,
            ),
            itemCount: tumRozetler.where((r) => r.tur == tur).length,
            itemBuilder: (context, i) {
              final r = tumRozetler.where((r) => r.tur == tur).elementAt(i);
              final kazanildi = _rozetler.contains(r.id);
              final gorunur = kazanildi || !r.gizli;
              return _RozetRafi(
                ad: gorunur
                    ? context.t('rozet_${r.id}_ad')
                    : context.t('rozet_gizli'),
                aciklama: gorunur
                    ? context.t('rozet_${r.id}_acik')
                    : context.t('rozet_gizli_acik'),
                kazanildi: kazanildi,
              );
            },
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              20,
              0,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: OyunPanel(
              renk: Renk.limon,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.checkroom, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.t('dolap'), style: Yazi.govde(boyut: 15, kalinlik: FontWeight.w800)),
                        Text(context.t('dolap_acik'), style: Yazi.govde(boyut: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Renk.kagit,
                      border: Border.all(color: Renk.murekkep, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(context.t('yakinda'), style: Yazi.piksel(boyut: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UlkeKarti extends StatelessWidget {
  final String ad;
  final int yildiz;
  final bool tamam;
  final bool denendi;
  const _UlkeKarti({
    required this.ad,
    required this.yildiz,
    required this.tamam,
    required this.denendi,
  });

  @override
  Widget build(BuildContext context) {
    final renk = tamam
        ? Renk.limon
        : denendi
            ? Renk.kagit
            : const Color(0xFFEDE7F5);
    return Semantics(
      label: '$ad, $yildiz/3',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: renk,
          border: Border.all(
            color: denendi ? Renk.murekkep : Renk.soluk,
            width: denendi ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Yazi.govde(
                boyut: 13,
                kalinlik: FontWeight.w800,
                renk: denendi ? Renk.murekkep : Renk.soluk,
              ),
            ),
            const SizedBox(height: 4),
            if (denendi)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: PikselYildiz(dolu: i < yildiz, boyut: 14),
                    ),
                ],
              )
            else
              Text('—', style: Yazi.govde(boyut: 13, renk: Renk.soluk)),
          ],
        ),
      ),
    );
  }
}

class _RozetRafi extends StatelessWidget {
  final String ad;
  final String aciklama;
  final bool kazanildi;
  const _RozetRafi({
    required this.ad,
    required this.aciklama,
    required this.kazanildi,
  });

  void _goster(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ad, style: Yazi.piksel(boyut: 20)),
        content: Text(
          kazanildi ? aciklama : '$aciklama\n\n${ctx.t('rozet_kazanilmadi')}',
          style: Yazi.govde(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: ad,
      child: GestureDetector(
        onTap: () => _goster(context),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kazanildi ? Renk.pembe : Renk.bos,
                border: Border.all(
                  color: kazanildi ? Renk.murekkep : Renk.soluk,
                  width: 3,
                ),
                boxShadow: kazanildi
                    ? const [
                        BoxShadow(
                          color: Renk.murekkep,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: kazanildi
                  ? const Icon(Icons.workspace_premium, size: 30)
                  : Text('?', style: Yazi.piksel(boyut: 24, renk: Renk.soluk)),
            ),
            const SizedBox(height: 6),
            Text(
              ad,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Yazi.govde(
                boyut: 12,
                kalinlik: FontWeight.w800,
                renk: kazanildi ? Renk.murekkep : Renk.soluk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
