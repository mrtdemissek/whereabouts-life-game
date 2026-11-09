import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pastel oyuncak renk paleti
class Renk {
  static const krem = Color(0xFFFFF6E9); // arka plan
  static const kagit = Color(0xFFFFFFFF); // kartlar
  static const murekkep = Color(0xFF4A3F5C); // metin ve çerçeveler
  static const lavanta = Color(0xFFC3B1E8); // ana vurgu
  static const nane = Color(0xFFBDEBD6);
  static const seftali = Color(0xFFFFD3B6);
  static const gokMavisi = Color(0xFFBFE3F5);
  static const pembe = Color(0xFFFFC8DD);
  static const limon = Color(0xFFFFF1A8);

  // Ölçü renkleri
  static const zaman = Color(0xFF8EC9F0);
  static const para = Color(0xFFF7D774);
  static const saglik = Color(0xFF9EDDB5);
  static const iliski = Color(0xFFFFA8C5);
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
    textTheme: GoogleFonts.fredokaTextTheme(taban.textTheme).apply(
      bodyColor: Renk.murekkep,
      displayColor: Renk.murekkep,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Renk.krem,
      foregroundColor: Renk.murekkep,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Renk.murekkep,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Renk.lavanta,
        foregroundColor: Renk.murekkep,
        elevation: 0,
        side: const BorderSide(color: Renk.murekkep, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}