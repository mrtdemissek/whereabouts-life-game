import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Animasyon tercihi.
// sistem: telefonun "Hareketi Azalt" ayarına uyar (varsayılan)
// tam: telefon ayarı ne olursa olsun tüm animasyonlar oynar
// azaltilmis: telefon ayarı ne olursa olsun hareketler yumuşak solmaya döner
enum HareketModu { sistem, tam, azaltilmis }

// Seçilen moda göre "hareket azaltılsın mı" kararı (saf fonksiyon, testli)
bool hareketAzaltilsinMi(HareketModu mod, bool sistemAzalt) {
  switch (mod) {
    case HareketModu.sistem:
      return sistemAzalt;
    case HareketModu.tam:
      return false;
    case HareketModu.azaltilmis:
      return true;
  }
}

class HareketAyari extends ChangeNotifier {
  HareketAyari._();
  static final HareketAyari ornek = HareketAyari._();

  static const _anahtar = 'hareket_modu';
  HareketModu _mod = HareketModu.sistem;
  HareketModu get mod => _mod;

  Future<void> yukle() async {
    final t = await SharedPreferences.getInstance();
    final ad = t.getString(_anahtar);
    for (final m in HareketModu.values) {
      if (m.name == ad) _mod = m;
    }
  }

  Future<void> sec(HareketModu m) async {
    if (m == _mod) return;
    _mod = m;
    notifyListeners();
    final t = await SharedPreferences.getInstance();
    await t.setString(_anahtar, m.name);
  }
}

// Flutter, telefonda "Hareketi Azalt" açıkken TÜM animasyonları kendiliğinden
// 20 kat hızlandırır (AnimationController süreyi 0.05 ile çarpar). Bu yüzden
// iPhone'da kartlar, geçişler, yumuşak solmalar bile göz açıp kapayana kadar
// biter ve "animasyon yok" gibi görünür. Bu bağlama o otomatik hızlandırmayı
// kapatır; hareketi azaltma kararını oyun kendisi verir (HareketKapsami ve
// her ekrandaki MediaQuery.disableAnimations kontrolleri: sarsıntı yerine
// renk, uçuş yerine solma).
class OyunBinding extends WidgetsFlutterBinding {
  @override
  bool get disableAnimations => false;
}

// Uygulamanın tepesinde: MediaQuery.disableAnimations değerini seçilen moda
// göre ayarlar. Oyundaki tüm ekranlar bu değeri okuduğu için tek yerden yönetilir.
class HareketKapsami extends StatelessWidget {
  final Widget child;
  const HareketKapsami({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HareketAyari.ornek,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final azalt = hareketAzaltilsinMi(
          HareketAyari.ornek.mod,
          mq.disableAnimations,
        );
        if (azalt == mq.disableAnimations) return child!;
        return MediaQuery(
          data: mq.copyWith(disableAnimations: azalt),
          child: child!,
        );
      },
      child: child,
    );
  }
}
