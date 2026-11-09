import 'dart:math';
import 'package:flutter/material.dart';

enum HayatEvresi { kucuk, cocuk, genc, yetiskin, yasli }

// Karakterin karar sonrası tepkisi
enum Tepki { yok, sevinc, uzuntu }

HayatEvresi evreBul(int yas) {
  if (yas < 8) return HayatEvresi.kucuk;
  if (yas < 13) return HayatEvresi.cocuk;
  if (yas < 19) return HayatEvresi.genc;
  if (yas < 60) return HayatEvresi.yetiskin;
  return HayatEvresi.yasli;
}

// Her sprite 12 sütun x 16 satırdır.
// . boş, H saç, W beyaz saç, S ten, E göz, C gömlek, P pantolon,
// B ayakkabı, K baston
const _kucuk = [
  '............',
  '............',
  '............',
  '............',
  '............',
  '....HHHH....',
  '...HHHHHH...',
  '...SSSSSS...',
  '...SESSES...',
  '...SSSSSS...',
  '....SSSS....',
  '...CCCCCC...',
  '..SCCCCCCS..',
  '...CCCCCC...',
  '...CC..CC...',
  '...SS..SS...',
];

const _cocuk = [
  '............',
  '............',
  '....HHHH....',
  '...HHHHHH...',
  '...HSSSSH...',
  '...SESSES...',
  '...SSSSSS...',
  '....SSSS....',
  '...CCCCCC...',
  '..SCCCCCCS..',
  '..SCCCCCCS..',
  '...CCCCCC...',
  '...PP..PP...',
  '...PP..PP...',
  '...PP..PP...',
  '..BBB..BBB..',
];

const _genc = [
  '....HHHH....',
  '...HHHHHH...',
  '...HSSSSH...',
  '...SESSES...',
  '...SSSSSS...',
  '....SSSS....',
  '..CCCCCCCC..',
  '.SCCCCCCCCS.',
  '.SCCCCCCCCS.',
  '.SCCCCCCCCS.',
  '..CCCCCCCC..',
  '...PPPPPP...',
  '...PP..PP...',
  '...PP..PP...',
  '...PP..PP...',
  '..BBB..BBB..',
];

const _yetiskin = [
  '...HHHHHH...',
  '..HHHHHHHH..',
  '..HHSSSSHH..',
  '...SESSES...',
  '...SSSSSS...',
  '....SSSS....',
  '..CCCCCCCC..',
  '.SCCCCCCCCS.',
  '.SCCCCCCCCS.',
  '.SCCCCCCCCS.',
  '..CCCCCCCC..',
  '...PPPPPP...',
  '...PP..PP...',
  '...PP..PP...',
  '...PP..PP...',
  '..BBB..BBB..',
];

const _yasli = [
  '............',
  '....WWWW....',
  '...WWWWWW...',
  '...WSSSSW...',
  '...SESSES...',
  '...SSSSSS...',
  '....SSSS....',
  '..CCCCCCCC..',
  '.SCCCCCCCCSK',
  '.SCCCCCCCCSK',
  '..CCCCCCCC.K',
  '...PPPPPP..K',
  '...PP..PP..K',
  '...PP..PP..K',
  '...PP..PP..K',
  '..BBB..BBB.K',
];

const _sprite = <HayatEvresi, List<String>>{
  HayatEvresi.kucuk: _kucuk,
  HayatEvresi.cocuk: _cocuk,
  HayatEvresi.genc: _genc,
  HayatEvresi.yetiskin: _yetiskin,
  HayatEvresi.yasli: _yasli,
};

