// Hayatın başlangıç bağlamı: doğumda her hayata iki etiket verilir.
// Ülkenin koşulları: 'zor', 'orta' ya da 'refah' (yaşam süresinden).
// Yaşanılan yer: 'kir' ya da 'kent' (rastgele).
String ulkeTuru(double omur) {
  if (omur < 66) return 'zor';
  if (omur < 76) return 'orta';
  return 'refah';
}
