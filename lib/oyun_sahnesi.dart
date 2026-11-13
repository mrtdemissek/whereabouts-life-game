import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'piksel_karakter.dart';
import 'tema.dart';

// Tam ekran, soluk renkli arka plan + dönen yarım dünya + üstünde zıplayan
// karakter + karakterin üstünde konuşma balonu.
class OyunSahnesi extends StatefulWidget {
  final int yas;
  final Color ten;
  final Color gomlek;
  final Tepki tepki;
  final int tepkiNo;
  final bool bitti;
  final String? balon; // sonuç cümlesi
  final String? altYazi; // "+2 yıl geçti" / dönüm noktası
  final int balonNo; // her kararda artar; balonu yeniden gösterir
  final double tepeOrani; // dünyanın tepesi sahne yüksekliğinin kaçta kaçında
  final double ustBosluk; // balonun üstte bırakacağı boşluk (ölçüler için)
  const OyunSahnesi({
    required this.yas,
    required this.ten,
    required this.gomlek,
    this.tepki = Tepki.yok,
    this.tepkiNo = 0,
    this.bitti = false,
    this.balon,
    this.altYazi,
    this.balonNo = 0,
    this.tepeOrani = 0.70,
    this.ustBosluk = 4,
    super.key,
  });

  @override
  State<OyunSahnesi> createState() => _OyunSahnesiState();
}

class _OyunSahnesiState extends State<OyunSahnesi>
    with TickerProviderStateMixin {
  late final AnimationController _donus = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
  )..repeat();
  late final AnimationController _bulutlar = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
  )..repeat();
  late final AnimationController _yildiz = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  late final AnimationController _balon = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.balon != null) _balon.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant OyunSahnesi old) {
    super.didUpdateWidget(old);
    if (widget.balonNo != old.balonNo && widget.balon != null) {
      _balon.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _donus.dispose();
    _bulutlar.dispose();
    _yildiz.dispose();
    _balon.dispose();
    super.dispose();
  }

  static (Color, Color, Color) _renkler(HayatEvresi e) => switch (e) {
        HayatEvresi.kucuk => (
            const Color(0xFFD6EEFA),
            const Color(0xFFF4FBFF),
            const Color(0xFFBDEBD6)
          ),
        HayatEvresi.cocuk => (
            const Color(0xFFCBEAF8),
            const Color(0xFFFFF6E9),
            const Color(0xFFBDEBD6)
          ),
        HayatEvresi.genc => (
            const Color(0xFFD2EEF3),
            const Color(0xFFEEF9F2),
            const Color(0xFFB5E6C9)
          ),
        HayatEvresi.yetiskin => (
            const Color(0xFFFFEFCF),
            const Color(0xFFFFF8EE),
            const Color(0xFFD6EBC0)
          ),
        HayatEvresi.yasli => (
            const Color(0xFFFFDCE8),
            const Color(0xFFFFEBD0),
            const Color(0xFFD7C6EE)
          ),
      };

  @override
  Widget build(BuildContext context) {
    final evre = evreBul(widget.yas);
    final (ust, alt, _) = _renkler(evre);
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final r = w * 0.525;
      // dünyanın tepesi sahnenin ~%70'inde; kalan kısım ekran altına taşar
      final tepeY = h * widget.tepeOrani;
      final piksel = ((tepeY - widget.ustBosluk - 70) / 16).clamp(3.0, 7.0);
      final karakterH = 16 * piksel;
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // gökyüzü
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ust, alt],
                ),
              ),
            ),
          ),
          // piksel manzara: güneş, tepeler, ağaçlar, çiçekler
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: CustomPaint(
                key: ValueKey(evre),
                size: Size.infinite,
                painter: _ManzaraPainter(
                  evre,
                  ustSatir: (widget.ustBosluk / _u).round(),
                ),
              ),
            ),
          ),
          // bulutlar
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
              animation: _bulutlar,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _BulutPainter(
                  _bulutlar.value,
                  (widget.ustBosluk / _u).round(),
                ),
              ),
            ),
            ),
          ),
          // dönen yarım dünya (yalnızca görünen üst kısmı çizilir)
          Positioned(
            left: w / 2 - r,
            top: tepeY,
            width: r * 2,
            height: h - tepeY + 12,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _donus,
                // ~8 kare/sn: piksel küre için yeterli, işlemciyi rahatlatır
                builder: (context, _) => CustomPaint(
                  painter: _DunyaPainter(
                    (_donus.value * 720).floor() / 720,
                    evre,
                  ),
                ),
              ),
            ),
          ),
          // karakter
          Positioned(
            left: 0,
            right: 0,
            top: tepeY - karakterH + piksel,
            child: Center(
              child: Opacity(
                opacity: widget.bitti ? 0.5 : 1,
                child: PikselKarakter(
                  yas: widget.yas,
                  ten: widget.ten,
                  gomlek: widget.gomlek,
                  piksel: piksel,
                  tepki: widget.tepki,
                  tepkiNo: widget.tepkiNo,
                ),
              ),
            ),
          ),
          // konuşma balonu
          if (widget.balon != null)
            Positioned(
              left: 12,
              right: 12,
              top: widget.ustBosluk,
              height: max(0.0, tepeY - karakterH - 6 - widget.ustBosluk),
              child: AnimatedBuilder(
                animation: _balon,
                builder: (context, _) {
                  final t = _balon.value;
                  final o = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2);
                  return Opacity(
                    opacity: o.clamp(0.0, 1.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _Balon(
                        metin: widget.balon!,
                        altYazi: widget.altYazi,
                      ),
                    ),
                  );
                },
              ),
            ),
          // yaşam sonu: gökyüzü kararır, yıldızlar ve ay çıkar
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.bitti ? 0.85 : 0.0,
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeInOut,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1F1D3A), Color(0xFF4B3F72)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.bitti ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1800),
                child: AnimatedBuilder(
                  animation: _yildiz,
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: _YildizPainter(
                      _yildiz.value,
                      (widget.ustBosluk / _u).round(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Balon extends StatelessWidget {
  final String metin;
  final String? altYazi;
  const _Balon({required this.metin, this.altYazi});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Renk.murekkep, width: 2.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  metin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: Renk.murekkep,
                  ),
                ),
              ),
            ),
          ),
        ),
        // balon kuyruğu
        CustomPaint(size: const Size(16, 8), painter: _KuyrukPainter()),
        if (altYazi != null && altYazi!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              altYazi!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Renk.murekkep.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

class _KuyrukPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width / 2, s.height)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    final k = Paint()
      ..color = Renk.murekkep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset.zero, Offset(s.width / 2, s.height), k);
    canvas.drawLine(Offset(s.width, 0), Offset(s.width / 2, s.height), k);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Dünyanın yüzeyindeki nesneler: a ağaç, c çiçek, d dağ, f fidan
