import 'dart:math';
import 'package:flutter/material.dart';
import 'piksel_karakter.dart';
import 'tema.dart';

class _Gokyuzu {
  final Color ust;
  final Color alt;
  final Color gunes;
  final Color tepeUzak;
  final Color tepeYakin;
  const _Gokyuzu({
    required this.ust,
    required this.alt,
    required this.gunes,
    required this.tepeUzak,
    required this.tepeYakin,
  });
}

const _gokler = <HayatEvresi, _Gokyuzu>{
  HayatEvresi.kucuk: _Gokyuzu(
    ust: Color(0xFFBFE3F5),
    alt: Color(0xFFE8F6FF),
    gunes: Color(0xFFFFE680),
    tepeUzak: Color(0xFFBDEBD6),
    tepeYakin: Color(0xFF9EDDB5),
  ),
  HayatEvresi.cocuk: _Gokyuzu(
    ust: Color(0xFFAEE0F7),
    alt: Color(0xFFFFF6E9),
    gunes: Color(0xFFFFE680),
    tepeUzak: Color(0xFFBDEBD6),
    tepeYakin: Color(0xFF9EDDB5),
  ),
  HayatEvresi.genc: _Gokyuzu(
    ust: Color(0xFFB8E6F0),
    alt: Color(0xFFE6F7EC),
    gunes: Color(0xFFFFD966),
    tepeUzak: Color(0xFFB5E6C9),
    tepeYakin: Color(0xFF8FD6A8),
  ),
  HayatEvresi.yetiskin: _Gokyuzu(
    ust: Color(0xFFFFE9B8),
    alt: Color(0xFFFFF6E9),
    gunes: Color(0xFFFFD27F),
    tepeUzak: Color(0xFFD6EBC0),
    tepeYakin: Color(0xFFA9D98C),
  ),
  HayatEvresi.yasli: _Gokyuzu(
    ust: Color(0xFFFFC8DD),
    alt: Color(0xFFFFE3B8),
    gunes: Color(0xFFFFA97A),
    tepeUzak: Color(0xFFD7C6EE),
    tepeYakin: Color(0xFFC3B1E8),
  ),
};

// . boş, L koyu yaprak, l açık yaprak, T gövde
const _fidan = [
  '..l..',
  '.lLl.',
  '..L..',
  '..T..',
  '..T..',
  '..T..',
];

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

// p pembe, Y sarı, G sap
const _cicek = [
  '.p.',
  'pYp',
  '.p.',
  '.G.',
];

const _bulut = [
  '...XXX...',
  '.XXXXXXX.',
  'XXXXXXXXX',
  '.XXXXXXX.',
];

Map<String, Color> _agacPaleti(bool sonbahar) => {
      'L': sonbahar ? const Color(0xFFF59E6B) : const Color(0xFF5FBF86),
      'l': sonbahar ? const Color(0xFFFFC48F) : const Color(0xFF9BE0B8),
      'T': const Color(0xFFA67C5B),
    };

const _cicekPaleti = <String, Color>{
  'p': Color(0xFFFFA8C5),
  'Y': Color(0xFFFFE680),
  'G': Color(0xFF6FBF8A),
};

const double _u = 8; // bir piksel bloğunun boyutu

class _ManzaraPainter extends CustomPainter {
  final HayatEvresi evre;
  const _ManzaraPainter(this.evre);

  @override
  void paint(Canvas canvas, Size size) {
    final g = _gokler[evre]!;
    final kolon = (size.width / _u).ceil();
    final satir = (size.height / _u).ceil();
    final firca = Paint()..isAntiAlias = false;

    // Izgarayı alttan hizala
    canvas.translate(0, size.height - satir * _u);

    void kare(int x, int y, Color c) {
      firca.color = c;
      canvas.drawRect(Rect.fromLTWH(x * _u, y * _u, _u, _u), firca);
    }

    void sprite(List<String> s, int x0, int y0, Map<String, Color> p) {
      for (var r = 0; r < s.length; r++) {
        for (var c = 0; c < s[r].length; c++) {
          final renk = p[s[r][c]];
          if (renk != null) kare(x0 + c, y0 + r, renk);
        }
      }
    }

    final zemin = satir - 3; // ilk zemin satırı

    // Güneş
    final gx = kolon - 5;
    final gy = evre == HayatEvresi.yasli ? 9 : 4;
    for (var dy = -3; dy <= 3; dy++) {
      for (var dx = -3; dx <= 3; dx++) {
        if (dx * dx + dy * dy <= 9) kare(gx + dx, gy + dy, g.gunes);
      }
    }

    // Uzak tepeler
    for (var x = 0; x < kolon; x++) {
      final h = 7 + (sin(x * 0.30) * 2 + sin(x * 0.11 + 1.0) * 2).round();
      for (var y = zemin - h; y < zemin; y++) {
        kare(x, y, g.tepeUzak);
      }
    }

    // Yakın tepeler
    for (var x = 0; x < kolon; x++) {
      final h = 3 + (sin(x * 0.45 + 2) * 1.5 + sin(x * 0.2) * 1.5).round();
      for (var y = zemin - h; y < zemin; y++) {
        kare(x, y, g.tepeYakin);
      }
    }

    // Zemin: çimen, çimen, toprak
    for (var x = 0; x < kolon; x++) {
      kare(x, zemin, const Color(0xFF7BC89B));
      kare(x, zemin + 1, const Color(0xFF9EDDB5));
      kare(x, zemin + 2, const Color(0xFFF1D9B5));
    }

    // Ağaçlar
    final buyuk = evre != HayatEvresi.kucuk && evre != HayatEvresi.cocuk;
    final paleti = _agacPaleti(evre == HayatEvresi.yasli);
    final sol = buyuk ? _agac : _fidan;
    sprite(sol, 1, zemin - sol.length, paleti);
    if (evre == HayatEvresi.yetiskin || evre == HayatEvresi.yasli) {
      sprite(_agac, kolon - 10, zemin - _agac.length, paleti);
    }

    // Çiçekler
    final cx = kolon ~/ 2;
    sprite(_cicek, cx - 9, zemin - _cicek.length, _cicekPaleti);
    sprite(_cicek, cx + 7, zemin - _cicek.length, _cicekPaleti);
  }

