# SimpleDiary 📔

> A modern, privacy-first diary application built with Flutter for tracking your daily activities, moods, and personal growth — backed by research-based wellbeing science.

![Dashboard](docs/dashboard.png)

## ✨ Features

### 📊 Comprehensive Dashboard
- **Quick Stats Overview**: Track your current streak, weekly average scores, and daily status at a glance
- **7-Day Overview**: Visual representation of your week with color-coded scores
- **Mood Trend Chart**: Line chart showing your emotional journey over time
- **Insights & Achievements**: Smart suggestions and milestone tracking
- **Goals Tracking**: Set weekly/monthly goals per category with progress visualization

### 🧠 Research-Based Day Rating System
![Wizard Interface](docs/wizard.png)

The enhanced rating system is built on peer-reviewed wellbeing research and offers two modes:

**Enhanced Mode (PERMA+)**
- **Quick Mood Map** (Tier 1): Place your mood on an interactive 2D canvas based on the Circumplex Model of Affect (Russell, 1980) — valence × arousal axes
- **Wellbeing Dimensions** (Tier 2): Rate 6 PERMA+ dimensions — Mood, Energy, Connection, Purpose, Achievement, Engagement — each on a 1–5 scale (Seligman, 2011)
- **Emotion Wheel** (Tier 3, optional): Select specific emotions with intensity levels for emotional granularity tracking
- **Contextual Factors** (Tier 4, optional): Log sleep hours, sleep quality, exercise, stress level, and custom tags
- **Configurable tiers**: Enable only the sections you need per session

**Legacy Mode**
- Classic 4-category rating: Social, Productivity, Sport, Food
- Switch between modes at any time with a single tap

### 📝 Intelligent Diary Wizard
- **Step-by-step guided entry**: Structured approach to daily journaling
- **Rich text notes**: Add detailed descriptions with time ranges for each activity
- **Custom templates**: Create and reuse personalized note templates with section prompts
- **Configurable categories**: Create, edit, and delete note categories with custom colors
- **Favorite entries**: Mark special days and notes for quick access

### 🎯 Goals & Progress Tracking
- **Weekly and monthly goals**: Set target scores per rating category
- **Progress visualization**: See how you're tracking against your goals mid-period
- **Streak tracking**: Consecutive goal completions across periods
- **Smart suggestions**: Automatic target recommendations based on your history

### 📅 Calendar View
- **Monthly overview**: See all your diary entries at a glance
- **Color-coded entries**: Visual distinction by note category
- **Quick navigation**: Jump to any day's entry directly from the calendar

### 🔐 Security & Privacy
- **Local-first**: Your data stays on your device by default
- **Per-user encrypted databases**: Each user profile has its own AES-256 encrypted SQLite database
- **Password authentication**: PBKDF2 password hashing with salt
- **Biometric login**: Fingerprint / face unlock support (Android)
- **Multi-user support**: Separate diaries for different users on the same device

### 💾 Data Management
- **Automatic scheduled backups**: Configurable daily/weekly/monthly local backups
  - Android: Background scheduling via WorkManager
  - Desktop: Overdue check on app startup
- **Backup history & restore**: Browse, restore, or delete past backups
- **JSON export/import**: Full data portability with optional password encryption
- **ICS export**: Sync diary notes with any calendar app
- **Supabase sync**: Optional cloud backup and multi-device sync

### 🌍 Multi-Language Support
- **4 Languages**: English, German (Deutsch), Spanish (Español), French (Français)
- **Live language switching**: Change language instantly from Settings — no restart required
- **Persistent preference**: Language choice saved per user profile

### 🎨 Customizable Theming
- **Dynamic color schemes**: Choose any seed color for your theme
- **Dark mode support**: Full dark theme with optimized contrast
- **Material Design 3**: Modern, clean interface following latest design guidelines

### 🚀 Onboarding
- **First-launch flow**: Guided setup for theme, language, and account creation
- **Demo mode**: Explore the app with pre-filled sample data before committing
- **Setup wizard**: Step-by-step profile and preference configuration

### 🎨 Additional Features
![App Drawer](docs/app_drawer.png)