const _ogeler = [
  'a', 'c', 'd', 'f', 'c', 'a', 'c', 'f', 'd', 'c',
  'a', 'f', 'c', 'd', 'c', 'a', 'c', 'f', 'd', 'c',
];

const _dag = [
  '......s......',
  '.....sMs.....',
  '....MMMMM....',
  '...MMMMMMM...',
  '..MMMMMMMMM..',
  '.MMMMMMMMMMM.',
  'MMMMMMMMMMMMM',
];

const _dagPaleti = <String, Color>{
  'M': Color(0xFFB09CDB),
  's': Color(0xFFFFFFFF),
};

// Piksel küre: üç tonlu gölgeli, gerçek 3B dönen yüzeyli gezegen. Ağaç, çiçek
// ve dağlar siluet kenarına dikili, gezegenle birlikte döner.
class _Kure {
  final double r;
  final double yuk;
  final int satir;
  final int kolon;
  final Float32List xs;
  final Float32List ys;
  final Float32List zs;
  final Uint8List tur; // 0 dışarı, 1 yüzey, 2 kenar
  final Uint8List bant; // 0 koyu, 1 orta, 2 açık
  _Kure(this.r, this.yuk, this.satir, this.kolon, this.xs, this.ys, this.zs,
      this.tur, this.bant);
}

class _DunyaPainter extends CustomPainter {
  final double t;
  final HayatEvresi evre;
  _DunyaPainter(this.t, this.evre);

