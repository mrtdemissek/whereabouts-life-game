import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pastel oyuncak renk paleti
class Renk {
  static const krem = Color(0xFFFFF6E9); // arka plan
  static const kagit = Color(0xFFFFFDF7); // kartlar ve paneller
  static const murekkep = Color(0xFF3B2F4A); // metin, çerçeve, gölge
  static const lavanta = Color(0xFFB9A5EA); // ana vurgu
  static const nane = Color(0xFFBDEBD6);
  static const seftali = Color(0xFFFFD3B6);
  static const gokMavisi = Color(0xFFBFE3F5);
  static const pembe = Color(0xFFFFC8DD);
  static const limon = Color(0xFFFFE89A);
  static const mercan = Color(0xFFFF8A7A); // ana eylem düğmesi
  static const altin = Color(0xFFFFD84D); // yıldız
  static const bos = Color(0xFFE6E0EE); // boş çubuk dilimi
  static const soluk = Color(0xFF6B6280); // ikincil metin (kontrast 4.5:1+)
  static const gece = Color(0xFF1F1D3A);
  static const artis = Color(0xFF15803D);
  static const azalis = Color(0xFFC2410C);

  // Ölçü renkleri (çubuk dilimleri)
  static const zaman = Color(0xFF5BA8E0);
  static const para = Color(0xFFE8B92E);
  static const saglik = Color(0xFF4FB57D);
  static const iliski = Color(0xFFF06C9B);
}

// Yazı stilleri: kelimeler ve başlıklar piksel yazı tipiyle, sayılar ise
// karışmasın diye okunaklı ve eşit genişlikli Nunito ile yazılır.
class Yazi {
  static TextStyle piksel({
    double boyut = 16,
    FontWeight kalinlik = FontWeight.w500,
    Color renk = Renk.murekkep,
  }) =>
      GoogleFonts.pixelifySans(
        fontSize: boyut,
        fontWeight: kalinlik,
        color: renk,
      );

  static TextStyle sayi({
    double boyut = 15,
    Color renk = Renk.murekkep,
  }) =>
      GoogleFonts.nunito(
        fontSize: boyut,
        fontWeight: FontWeight.w800,
        color: renk,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle govde({
    double boyut = 15,
    FontWeight kalinlik = FontWeight.w700,
    Color renk = Renk.murekkep,
  }) =>
      GoogleFonts.nunito(fontSize: boyut, fontWeight: kalinlik, color: renk);
}

ThemeData temaOlustur() {
  final sema = ColorScheme.fromSeed(
    seedColor: Renk.lavanta,
    brightness: Brightness.light,
  ).copyWith(
    surface: Renk.krem,
    onSurface: Renk.murekkep,
    surfaceContainerLow: Renk.kagit,
  );

  final taban = ThemeData(useMaterial3: true, colorScheme: sema);

  return taban.copyWith(
    scaffoldBackgroundColor: Renk.krem,
    iconTheme: const IconThemeData(color: Renk.murekkep),
    textTheme: GoogleFonts.nunitoTextTheme(taban.textTheme).apply(
      bodyColor: Renk.murekkep,
      displayColor: Renk.murekkep,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Renk.krem,
      foregroundColor: Renk.murekkep,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: Yazi.piksel(boyut: 22, kalinlik: FontWeight.w700),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Renk.lavanta,
        foregroundColor: Renk.murekkep,
        elevation: 0,
        side: const BorderSide(color: Renk.murekkep, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: Yazi.piksel(boyut: 17, kalinlik: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