  @override
  bool shouldRepaint(covariant _ManzaraPainter old) => old.evre != evre;
}

class _BulutPainter extends CustomPainter {
  final double t;
  const _BulutPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()
      ..isAntiAlias = false
      ..color = const Color(0xE6FFFFFF);
    final genislik = _bulut[0].length * _u;
    final yol = size.width + genislik;
    const baslar = [0.05, 0.40, 0.75];
    const satirlar = [1, 5, 3];
    for (var i = 0; i < baslar.length; i++) {
      final xx = ((baslar[i] + t) % 1.0) * yol - genislik;
      final x = (xx / _u).floorToDouble() * _u;
      final y = satirlar[i] * _u;
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
  const _YildizPainter(this.t);

  // (yatay oran, dikey oran, pırıltı fazı)
  static const _yildizlar = <(double, double, double)>[
    (0.08, 0.10, 0.0),
    (0.20, 0.25, 0.3),
    (0.33, 0.08, 0.6),
    (0.45, 0.30, 0.1),
    (0.55, 0.12, 0.8),
    (0.68, 0.28, 0.4),
    (0.78, 0.06, 0.9),
    (0.90, 0.22, 0.2),
    (0.15, 0.45, 0.5),
    (0.40, 0.50, 0.7),
    (0.62, 0.45, 0.15),
    (0.85, 0.48, 0.55),
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

    // Ay
    firca.color = const Color(0xFFFFF3C4);
    final kolon = (size.width / _u).floor();
    final cx = kolon - 5;
    const cy = 4;
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

class Sahne extends StatefulWidget {
  final int yas;
  final Color ten;
  final Color gomlek;
  final Tepki tepki;
  final int tepkiNo;
  final bool bitti; // hayat bitince sahne geceye döner
  const Sahne({
    required this.yas,
    required this.ten,
    required this.gomlek,
    this.tepki = Tepki.yok,
    this.tepkiNo = 0,
    this.bitti = false,
    super.key,
  });

  @override
  State<Sahne> createState() => _SahneState();
}

class _SahneState extends State<Sahne> with TickerProviderStateMixin {
  late final AnimationController _bulutlar;
  late final AnimationController _yildiz;

  @override
  void initState() {
    super.initState();
    _bulutlar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();
    _yildiz = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _bulutlar.dispose();
    _yildiz.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final evre = evreBul(widget.yas);
    final g = _gokler[evre]!;
    const gecesure = Duration(milliseconds: 1800);
    return Container(
      height: 224,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: Renk.murekkep, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [g.ust, g.alt],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: CustomPaint(
                key: ValueKey(evre),
                size: Size.infinite,
                painter: _ManzaraPainter(evre),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bulutlar,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _BulutPainter(_bulutlar.value),
              ),
            ),
          ),
          // Hayat sonu: gökyüzü kararır
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.bitti ? 0.85 : 0.0,
                duration: gecesure,
                curve: Curves.easeInOut,
                child: Container(
                  decoration: const BoxDecoration(
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
          // Hayat sonu: yıldızlar ve ay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.bitti ? 1.0 : 0.0,
                duration: gecesure,
                child: AnimatedBuilder(
                  animation: _yildiz,
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: _YildizPainter(_yildiz.value),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: AnimatedOpacity(
                opacity: widget.bitti ? 0.5 : 1.0,
                duration: gecesure,
                child: PikselKarakter(
                  yas: widget.yas,
                  ten: widget.ten,
                  gomlek: widget.gomlek,
                  tepki: widget.tepki,
                  tepkiNo: widget.tepkiNo,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}