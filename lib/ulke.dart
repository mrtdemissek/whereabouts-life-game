import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'ulke_adlari.dart';

// Bir ülkenin doğuşta beklenen yaşam süresi verisi
class Ulke {
  final String kod;
  final String ad; // Türkçe ad (yoksa İngilizce)
  final String adEn; // Dünya Bankası'ndan gelen İngilizce ad
  final int yil;
  final double omur;
  const Ulke({
    required this.kod,
    required this.ad,
    required this.adEn,
    required this.yil,
    required this.omur,
  });

  factory Ulke.fromJson(Map<String, dynamic> j) {
    final kod = j['kod'] as String;
    final en = j['ad'] as String;
    return Ulke(
      kod: kod,
      ad: trAdlar[kod] ?? en,
      adEn: en,
      yil: (j['yil'] as num).toInt(),
      omur: (j['omur'] as num).toDouble(),
    );
  }

  // Seçili dile göre görünen ad
  String adi(String dilKodu) => dilKodu == 'tr' ? ad : adEn;
}

// assets/ulkeler.json dosyasını okuyup Türkçe ada göre sıralı listeye çevirir
Future<List<Ulke>> ulkeleriYukle() async {
  final metin = await rootBundle.loadString('assets/ulkeler.json');
  final liste = jsonDecode(metin) as List<dynamic>;
  final ulkeler =
      liste.map((e) => Ulke.fromJson(e as Map<String, dynamic>)).toList();
  ulkeler.sort((a, b) => aramaMetni(a.ad).compareTo(aramaMetni(b.ad)));
  return ulkeler;
}