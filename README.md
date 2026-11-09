# Whereabouts (working title)

*Türkçe özet: Rastgele bir ülkede doğduğun, her yıl bir karar verdiğin ve hayatın gerçek verilerden türetilen koşullara göre şekillendiği, Flutter ile yazılmış piksel sanatlı bir hayat simülasyonu. Öğrenme ve portföy projesi.*

A pastel pixel-art life simulation built with Flutter. You are born in a random country, make one decision a year by swiping cards, and live a life shaped by conditions derived from real-world indicators. Each country has its own life expectancy, and you complete a country in the atlas only by reaching its expected age.

## How it plays

- **Random birth:** every country has an equal chance. You do not choose where you are born.
- **Early years:** your family makes the decisions until age 5. Infant mortality is higher in countries with lower life expectancy.
- **Swipe cards:** four meters (time, money, health, relationships). Choices leave hidden tags that unlock chain cards later in life.
- **Mortality model:** death is random and depends on the country's life expectancy and your health. After the expected age, life continues until death.
- **Country conditions:** life events and the cause of death are drawn from a risk profile built from published indicators (water, disease, hunger, violence, conflict, inflation, unemployment, governance perception and more). An event only appears when real data exists for the country.
- **Atlas, badges, daily challenge:** complete countries, earn badges, keep a daily streak.
- **Languages:** Turkish and English.

## Tech

- Flutter / Dart, tested on an Android emulator (iOS not tested).
- All pixel art (characters, scenery, icons, confetti) is drawn in code.
- All sound effects are synthesized in code at runtime; no audio files.
- Local storage with `shared_preferences`; audio with `audioplayers`.

## Data and attribution

Country data comes from **The World Bank**: World Development Indicators (including life expectancy at birth, `SP.DYN.LE00.IN`) and Worldwide Governance Indicators, provided under the **CC BY 4.0** license. The exact list of indicators is in `tools/veri_hazirla.ps1`. Original data providers include the International Monetary Fund, the International Labour Organization, the UN Office on Drugs and Crime, the Uppsala Conflict Data Program, the World Health Organization, the Food and Agriculture Organization, the WHO/UNICEF Joint Monitoring Programme and the World Bank Poverty and Inequality Platform.

The data was processed for the game: the latest available year per country is used, and each indicator is converted into a 0 to 1 risk score based on how countries rank against each other. Governance indicators are perception measures based on surveys and expert assessments.

The inflation indicator originates from the IMF, whose terms ask for permission for commercial reuse. This project is non-commercial.

This project is not endorsed, supported or produced by The World Bank or any of the data providers.

## Disclaimer

The game is a simplification. Death risk comes from a simple model derived only from each country's average life expectancy and does not use real mortality tables. Causes of death and life events are random draws from country risk profiles, not real individual experiences or real statistics. The game makes no personal or statistical prediction.

## Run locally

```
flutter pub get
flutter run
```

To rebuild the risk data (needs internet, Windows PowerShell):

```
powershell -ExecutionPolicy Bypass -File tools\veri_hazirla.ps1
```

## Credits

- Inspired by the idea of being born at random into a real-world statistic. No code, text or art from any other project is used.
- UI font: Fredoka (SIL Open Font License 1.1), loaded at runtime with the `google_fonts` package.

## License

Code is released under the MIT License (see `LICENSE`). The files in `assets/` are derived from CC BY 4.0 data as described above.