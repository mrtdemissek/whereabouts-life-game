import 'package:flutter/material.dart';
import 'dil.dart';
import 'dolap.dart';
import 'hayat_karnesi.dart';
import 'oyun_sahnesi.dart';
import 'oyun_ui.dart';
import 'tema.dart';
import 'yildiz.dart';

// Kıyafet dolabı: kıyafet, saç ve dünya seçimi; yıldızla açılır
class DolapEkrani extends StatefulWidget {
  const DolapEkrani({super.key});

  @override
  State<DolapEkrani> createState() => _DolapEkraniState();
}

class _DolapEkraniState extends State<DolapEkrani> {
  int _yildiz = 0;

  @override
  void initState() {
    super.initState();
    toplamYildiz().then((y) {
      if (mounted) setState(() => _yildiz = y);
    });
  }

  Future<void> _sec(Kozmetik k) async {
    if (!acikMi(k, _yildiz)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('dolap_kilit', {'n': k.esik}))),
      );
      return;
    }
    await Dolap.ornek.sec(k);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final dolap = Dolap.ornek;
    return Scaffold(
      body: Column(
        children: [
          // Önizleme: seçili görünümle sahne
          SizedBox(
            height: 250 + mq.padding.top,
            child: Stack(
              children: [
                Positioned.fill(
                  child: OyunSahnesi(
                    key: ValueKey(
                      '${dolap.secili(KozmetikTuru.gomlek)}'
                      '${dolap.secili(KozmetikTuru.sac)}'
                      '${dolap.secili(KozmetikTuru.dunya)}',
                    ),
                    yas: 30,
                    ten: const Color(0xFFD9A066),
                    gomlek: dolap.gomlekRengi ?? const Color(0xFFEF6C00),
                    tepeOrani: 0.68,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, mq.padding.top + 8, 12, 0),
                  child: Row(
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
                          context.t('dolap'),
                          style: Yazi.piksel(boyut: 24, kalinlik: FontWeight.w700),
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
                            Text('$_yildiz', style: Yazi.sayi(boyut: 17)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 24 + mq.padding.bottom),
              children: [
                for (final tur in KozmetikTuru.values) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(
                      context.t('dolap_${tur.name}'),
                      style: Yazi.piksel(boyut: 17),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.05,
                    children: [
                      for (final k in kozmetiklerTuru(tur))
                        _KozmetikKutusu(
                          kozmetik: k,
                          acik: acikMi(k, _yildiz),
                          secili: dolap.secili(tur) == k.id,
                          onTap: () => _sec(k),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KozmetikKutusu extends StatelessWidget {
  final Kozmetik kozmetik;
  final bool acik;
  final bool secili;
  final VoidCallback onTap;
  const _KozmetikKutusu({
    required this.kozmetik,
    required this.acik,
    required this.secili,
    required this.onTap,
  });

  Widget _ornek() {
    final k = kozmetik;
    if (k.tur == KozmetikTuru.dunya) {
      final d = k.dunya ??
          const DunyaTemasi(Color(0xFF8BD0A4), Color(0xFF4F9E70), Color(0xFF96CDEE));
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Renk.murekkep, width: 2.5),
          gradient: SweepGradient(colors: [d.cimen, d.orman, d.su, d.cimen]),
        ),
      );
    }
    if (k.renk == null) {
      // Rastgele: dört küçük renk
      return SizedBox(
        width: 38,
        height: 38,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            ColoredBox(color: Color(0xFF3F51B5)),
            ColoredBox(color: Color(0xFF2E7D32)),
            ColoredBox(color: Color(0xFFC62828)),
            ColoredBox(color: Color(0xFFEF6C00)),
          ],
        ),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: k.renk,
        border: Border.all(color: Renk.murekkep, width: 2.5),
        borderRadius: BorderRadius.circular(k.tur == KozmetikTuru.sac ? 19 : 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: secili,
      label: context.t('kozmetik_${kozmetik.id}'),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: secili ? Renk.limon : (acik ? Renk.kagit : Renk.bos),
            border: Border.all(
              color: acik ? Renk.murekkep : Renk.soluk,
              width: secili ? 4 : 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(opacity: acik ? 1 : 0.45, child: _ornek()),
              const SizedBox(height: 6),
              Text(
                context.t('kozmetik_${kozmetik.id}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Yazi.govde(
                  boyut: 12,
                  kalinlik: FontWeight.w800,
                  renk: acik ? Renk.murekkep : Renk.soluk,
                ),
              ),
              if (!acik)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 12, color: Renk.soluk),
                    const SizedBox(width: 2),
                    Text('${kozmetik.esik}', style: Yazi.sayi(boyut: 12, renk: Renk.soluk)),
                    Text(' ★', style: Yazi.govde(boyut: 12, renk: Renk.soluk)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
