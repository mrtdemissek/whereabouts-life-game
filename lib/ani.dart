import 'package:flutter/widgets.dart';

// Hayat albümüne girecek bir an. yazi, gösterim anında seçili dilde
// metni üretir. oncelik büyükse albümde yer bulma şansı yüksektir.
class Ani {
  final int yas;
  final int oncelik; // 3 doğum, 2 hedef/olay/zincir, 1 dönüm noktası
  final String Function(BuildContext) yazi;
  const Ani(this.yas, this.oncelik, this.yazi);
}

// Albüm için en fazla [adet] anı seçer: doğum her zaman girer, sonra
// önceliği yüksek olanlar; sonuç yaşa göre sıralanır.
List<Ani> albumSec(List<Ani> anilar, {int adet = 6}) {
  final sirali = [...anilar]..sort((a, b) {
      final o = b.oncelik.compareTo(a.oncelik);
      return o != 0 ? o : a.yas.compareTo(b.yas);
    });
  final secilen = sirali.take(adet).toList()
    ..sort((a, b) => a.yas.compareTo(b.yas));
  return secilen;
}

// Bir sonuç cümlesinin yalnızca ilk cümlesi (polaroid altına sığsın)
String ilkCumle(String s) {
  final i = s.indexOf('. ');
  return i > 0 ? s.substring(0, i + 1) : s;
}