- **Search & filter**: Find past notes by text, category, or date range
- **Text highlighting**: Search terms highlighted in results
- **Cross-platform**: Windows, Linux, Android

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.29.3 or higher (stable)
- Dart SDK ≥ 3.0.3
- For desktop builds: platform-specific requirements (see below)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/SimpleDiary.git
   cd SimpleDiary
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp template.env .env
   ```
   Edit `.env` and set `PROJECT_NAME` (used for app document paths).
   ⚠️ **Never commit `.env` to version control!**

4. **Run the app**
   ```bash
   flutter run -d linux      # Linux desktop
   flutter run -d windows    # Windows desktop
   flutter run -d <deviceId> # Android
   ```

---

## 🛠️ Development Environment Setup

### Flutter

Follow the official installation guide for your platform:
https://docs.flutter.dev/get-started/install

### IDE

VS Code is recommended:
https://code.visualstudio.com/download

Install the **Flutter** and **Dart** extensions inside VS Code.

---

## 📁 Project Structure

```
lib/
├── core/                    # Shared infrastructure
│   ├── authentication/      # PBKDF2 password hashing & key derivation
│   ├── backup/              # Backup metadata model
│   ├── database/            # DbEntity, DbRepository, DbMigration, DbColumn
│   ├── encryption/          # AES-256 encryptor
│   ├── log/                 # Logger configuration
│   ├── navigation/          # Drawer items & routing
│   ├── onboarding/          # OnboardingStatus model & demo data generator
│   ├── provider/            # Global providers (theme, locale)
│   ├── services/            # BackupService, BackupScheduler, OnboardingService
│   ├── settings/            # SettingsContainer, BackupSettings, BiometricSettings
│   ├── theme/               # Theme definitions
│   ├── utils/               # Utilities, platform detection
│   └── widgets/             # Shared UI kit (AppCard, AppSpacing, etc.)
│
└── features/                # Feature modules (Clean Architecture)
    ├── app/                 # Main app shell & settings page
    ├── authentication/      # Login, registration, multi-user management
    ├── calendar/            # Calendar view
    ├── dashboard/           # Home dashboard, stats, insights
    ├── day_rating/          # Diary wizard, PERMA+ rating, mood map
    ├── goals/               # Goal setting, progress tracking
    ├── note_templates/      # Reusable note templates
    ├── notes/               # Notes & configurable categories
    ├── onboarding/          # First-launch flow, setup wizard, demo mode
    └── synchronization/     # File export/import, ICS, PDF reports, Supabase sync
```

### Architecture

- **Clean Architecture**: Domain / Data / Presentation layers per feature
- **Riverpod**: State management (StateNotifier pattern)
- **Schema-driven DB**: Each model declares its own `columns`, `migrations`, and serialization
- **Repository Pattern**: Unified CRUD via `DbRepository<T>`

---

## 🏗️ Building

### Linux
```bash
flutter build linux --release
```
**Requirements:**
```bash
sudo apt-get install libsqlite3-0 libsqlite3-dev  # Ubuntu/Debian
sudo dnf install sqlite-devel                       # Fedora
```

### Windows
```bash
flutter build windows --release
```

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

---

## 🧪 Testing

```bash
# Run all unit tests
flutter test test/core/ test/features/ test/l10n/

# Run with coverage
flutter test --coverage test/core/ test/features/ test/l10n/

# Static analysis
flutter analyze
```

**762 passing tests** across 45 test files covering:
- All data models (serialization round-trips)
- Dashboard statistics & streak calculation
- PDF export & date range logic
- Backup metadata & scheduling
- Goal progress & repository logic
- Localization completeness (EN, DE, ES, FR)
- Password hashing, AES encryption

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `sqflite` / `sqflite_common_ffi` | Local SQLite database |
| `supabase_flutter` | Optional cloud sync |
| `local_auth` | Biometric authentication |
| `encrypt` / `crypto` | AES-256 encryption & password hashing |
| `fl_chart` / `syncfusion_flutter_charts` | Charts and calendar |
| `enough_icalendar` | ICS calendar export |
| `google_fonts` | Typography |
| `flutter_riverpod` | State management |

For the complete list, see [pubspec.yaml](pubspec.yaml).

---

## 📤 Demo Data

A sample week of diary data is included at [`demo_week.json`](demo_week.json) for testing the import flow. Import it via **Settings → Sync → Import**.

---

## 🤝 Contributing

Contributions are welcome! Please submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/MyFeature`)
3. Commit your changes (`git commit -m 'Add MyFeature'`)
4. Push to the branch (`git push origin feature/MyFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
- [PERMA+ Wellbeing Model](https://ppc.sas.upenn.edu/learn-more/perma-theory-well-being-and-perma-workshops)
- [Circumplex Model of Affect — Russell (1980)](https://pdodds.w3.uvm.edu/research/papers/others/1980/russell1980a.pdf)

---

**Made with ❤️ using Flutter**