class _PikselPainter extends CustomPainter {
  final List<String> satirlar;
  final Map<String, Color> palet;
  final double piksel;
  const _PikselPainter(this.satirlar, this.palet, this.piksel);

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()..isAntiAlias = false;
    for (var y = 0; y < satirlar.length; y++) {
      final satir = satirlar[y];
      for (var x = 0; x < satir.length; x++) {
        final renk = palet[satir[x]];
        if (renk == null) continue;
        firca.color = renk;
        canvas.drawRect(
          Rect.fromLTWH(x * piksel, y * piksel, piksel, piksel),
          firca,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PikselPainter old) => true;
}

// Tepki süsleri: sevinçte sarı pırıltılar, üzüntüde mavi damla
const _yildiz = ['.Y.', 'YYY', '.Y.'];
const _damla = ['.B', 'BB', 'BB'];

class _TepkiPainter extends CustomPainter {
  final Tepki tepki;
  final double t;
  final double p;
  const _TepkiPainter(this.tepki, this.t, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final firca = Paint()..isAntiAlias = false;
    void ciz(List<String> s, double x, double y, Color renk) {
      firca.color = renk;
      for (var r = 0; r < s.length; r++) {
        for (var c = 0; c < s[r].length; c++) {
          if (s[r][c] == '.') continue;
          canvas.drawRect(Rect.fromLTWH(x + c * p, y + r * p, p, p), firca);
        }
      }
    }

    if (tepki == Tepki.sevinc) {
      final alfa = sin(pi * t).clamp(0.0, 1.0).toDouble();
      final renk = const Color(0xFFFFD54F).withValues(alpha: alfa);
      final yukari = -(t * 3).round() * p;
      ciz(_yildiz, 0, 2 * p + yukari, renk);
      ciz(_yildiz, 9 * p, yukari, renk);
      ciz(_yildiz, 5 * p, -2 * p + yukari, renk);
    } else if (tepki == Tepki.uzuntu) {
      final alfa = (1 - t).clamp(0.0, 1.0).toDouble();
      final renk = const Color(0xFF64B5F6).withValues(alpha: alfa);
      final asagi = (t * 6).round() * p;
      ciz(_damla, 8 * p, 4 * p + asagi, renk);
    }
  }

  @override
  bool shouldRepaint(covariant _TepkiPainter old) =>
      old.t != t || old.tepki != tepki;
}

// Renk doygunluğunu azaltan matris (1: normal, 0: gri)
List<double> _doygunlukMatrisi(double s) {
  const r = 0.2126;
  const g = 0.7152;
  const b = 0.0722;
  return [
    r + (1 - r) * s, g - g * s, b - b * s, 0, 0,
    r - r * s, g + (1 - g) * s, b - b * s, 0, 0,
    r - r * s, g - g * s, b + (1 - b) * s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

class PikselKarakter extends StatefulWidget {
  final int yas;
  final Color ten;
  final Color gomlek;
  final double piksel;
  final Tepki tepki;
  final int tepkiNo; // her kararda artar; tepkiyi yeniden başlatır
  const PikselKarakter({
    required this.yas,
    required this.ten,
    required this.gomlek,
    this.piksel = 8,
    this.tepki = Tepki.yok,
    this.tepkiNo = 0,
    super.key,
  });

  @override
  State<PikselKarakter> createState() => _PikselKarakterState();
}

class _PikselKarakterState extends State<PikselKarakter>
    with TickerProviderStateMixin {
  late final AnimationController _nefes;
  late final AnimationController _tepki;

  @override
  void initState() {
    super.initState();
    _nefes = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _tepki = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant PikselKarakter old) {
    super.didUpdateWidget(old);
    if (widget.tepkiNo != old.tepkiNo && widget.tepki != Tepki.yok) {
      _tepki.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _nefes.dispose();
    _tepki.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.piksel;
    final evre = evreBul(widget.yas);
    final palet = <String, Color>{
      'H': const Color(0xFF5B3A29),
      'W': const Color(0xFFBDBDBD),
      'S': widget.ten,
      'E': const Color(0xFF222222),
      'C': widget.gomlek,
      'P': const Color(0xFF37474F),
      'B': const Color(0xFF3E2723),
      'K': const Color(0xFF8D6E63),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12 * p,
          height: 16 * p,
          child: AnimatedBuilder(
            animation: Listenable.merge([_nefes, _tepki]),
            builder: (context, _) {
              final t = _tepki.value;
              final aktif = widget.tepki != Tepki.yok && _tepki.isAnimating;
              var dy = _nefes.value > 0.5 ? -p : 0.0;
              var doygunluk = 1.0;
              if (aktif && widget.tepki == Tepki.sevinc) {
                // iki zıplama, tam piksel adımlarıyla
                dy = -(sin(t * 2 * pi).abs() * 3).round() * p;
              } else if (aktif && widget.tepki == Tepki.uzuntu) {
                final d = sin(t * pi);
                dy = (d * 1.2).round() * p;
                doygunluk = 1 - 0.8 * d;
              }
              Widget karakter = AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: CustomPaint(
                  key: ValueKey(evre),
                  size: Size(12 * p, 16 * p),
                  painter: _PikselPainter(_sprite[evre]!, palet, p),
                ),
              );
              if (doygunluk < 1) {
                karakter = ColorFiltered(
                  colorFilter: ColorFilter.matrix(_doygunlukMatrisi(doygunluk)),
                  child: karakter,
                );
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, dy),
                      child: karakter,
                    ),
                  ),
                  if (aktif)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TepkiPainter(widget.tepki, t, p),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 12 * p, height: p / 2, color: Colors.black12),
      ],
    );
  }
}