  static const double _hucre = 5; // küre pikselinin boyutu
  static const double _egim = -0.6; // dönme ekseninin izleyiciye eğimi

  @override
  void paint(Canvas canvas, Size s) {
    final r = s.width / 2;
    final (_, _, yakin) = _manzaraRenk(evre);
    final cimen = Color.lerp(const Color(0xFF8BD0A4), yakin, 0.25)!;
    final orman = Color.lerp(cimen, const Color(0xFF3F9462), 0.55)!;
    const su = Color(0xFF96CDEE);
    Color ton(Color c, int bant) => switch (bant) {
          2 => Color.lerp(c, Colors.white, 0.28)!,
          1 => c,
          _ => Color.lerp(c, const Color(0xFF3F3A5C), 0.38)!,
        };

    final don = t * 2 * pi;
    final firca = Paint()..isAntiAlias = false;

    // 1) kenardaki nesneler: kürenin arkasından çizilir, böylece yüzeye gömülü durur
    final buyuk = evre != HayatEvresi.kucuk && evre != HayatEvresi.cocuk;
    final agacP = _agacPaleti(evre == HayatEvresi.yasli);
    final n = _ogeler.length;

    // Her sprite sütunu, kürenin o noktadaki yüzeyine oturur
    void ciz(List<String> sp, Map<String, Color> p, double u, double cx) {
      final w = sp.fold<int>(0, (m, x) => max(m, x.length));
      for (var col = 0; col < w; col++) {
        final xx = cx + (col - w / 2) * u;
        final dx = (xx - r).clamp(-r * 0.98, r * 0.98);
        final yuzey = r - sqrt(r * r - dx * dx) + 6; // 6 px gömülü
        for (var row = 0; row < sp.length; row++) {
          if (col >= sp[row].length) continue;
          final renk = p[sp[row][col]];
          if (renk == null) continue;
          firca.color = renk;
          canvas.drawRect(
            Rect.fromLTWH(xx, yuzey - (sp.length - row) * u, u, u),
            firca,
          );
        }
      }
    }

    for (var i = 0; i < n; i++) {
      final a = don * 0.9 + i * 2 * pi / n;
      if (cos(a) < 0.6) continue; // yalnızca üstte görünenler
      final cx = r + r * sin(a);
      switch (_ogeler[i]) {
        case 'a':
          ciz(buyuk ? _agac : _fidan, agacP, buyuk ? 8 : 7, cx);
        case 'f':
          ciz(_fidan, agacP, 7, cx);
        case 'c':
          ciz(_cicek, _cicekPaleti, 6, cx);
        case 'd':
          ciz(_dag, _dagPaleti, 8, cx);
      }
    }

    // 2) küre: ışık/gölge önceden hesaplanır, kare başına yalnızca doku
    final k = _kure(r, s.height);
    final cd = cos(don);
    final sd = sin(don);
    final ct = cos(_egim);
    final st = sin(_egim);
    final kolon = k.kolon;
    // su, orman, çimen x (koyu, orta, açık) renkleri bir kez hazırlanır
    final renkler = [
      for (final c in [su, orman, cimen])
        for (var b = 0; b < 3; b++) ton(c, b),
    ];
    for (var row = 0; row < k.satir; row++) {
      for (var col = 0; col < kolon; col++) {
        final i = row * kolon + col;
        final tur = k.tur[i];
        if (tur == 0) continue;
        if (tur == 2) {
          firca.color = Renk.murekkep;
        } else {
          final x = k.xs[i];
          final y = k.ys[i];
          final z = k.zs[i];
          // görünümden gezegen uzayına: önce eğimi, sonra dönüşü geri al
          final y1 = y * ct + z * st;
          final z1 = -y * st + z * ct;
          final x0 = x * cd - z1 * sd;
          final z0 = x * sd + z1 * cd;
          final v = sin(x0 * 4.2 + 1) * sin(y1 * 3.6 + 2) +
              sin(z0 * 3.8 + 0.5) * sin(x0 * 2.2 + y1 * 2.9) +
              0.5 * sin(y1 * 7 + z0 * 5);
          final b = v < -0.55 ? 0 : (v > 0.85 ? 3 : 6);
          firca.color = renkler[b + k.bant[i]];
        }
        canvas.drawRect(
          Rect.fromLTWH(col * _hucre, row * _hucre, _hucre, _hucre),
          firca,
        );
      }
    }
  }

