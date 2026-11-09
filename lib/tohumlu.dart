import 'dart:math';

/// Her platformda ayni sonucu veren tohumlu uretec.
/// Yalnizca + * % kullanir (web'de de tam hassasiyet).
class Tohumlu implements Random {
  static const int _m = 2147483647;
  static const int _a = 48271;
  static const int _p = 67108859;

  int _s;

  Tohumlu(int tohum) : _s = _baslat(tohum);

  static int _karistir(int x, int tuz) {
    var h = (x.abs() + tuz) % _p;
    for (var i = 0; i < 4; i++) {
      h = (h * h + 7919 * (i + 1) + tuz) % _p;
    }
    return h;
  }

  static int _baslat(int tohum) {
    final a = _karistir(tohum, 1);
    final b = _karistir(tohum ~/ _p, 2);
    return (a * 31 + b) % (_m - 1) + 1;
  }

  @override
  double nextDouble() {
    _s = (_s * _a) % _m;
    return (_s - 1) / (_m - 1);
  }

  @override
  int nextInt(int max) {
    if (max <= 0) throw RangeError.value(max, 'max');
    return (nextDouble() * max).floor();
  }

  @override
  bool nextBool() => nextDouble() < 0.5;
}