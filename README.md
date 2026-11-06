<div align="center">
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/nurebo_logo.png" alt="Nurebo Banner" width="400"/>  <p><strong>Marketplace di servizi e piattaforma sociale per prenotazioni, eventi e connessioni locali.</strong></p>

<p>
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"/>
    <img src="https://img.shields.io/badge/Version-0.2.9-blue" alt="Version"/>
  </p>
</div>

## 📱 Cos'è Nurebo?

**Nurebo** è un'applicazione mobile cross-platform (Flutter) che combina marketplace di servizi, prenotazioni e funzionalità social.

Permette agli utenti di:

- Scoprire e prenotare **prestazioni** (servizi) offerte da business locali
- Visualizzare attività su mappa con geolocalizzazione
- Gestire carrello e acquisti
- Partecipare a eventi e acquistare biglietti
- Interagire tramite feed di post, like, commenti e chat in tempo reale
- Gestire preferiti, amici e notifiche

Ideale per professionisti e business che vogliono offrire servizi prenotabili e per utenti che cercano soluzioni locali in modo semplice e sociale.

## ✨ Funzionalità principali

<div align="center">
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/nurebo_icon.png" alt="Nurebo Features" width="200"/>
</div>

| Funzionalità | Descrizione |
|-------------|-------------|
| **Prenotazioni** | Prenota slot di servizi (prestazioni) con gestione disponibilità |
| **Mappa** | Cerca business e servizi nelle vicinanze con Flutter Map |
| **Social Feed** | Post, like, commenti e interazioni con business e utenti |
| **Chat** | Messaggistica in tempo reale (Socket.IO) con business e amici |
| **Eventi** | Scopri eventi, prenota e gestisci biglietti |
| **Carrello & Acquisti** | Gestione ordini e pagamenti |
| **Notifiche** | Push notifications con Firebase |
| **Preferiti & Amici** | Salva servizi/business e gestisci connessioni |

## 📸 Screenshot

<div align="center">
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed.webp" width="150"/>
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed (1).webp" width="150"/>
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed (2).webp" width="150"/>
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed (3).webp" width="150"/>
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed (4).webp" width="150"/>
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed (5).webp" width="150"/>
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/unnamed (6).webp" width="150"/>
</div>

## 🛠 Tech Stack

- **Framework**: Flutter 3.x + Dart
- **State Management**: Provider + GetX
- **Backend Communication**: HTTP + Socket.IO Client
- **Mappe**: flutter_map + geolocator + geocoding
- **Notifiche**: Firebase Messaging + flutter_local_notifications
- **Storage locale**: SQLite (sqflite) + SharedPreferences
- **UI**: Google Fonts, Lottie, Carousel, Staggered Grid, custom widgets
- **Altro**: Image Picker, Cached Network Image, Permissions, etc.

## 🚀 Come iniziare

### Prerequisiti

- Flutter SDK >= 3.0.2
- Dart SDK
- Android Studio / Xcode (per mobile)
- Account Firebase configurato (per notifications)

### Installazione

```bash
# Clona il repository
git clone https://github.com/jacko95/nurebo.git
cd nurebo

# Installa le dipendenze
flutter pub get

# Genera i file (se necessario per launcher icons / splash)
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Avvia l'app
flutter run
```

### Configurazione

1. Configura Firebase (`lib/services/firebase_options.dart`)
2. Imposta l'endpoint del server (nurebo-server)
3. Configura le chiavi API necessarie (mappe, ecc.)

## 📁 Struttura del progetto

```
lib/
├── main.dart                 # Entry point
├── tab_navigator.dart        # Navigazione a tab
├── models/                   # Modelli dati (Business, Prestazione, Post, etc.)
├── provider/                 # State management
├── screens/                  # Schermate dell'app
├── services/                 # Servizi (Firebase, API, etc.)
├── sqflite_db/               # Database locale
├── utils/                    # Utility
└── widgets/                  # Componenti riutilizzabili
```

## 🔗 Progetti correlati

- **[nurebo-server](https://github.com/jacko95/nurebo-server)** — Backend del progetto

## 📄 Licenza

Questo progetto è privato / in sviluppo. Contatta il maintainer per informazioni.

---

<div align="center">
  <p>Realizzato con ❤️ in Flutter</p>
  <p><strong>Nurebo</strong> — Prenota. Scopri. Connettiti.</p>
</div>
