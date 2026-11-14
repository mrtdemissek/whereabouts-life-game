import 'package:flutter/material.dart';
import 'acilis_ekrani.dart';
import 'ana_ekran.dart';
import 'dil.dart';
import 'dolap.dart';
import 'hareket.dart';
import 'muzik.dart';
import 'ses.dart';
import 'tema.dart';

final Yerellestirme genelYerel = Yerellestirme();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await genelYerel.yukle();
  await Ses.ornek.yukle();
  await Muzik.ornek.yukle();
  await Dolap.ornek.yukle();
  await HareketAyari.ornek.yukle();
  runApp(YerelKapsam(yerel: genelYerel, child: const WhereaboutsApp()));
}

class WhereaboutsApp extends StatelessWidget {
  const WhereaboutsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: oyunAdi,
      theme: temaOlustur(),
      // Hareket ayarı (Telefona göre / Tam / Azaltılmış) tüm ekranlara buradan iner.
      // Geniş ekranlarda (tarayıcı, tablet) oyunu 480 piksellik bir sütunda tut.
      builder: (context, child) => HareketKapsami(
        child: ColoredBox(
          color: const Color(0xFFEADFCB),
          child: LayoutBuilder(
            builder: (context, c) {
              final genislik = c.maxWidth > 480 ? 480.0 : c.maxWidth;
              return Center(
                child: SizedBox(
                  width: genislik,
                  height: c.maxHeight,
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
      home: const AnaEkran(),
    );
  }
}