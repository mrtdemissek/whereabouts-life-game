# Whereabouts

*Türkçe özet: Rastgele bir ülkede doğduğun, her yıl bir karar verdiğin ve hayatın gerçek verilerden türetilen koşullara göre şekillendiği, Flutter ile yazılmış piksel sanatlı bir hayat simülasyonu (Whereabouts - Hayat Oyunu). Öğrenme ve portföy projesi.*

**Play in your browser: https://mrtdemissek.github.io/whereabouts-life-game/**

A pastel pixel-art life simulation built with Flutter. You are born in a random country, make one decision a year by swiping cards, and live a life shaped by conditions derived from real-world indicators. Each country has its own life expectancy, and you complete a country in the atlas only by reaching its expected age.

## How it plays

- **Random birth:** every country has an equal chance. You do not choose where you are born.
- **Early years:** your family makes the decisions until age 5. Infant mortality is higher in countries with lower life expectancy.
- **Swipe cards:** four meters (time, money, health, relationships). Choices leave hidden tags that unlock chain cards later in life.
- **Mortality model:** death is random and depends on the country's life expectancy and your health. After the expected age, life continues until death.
- **Country conditions:** life events and the cause of death are drawn from a risk profile built from published indicators (water, disease, hunger, violence, conflict, inflation, unemployment, governance perception and more). An event only appears when real data exists for the country.
- **Atlas, badges, daily challenge:** complete countries, earn badges, keep a daily streak. The daily challenge uses a seeded generator, so everyone gets the same country and the same dice that day, on every platform.
- **Languages:** Turkish and English.

## Tech

- Flutter / Dart. Tested on an Android emulator and in a desktop browser (iOS not tested natively).
- All pixel art (characters, scenery, icons, confetti) is drawn in code.
- All sound effects and background music are synthesized in code at runtime; no audio files.
- Local storage with `shared_preferences`; audio with `audioplayers`.
- The web version is built and published automatically with GitHub Actions (`.github/workflows/web.yml`).

## Web version notes

- Music starts after your first tap (browser autoplay rules).
- There is no vibration feedback in the browser.
- Progress is stored in your browser, so clearing site data resets the atlas and badges.

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

To build the web version yourself:

```
flutter build web --release
```

## License

MIT, see `LICENSE`.