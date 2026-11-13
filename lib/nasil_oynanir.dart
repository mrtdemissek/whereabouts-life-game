import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dil.dart';
import 'oyuncak.dart';
import 'ses.dart';
import 'tema.dart';

const _anahtar = 'nasil_oynanir_goruldu';

// Anlatım daha önce gösterildi mi
Future<bool> nasilGorulduMu() async {
  try {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_anahtar) ?? false;
  } catch (_) {
    return true;
  }
}

Future<void> nasilGoruldu() async {
  try {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_anahtar, true);
  } catch (_) {}
}

class _Sayfa {
  final IconData ikon;
  final Color renk;
  final String baslikTr;
  final String baslikEn;
  final String metinTr;
  final String metinEn;
  const _Sayfa({
    required this.ikon,
    required this.renk,
    required this.baslikTr,
    required this.baslikEn,
    required this.metinTr,
    required this.metinEn,
  });
}

final _sayfalar = <_Sayfa>[
  _Sayfa(
    ikon: Icons.public,
    renk: Renk.gokMavisi,
    baslikTr: 'Rastgele doğ',
    baslikEn: 'Be born at random',
    metinTr: 'Doğ düğmesine bas. Dünyanın rastgele bir ülkesinde doğarsın. '
        'Nerede doğacağını seçemezsin, hayatın oradaki koşullara göre şekillenir.',
    metinEn: 'Tap Be born. You are born in a random country. '
        'You cannot choose where, and your life is shaped by the conditions there.',
  ),
  _Sayfa(
    ikon: Icons.swipe,
    renk: Renk.nane,
    baslikTr: 'Kartları kaydır',
    baslikEn: 'Swipe the cards',
    metinTr: 'Her kart bir karar. Kartı sağa ya da sola kaydırarak bir seçenek '
        'seç. Hangi yönün neyi seçtiğini kartın altındaki oklar gösterir, '
        'üstelik yönler her kartta yer değiştirebilir.',
    metinEn: 'Every card is a decision. Swipe it left or right to choose. '
        'The arrows under the card show what each direction means, and the '
        'directions can swap from card to card.',
  ),
  _Sayfa(
    ikon: Icons.favorite,
    renk: Renk.seftali,
    baslikTr: 'Dört ölçüyü dengede tut',
    baslikEn: 'Keep four meters balanced',
    metinTr: 'Zaman, para, sağlık ve ilişkiler. Bir ölçü sıfıra inerse sağlığın '
        'hızla düşer. Sağlık sıfır olunca hayat biter. Hiçbir seçim hepsini '
        'birden artırmaz.',
    metinEn: 'Time, money, health and relationships. If a meter hits zero, '
        'your health drops fast, and when health reaches zero life ends. '
        'No choice improves everything at once.',
  ),
  _Sayfa(
    ikon: Icons.emoji_events,
    renk: Renk.limon,
    baslikTr: 'Ülkeyi tamamla',
    baslikEn: 'Complete the country',
    metinTr: 'Her ülkenin ortalama yaşam süresi farklı. O yaşa ulaşırsan ülkeyi '
        'atlasta tamamlarsın. Rozet topla, günlük meydan okumada herkes aynı '
        'ülkede ve aynı zarlarla oynar.',
    metinEn: 'Every country has a different life expectancy. Reach it and you '
        'complete the country in the atlas. Collect badges, and in the daily '
        'challenge everyone plays the same country with the same dice.',
  ),
];

class NasilOynanirEkrani extends StatefulWidget {
  const NasilOynanirEkrani({super.key});

  @override
  State<NasilOynanirEkrani> createState() => _NasilOynanirEkraniState();
}

class _NasilOynanirEkraniState extends State<NasilOynanirEkrani> {
  final PageController _kontrol = PageController();
  int _sayfa = 0;

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  void _ileri() {
    Ses.ornek.cal(SesTuru.tik);
    if (_sayfa >= _sayfalar.length - 1) {
      nasilGoruldu();
      Navigator.pop(context);
      return;
    }
    _kontrol.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _gec() {
    nasilGoruldu();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.yerel.kod == 'tr';
    final son = _sayfa == _sayfalar.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(tr ? 'Nasıl oynanır' : 'How to play')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _kontrol,
                  itemCount: _sayfalar.length,
                  onPageChanged: (i) => setState(() => _sayfa = i),
                  itemBuilder: (context, i) {
                    final s = _sayfalar[i];
                    return Center(
                      child: SingleChildScrollView(
                        child: OyuncakKart(
                          renk: s.renk,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(s.ikon, size: 72, color: Renk.murekkep),
                              const SizedBox(height: 16),
                              Text(
                                tr ? s.baslikTr : s.baslikEn,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tr ? s.metinTr : s.metinEn,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _sayfalar.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _sayfa ? 22 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == _sayfa ? Renk.murekkep : Renk.kagit,
                        border: Border.all(color: Renk.murekkep, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  son
                      ? const SizedBox(width: 80)
                      : TextButton(
                          onPressed: _gec,
                          child: Text(tr ? 'Geç' : 'Skip'),
                        ),
                  ElevatedButton(
                    onPressed: _ileri,
                    child: Text(
                      son
                          ? (tr ? 'Başla' : "Let's go")
                          : (tr ? 'İleri' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}