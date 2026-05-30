# 🎬 Episode Planner

Aplikace pro přehled seriálů podle dne v týdnu.

## Funkce

- 📅 **Přepínání dnů** – každý den má svůj vlastní seznam
- ➕ **Přidání seriálu** – tlačítko + nebo FAB, výběr dne, platformy, sezóny a epizody
- ✏️ **Úprava seriálu** – dlouhý stisk karty nebo ikona tužky
- ✅ **Označení jako viděno** – zaškrtávátko na kartě
- 🗑️ **Smazání** – přejeď kartou doleva, nebo přes edit dialog
- 🔁 **Stejný seriál více dní** – každý záznam je samostatný, název se může opakovat

## Spuštění projektu

```bash
# 1. Přejdi do složky
cd episode_planner

# 2. Nainstaluj závislosti
flutter pub get

# 3. Spusť na simulátoru nebo zařízení
flutter run
```

## Struktura projektu

```
lib/
├── main.dart                        # Vstupní bod aplikace
├── models/
│   └── show_entry.dart              # Model seriálu + enum StreamingService
├── providers/
│   └── show_provider.dart           # State management (bez externích balíčků)
├── screens/
│   └── home_screen.dart             # Hlavní obrazovka s tab barem dnů
└── widgets/
    ├── show_card.dart               # Karta seriálu (dismiss = mazání, long press = edit)
    └── add_edit_show_dialog.dart    # Bottom sheet pro přidání/úpravu
```

## Platformy

- ✅ Android
- ✅ iOS
- ✅ Web (základní podpora)

## Možná rozšíření

- Persistence dat (SharedPreferences nebo SQLite/Hive)
- Notifikace připomínající epizody
- Statistiky sledování
- Tmavý/světlý motiv
