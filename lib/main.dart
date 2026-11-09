import 'package:flutter/material.dart';
import 'acilis_ekrani.dart';
import 'dil.dart';
import 'muzik.dart';
import 'ses.dart';
import 'tema.dart';

final Yerellestirme genelYerel = Yerellestirme();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await genelYerel.yukle();
  await Ses.ornek.yukle();
  await Muzik.ornek.yukle();
  runApp(YerelKapsam(yerel: genelYerel, child: const HayatOyunu()));
}

class HayatOyunu extends StatelessWidget {
  const HayatOyunu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: oyunAdi,
      theme: temaOlustur(),
      home: const AcilisEkrani(),
    );
  }
}