import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kıyafet dolabı: toplam yıldızla açılan, oyunu etkilemeyen görünüm
// seçenekleri. Bir seçenek, toplam yıldız eşiğine ulaşınca kalıcı olarak açılır
// (yıldız harcanmaz). Adlar çeviri dosyalarında kozmetik_<id>.

enum KozmetikTuru { gomlek, sac, dunya }

// Dünya teması: gezegenin çimen, orman ve su renkleri
class DunyaTemasi {
  final Color cimen;
  final Color orman;
  final Color su;
  const DunyaTemasi(this.cimen, this.orman, this.su);
}

class Kozmetik {
  final String id;
  final KozmetikTuru tur;
  final int esik; // açılması için gereken toplam yıldız
  final Color? renk; // gömlek ya da saç rengi (rastgele gömlekte null)
  final DunyaTemasi? dunya;
  const Kozmetik(this.id, this.tur, this.esik, {this.renk, this.dunya});
}

const tumKozmetikler = [
  // Kıyafet (gömlek)
  Kozmetik('rastgele', KozmetikTuru.gomlek, 0),
  Kozmetik('mercan', KozmetikTuru.gomlek, 3, renk: Color(0xFFFF6F61)),
  Kozmetik('nane', KozmetikTuru.gomlek, 6, renk: Color(0xFF2BAE66)),
  Kozmetik('gece_mavisi', KozmetikTuru.gomlek, 10, renk: Color(0xFF1F3A93)),
  Kozmetik('altin', KozmetikTuru.gomlek, 15, renk: Color(0xFFE0A800)),
  Kozmetik('leylak', KozmetikTuru.gomlek, 25, renk: Color(0xFF8E5BD8)),
  // Saç
  Kozmetik('kahve', KozmetikTuru.sac, 0, renk: Color(0xFF5B3A29)),
  Kozmetik('siyah', KozmetikTuru.sac, 5, renk: Color(0xFF222222)),
  Kozmetik('kizil', KozmetikTuru.sac, 12, renk: Color(0xFFB5482A)),
  Kozmetik('sari', KozmetikTuru.sac, 20, renk: Color(0xFFE8C15A)),
  Kozmetik('mavi', KozmetikTuru.sac, 35, renk: Color(0xFF4F7BD9)),
  // Dünya
  Kozmetik('yesil', KozmetikTuru.dunya, 0),
  Kozmetik('col', KozmetikTuru.dunya, 8,
      dunya: DunyaTemasi(Color(0xFFE8C98A), Color(0xFFC9A15E), Color(0xFF7FC8D9))),
  Kozmetik('kis', KozmetikTuru.dunya, 18,
      dunya: DunyaTemasi(Color(0xFFEFF4F9), Color(0xFFB9CFE0), Color(0xFF8FB8DE))),
  Kozmetik('sonbahar', KozmetikTuru.dunya, 30,
      dunya: DunyaTemasi(Color(0xFFF0B46A), Color(0xFFD9774A), Color(0xFF96CDEE))),
  Kozmetik('pembe', KozmetikTuru.dunya, 50,
      dunya: DunyaTemasi(Color(0xFFF7B8D2), Color(0xFFD98AB5), Color(0xFFB9A5EA))),
];

Iterable<Kozmetik> kozmetiklerTuru(KozmetikTuru t) =>
    tumKozmetikler.where((k) => k.tur == t);

bool acikMi(Kozmetik k, int toplamYildiz) => toplamYildiz >= k.esik;

// Seçili görünüm. Her yerden Dolap.ornek ile okunur.
class Dolap extends ChangeNotifier {
  Dolap._();
  static final Dolap ornek = Dolap._();

  static const _anahtar = 'dolap_secim'; // "gomlek:id", "sac:id", "dunya:id"
  final Map<KozmetikTuru, String> _secim = {
    KozmetikTuru.gomlek: 'rastgele',
    KozmetikTuru.sac: 'kahve',
    KozmetikTuru.dunya: 'yesil',
  };

  String secili(KozmetikTuru t) => _secim[t]!;

  Kozmetik _bul(KozmetikTuru t) => tumKozmetikler.firstWhere(
        (k) => k.tur == t && k.id == _secim[t],
        orElse: () => kozmetiklerTuru(t).first,
      );

  // null: gömlek rastgele seçilsin
  Color? get gomlekRengi => _bul(KozmetikTuru.gomlek).renk;
  Color get sacRengi => _bul(KozmetikTuru.sac).renk ?? const Color(0xFF5B3A29);
  DunyaTemasi? get dunyaTemasi => _bul(KozmetikTuru.dunya).dunya;

  Future<void> yukle() async {
    final t = await SharedPreferences.getInstance();
    for (final s in t.getStringList(_anahtar) ?? <String>[]) {
      final p = s.split(':');
      if (p.length != 2) continue;
      for (final tur in KozmetikTuru.values) {
        if (tur.name == p[0] && kozmetiklerTuru(tur).any((k) => k.id == p[1])) {
          _secim[tur] = p[1];
        }
      }
    }
  }

  Future<void> sec(Kozmetik k) async {
    _secim[k.tur] = k.id;
    notifyListeners();
    final t = await SharedPreferences.getInstance();
    await t.setStringList(
      _anahtar,
      [for (final e in _secim.entries) '${e.key.name}:${e.value}'],
    );
  }
}
