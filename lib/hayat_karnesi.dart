import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ani.dart';
import 'dil.dart';
import 'oyun_ui.dart';
import 'piksel_karakter.dart';
import 'rozet.dart';
import 'tema.dart';
import 'yildiz.dart';

// Hayat bitince gece gökyüzünde açılan "Hayat Karnesi":
// yıldızlar ve koşulları, rekor, hayat albümü, nasıl bittiği, yeni rozetler.
class HayatKarnesi extends StatelessWidget {
  final String ulkeAdi;
  final int olumYas;
  final int omur; // ülkenin beklenen yaşı
  final HayatYildizi? yildiz;
  final int oncekiEnIyi;
  final String hedefAd;
  final String dengeDetay; // ör. "para 29"; denge yıldızı yoksa neden
  final String mesaj; // nasıl bitti
  final List<Ani> album;
  final List<Rozet> yeniRozetler;
  final bool rozetleriGoster;
  final Color ten;
  final Color gomlek;
  final VoidCallback yenidenBasla;
  const HayatKarnesi({
    required this.ulkeAdi,
    required this.olumYas,
    required this.omur,
    required this.yildiz,
    required this.oncekiEnIyi,
    required this.hedefAd,
    required this.dengeDetay,
    required this.mesaj,
    required this.album,
    required this.yeniRozetler,
    required this.rozetleriGoster,
    required this.ten,
    required this.gomlek,
    required this.yenidenBasla,
    super.key,
  });