  // Kürenin değişmeyen kısmı (konum, ışık bandı, kenar): bir kez hesaplanır
  static _Kure? _onbellek;

  static _Kure _kure(double r, double yuk) {
    final eski = _onbellek;
    if (eski != null && eski.r == r && eski.yuk == yuk) return eski;
    final satir = (yuk / _hucre).ceil();
    final kolon = (2 * r / _hucre).ceil();
    final n = satir * kolon;
    final k = _Kure(
      r, yuk, satir, kolon,
      Float32List(n), Float32List(n), Float32List(n),
      Uint8List(n), Uint8List(n),
    );
    const isik = (-0.45, -0.55, 0.70);
    for (var row = 0; row < satir; row++) {
      final py = (row + 0.5) * _hucre - r;
      for (var col = 0; col < kolon; col++) {
        final px = (col + 0.5) * _hucre - r;
        final x = px / r;
        final y = py / r;
        final d2 = x * x + y * y;
        final i = row * kolon + col;
        if (d2 > 1) continue; // tur 0: küre dışı
        if (sqrt(d2) > 1 - 1.15 * _hucre / r) {
          k.tur[i] = 2; // kenar çizgisi
          continue;
        }
        final z = sqrt(1 - d2);
        final lam = x * isik.$1 + y * isik.$2 + z * isik.$3;
        k.tur[i] = 1;
        k.xs[i] = x;
        k.ys[i] = y;
        k.zs[i] = z;
        k.bant[i] = lam > 0.62 ? 2 : (lam > 0.2 ? 1 : 0);
      }
    }
    return _onbellek = k;
  }

  @override
  bool shouldRepaint(covariant _DunyaPainter old) =>
      old.t != t || old.evre != evre;
}

// ---------------- piksel manzara ----------------
const double _u = 8; // bir piksel bloğunun boyutu

Color _soluk(Color c) => Color.lerp(c, Colors.white, 0.25)!;

// (güneş, uzak tepe, yakın tepe)
(Color, Color, Color) _manzaraRenk(HayatEvresi e) => switch (e) {
      HayatEvresi.kucuk => (
          const Color(0xFFFFE680),
          const Color(0xFFBDEBD6),
          const Color(0xFF9EDDB5)
        ),
      HayatEvresi.cocuk => (
          const Color(0xFFFFE680),
          const Color(0xFFBDEBD6),
          const Color(0xFF9EDDB5)
        ),
      HayatEvresi.genc => (
          const Color(0xFFFFD966),
          const Color(0xFFB5E6C9),
          const Color(0xFF8FD6A8)
        ),
      HayatEvresi.yetiskin => (
          const Color(0xFFFFD27F),
          const Color(0xFFD6EBC0),
          const Color(0xFFA9D98C)
        ),
      HayatEvresi.yasli => (
          const Color(0xFFFFA97A),
          const Color(0xFFD7C6EE),
          const Color(0xFFC3B1E8)
        ),
    };

const _fidan = ['..l..', '.lLl.', '..L..', '..T..', '..T..', '..T..'];

const _agac = [
  '..lLLLl..',
  '.lLLLLLl.',
  'lLLLLLLLl',
  'lLLLLLLLl',
  '.lLLLLLl.',
  '..LLLLL..',
  '....T....',
  '....T....',
  '....T....',
  '....T....',
];

const _cicek = ['.p.', 'pYp', '.p.', '.G.'];

const _bulut = [
  '...XXX...',
  '.XXXXXXX.',
  'XXXXXXXXX',
  '.XXXXXXX.',
];

Map<String, Color> _agacPaleti(bool sonbahar) => {
      'L': sonbahar ? const Color(0xFFE8803F) : const Color(0xFF3FA66B),
      'l': sonbahar ? const Color(0xFFFFB066) : const Color(0xFF7ED69A),
      'T': const Color(0xFF8A5A3C),
    };

const _cicekPaleti = <String, Color>{
  'p': Color(0xFFFF7FAE),
  'Y': Color(0xFFFFD84D),
  'G': Color(0xFF3FA66B),
};

class _ManzaraPainter extends CustomPainter {
  final HayatEvresi evre;
  final int ustSatir; // güneşin altına inmemesi gereken üst boşluk (satır)
  const _ManzaraPainter(this.evre, {required this.ustSatir});

  @override
  void paint(Canvas canvas, Size size) {
    final (gunes, _, _) = _manzaraRenk(evre);
    final kolon = (size.width / _u).ceil();
    final firca = Paint()..isAntiAlias = false;

    void kare(int x, int y, Color c) {
      firca.color = c;
      canvas.drawRect(Rect.fromLTWH(x * _u, y * _u, _u, _u), firca);
    }

    // Güneş (ölçülerin hemen altında, sağda)
    final gx = kolon - 5;
    final gy = ustSatir + (evre == HayatEvresi.yasli ? 7 : 4);
    for (var dy = -3; dy <= 3; dy++) {
      for (var dx = -3; dx <= 3; dx++) {
        if (dx * dx + dy * dy <= 9) kare(gx + dx, gy + dy, _soluk(gunes));
      }
    }

  }

  @override
  bool shouldRepaint(covariant _ManzaraPainter old) =>
      old.evre != evre || old.ustSatir != ustSatir;
}

class _BulutPainter extends CustomPainter {
  final double t;
  final int ustSatir;
  const _BulutPainter(this.t, this.ustSatir);

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()
      ..isAntiAlias = false
      ..color = const Color(0xE6FFFFFF);
    final genislik = _bulut[0].length * _u;
    final yol = size.width + genislik;
    const baslar = [0.05, 0.40, 0.75];
    const satirlar = [2, 8, 5];
    for (var i = 0; i < baslar.length; i++) {
      final xx = ((baslar[i] + t) % 1.0) * yol - genislik;
      final x = (xx / _u).floorToDouble() * _u;
      final y = (ustSatir + satirlar[i]) * _u;
      for (var r = 0; r < _bulut.length; r++) {
        for (var c = 0; c < _bulut[r].length; c++) {
          if (_bulut[r][c] == 'X') {
            canvas.drawRect(
              Rect.fromLTWH(x + c * _u, y + r * _u, _u, _u),
              firca,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BulutPainter old) => old.t != t;
}

// Hayat sonu gecesi: pırıldayan piksel yıldızlar ve bir ay
class _YildizPainter extends CustomPainter {
  final double t;
  final int ustSatir;
  const _YildizPainter(this.t, this.ustSatir);

  static const _yildizlar = <(double, double, double)>[
    (0.08, 0.20, 0.0),
    (0.20, 0.30, 0.3),
    (0.33, 0.18, 0.6),
    (0.45, 0.34, 0.1),
    (0.55, 0.22, 0.8),
    (0.68, 0.32, 0.4),
    (0.78, 0.16, 0.9),
    (0.90, 0.28, 0.2),
    (0.15, 0.42, 0.5),
    (0.40, 0.44, 0.7),
    (0.62, 0.40, 0.15),
    (0.85, 0.43, 0.55),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()..isAntiAlias = false;
    const b = _u / 2;
    for (final y in _yildizlar) {
      final alfa = 0.35 + 0.65 * sin(2 * pi * (t + y.$3)).abs();
      firca.color = const Color(0xFFFFF3C4).withValues(alpha: alfa);
      final x = (size.width * y.$1 / b).floorToDouble() * b;
      final yy = (size.height * y.$2 / b).floorToDouble() * b;
      canvas.drawRect(Rect.fromLTWH(x, yy, b, b), firca);
    }
    firca.color = const Color(0xFFFFF3C4);
    final kolon = (size.width / _u).floor();
    final cx = kolon - 5;
    final cy = ustSatir + 4;
    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        if (dx * dx + dy * dy <= 5) {
          canvas.drawRect(
            Rect.fromLTWH((cx + dx) * _u, (cy + dy) * _u, _u, _u),
            firca,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _YildizPainter old) => old.t != t;
}