  void _paylas(BuildContext context) {
    final y = yildiz?.sayi ?? 0;
    final metin = context.t('karne_paylas_metni', {
      'ulke': ulkeAdi,
      'yas': olumYas,
      'n': y,
    });
    Clipboard.setData(ClipboardData(text: metin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t('karne_kopyalandi'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final y = yildiz;
    final alt = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 8, 18, 24 + alt),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$ulkeAdi · ', style: Yazi.piksel(boyut: 16, renk: const Color(0xFFC9BCF0))),
                TextSpan(
                  text: context.t('karne_yas', {'n': olumYas}),
                  style: Yazi.sayi(boyut: 16, renk: const Color(0xFFC9BCF0)),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            context.t('karne_baslik'),
            textAlign: TextAlign.center,
            style: Yazi.piksel(boyut: 34, kalinlik: FontWeight.w700, renk: Renk.kagit),
          ),
          const SizedBox(height: 14),
          if (y != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PikselYildiz(dolu: y.sayi >= 1, boyut: 60, gecikme: 300),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PikselYildiz(dolu: y.sayi >= 2, boyut: 72, gecikme: 650),
                ),
                const SizedBox(width: 12),
                PikselYildiz(dolu: y.sayi >= 3, boyut: 60, gecikme: 1000),
              ],
            ),
            const SizedBox(height: 14),
            OyunPanel(
              kenar: 4,
              golge: 6,
              yaricap: 14,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Kosul(
                    tamam: y.omur,
                    yazi: context.t('yildiz_omur'),
                    detay: '$olumYas / $omur',
                  ),
                  _Kosul(
                    tamam: y.hedef,
                    yazi: context.t('hedef_etiket', {'ad': hedefAd}),
                  ),
                  _Kosul(
                    tamam: y.denge,
                    yazi: context.t('yildiz_denge'),
                    detay: y.denge ? null : dengeDetay,
                  ),
                  const SizedBox(height: 6),
                  _rekorEtiketi(context, y),
                ],
              ),
            ),
          ],
          if (album.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              context.t('karne_album'),
              style: Yazi.piksel(boyut: 16, renk: Renk.kagit),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: album.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _Polaroid(
                  ani: album[i],
                  aci: i.isEven ? -0.045 : 0.035,
                  ten: ten,
                  gomlek: gomlek,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          OyunPanel(
            renk: const Color(0xFFEDE7FA),
            golge: 0,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('karne_nasil'), style: Yazi.piksel(boyut: 14)),
                const SizedBox(height: 4),
                Text(mesaj, style: Yazi.govde(boyut: 14, kalinlik: FontWeight.w700)),
              ],
            ),
          ),
          if (yeniRozetler.isNotEmpty && rozetleriGoster) ...[
            const SizedBox(height: 12),
            for (final r in yeniRozetler)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.0),
                  duration: Duration(
                    milliseconds:
                        MediaQuery.of(context).disableAnimations ? 400 : 800,
                  ),
                  curve: MediaQuery.of(context).disableAnimations
                      ? Curves.easeOut
                      : Curves.elasticOut,
                  // Azaltılmış harekette büyümez, yalnızca belirir
                  builder: (context, v, child) =>
                      MediaQuery.of(context).disableAnimations
                          ? Opacity(opacity: ((v - 0.5) * 2).clamp(0.0, 1.0), child: child)
                          : Transform.scale(scale: v, child: child),
                  child: OyunPanel(
                    renk: Renk.pembe,
                    golge: 0,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium, size: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t('yeni_rozet', {
                                  'ad': context.t('rozet_${r.id}_ad'),
                                }),
                                style: Yazi.govde(boyut: 15, kalinlik: FontWeight.w800),
                              ),
                              Text(
                                context.t('rozet_${r.id}_acik'),
                                style: Yazi.govde(boyut: 13, kalinlik: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OyunDugme(
                  yukseklik: 58,
                  onTap: () => _paylas(context),
                  child: Text(context.t('karne_paylas'), style: Yazi.piksel(boyut: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OyunDugme(
                  renk: Renk.mercan,
                  yukseklik: 58,
                  onTap: yenidenBasla,
                  child: Text(
                    '${context.t('yeni_hayat').toUpperCase()} ▶',
                    style: Yazi.piksel(boyut: 18, kalinlik: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rekorEtiketi(BuildContext context, HayatYildizi y) {
    final rekor = y.sayi > oncekiEnIyi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: rekor ? Renk.limon : Renk.bos,
        border: Border.all(color: Renk.murekkep, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text.rich(
        TextSpan(
          children: rekor
              ? [
                  TextSpan(text: '${context.t('yildiz_rekor')}  ', style: Yazi.piksel(boyut: 14)),
                  TextSpan(text: '+${y.sayi - oncekiEnIyi}', style: Yazi.sayi(boyut: 14)),
                  TextSpan(text: ' ★', style: Yazi.piksel(boyut: 14)),
                ]
              : [
                  TextSpan(
                    text: context.t('yildiz_onceki', {'n': oncekiEnIyi}),
                    style: Yazi.govde(boyut: 13, kalinlik: FontWeight.w800),
                  ),
                ],
        ),
      ),
    );
  }
}

class _Kosul extends StatelessWidget {
  final bool tamam;
  final String yazi;
  final String? detay;
  const _Kosul({required this.tamam, required this.yazi, this.detay});

  @override
  Widget build(BuildContext context) {
    final renk = tamam ? Renk.murekkep : Renk.soluk;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tamam ? Icons.check_box : Icons.close,
            size: 20,
            color: tamam ? Renk.artis : Renk.soluk,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: yazi, style: Yazi.govde(boyut: 15, kalinlik: FontWeight.w800, renk: renk)),
                  if (detay != null)
                    TextSpan(text: '  ($detay)', style: Yazi.sayi(boyut: 14, renk: renk)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Albümdeki bir an: o yaştaki gökyüzü ve karakter, altında kısa yazı
class _Polaroid extends StatelessWidget {
  final Ani ani;
  final double aci;
  final Color ten;
  final Color gomlek;
  const _Polaroid({
    required this.ani,
    required this.aci,
    required this.ten,
    required this.gomlek,
  });

  static const _gokler = {
    HayatEvresi.kucuk: [Color(0xFFBFE3F5), Color(0xFFE8F6FF)],
    HayatEvresi.cocuk: [Color(0xFFAEE0F7), Color(0xFFFFF6E9)],
    HayatEvresi.genc: [Color(0xFFB8E6F0), Color(0xFFE6F7EC)],
    HayatEvresi.yetiskin: [Color(0xFFFFE9B8), Color(0xFFFFF6E9)],
    HayatEvresi.yasli: [Color(0xFFFFC8DD), Color(0xFFFFE3B8)],
  };

  @override
  Widget build(BuildContext context) {
    final evre = evreBul(ani.yas);
    return Transform.rotate(
      angle: aci,
      child: Container(
        width: 112,
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
        decoration: BoxDecoration(
          color: Renk.kagit,
          border: Border.all(color: Renk.gece, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _gokler[evre]!,
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: PikselKarakter(
                  yas: ani.yas,
                  ten: ten,
                  gomlek: gomlek,
                  piksel: 3.5,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${ani.yas} · ', style: Yazi.sayi(boyut: 11)),
                  TextSpan(
                    text: ani.yazi(context),
                    style: Yazi.govde(boyut: 11, kalinlik: FontWeight.w800),
                  ),
                ],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Büyüyerek beliren piksel yıldız (boş ya da dolu)
class PikselYildiz extends StatefulWidget {
  final bool dolu;
  final double boyut;
  final int gecikme; // milisaniye
  const PikselYildiz({
    required this.dolu,
    this.boyut = 36,
    this.gecikme = 0,
    super.key,
  });

  @override
  State<PikselYildiz> createState() => _PikselYildizState();
}

class _PikselYildizState extends State<PikselYildiz> {
  bool _gorundu = false;

  @override
  void initState() {
    super.initState();
    if (widget.dolu) {
      Future.delayed(Duration(milliseconds: widget.gecikme), () {
        if (mounted) setState(() => _gorundu = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hareketsiz = MediaQuery.of(context).disableAnimations;
    // Yıldızlar her durumda sırayla dolar; azaltılmış harekette yalnızca zıplamaz
    final dolu = widget.dolu && _gorundu;
    final y = Semantics(
      label: widget.dolu ? '★' : '☆',
      child: CustomPaint(
        size: Size(widget.boyut, widget.boyut),
        painter: _YildizPainter(dolu),
      ),
    );
    if (!dolu || hareketsiz) return y;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: y,
    );
  }
}

const _yildizSprite = [
  '....O....',
  '...OYO...',
  '...OYO...',
  'OOOOYOOOO',
  'OYYYYYYYO',
  '.OYYYYYO.',
  '..OYYYO..',
  '.OYO.OYO.',
  'OO.....OO',
];

class _YildizPainter extends CustomPainter {
  final bool dolu;
  _YildizPainter(this.dolu);

  @override
  void paint(Canvas canvas, Size size) {
    final p = size.width / 9;
    final firca = Paint()..isAntiAlias = false;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final ch = _yildizSprite[r][c];
        if (ch == '.') continue;
        firca.color = ch == 'O'
            ? Renk.gece
            : (dolu ? Renk.altin : const Color(0xFF6E6496));
        canvas.drawRect(Rect.fromLTWH(c * p, r * p, p + 0.5, p + 0.5), firca);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _YildizPainter old) => old.dolu != dolu;
}
