# 🌾 AgriServe

> A hyperlocal agriculture marketplace built with Flutter + Supabase to connect farmers with equipment owners and skilled labour providers through location-aware matching.

[![Flutter](https://img.shields.io/badge/Flutter-3.22%2B-02569B?logo=flutter&logoColor=white)](https://docs.flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres%20%2B%20PostGIS-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-6C63FF)](#architecture)

---

## ✨ Why AgriServe?

AgriServe helps rural communities discover and book nearby agricultural services quickly and reliably:

- 🔎 **Geo-search** for equipment and labour providers using PostGIS radius filtering.
- 👥 **Dual-role accounts** (Farmer/Provider) with seamless role switching.
- 📦 **Structured booking lifecycle** from request to completion.
- 🔐 **OTP-verified milestones** to reduce fraud and disputes.
- 💳 **Escrow-style payments** with Razorpay.
- 📶 **Offline-aware experience** using local caching.

---

## 🧱 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Material 3), Dart |
| State Management | Riverpod |
| Routing | GoRouter |
| Backend | Supabase (PostgreSQL + PostGIS) |
| Local Storage | Hive |
| Media Storage | Cloudinary |
| Payments | Razorpay |
| Localization | Hindi + English |

---

## 🚀 Quick Start

### 1) Prerequisites

- Flutter SDK (3.22+ recommended)
- Dart SDK (bundled with Flutter)
- A Supabase project
- Razorpay and Cloudinary credentials

Check your setup:

```bash
flutter doctor
```

### 2) Clone and install dependencies

```bash
git clone <your-repo-url>
cd Agrirental
flutter pub get
```

### 3) Configure environment

```bash
cp .env.example .env
```

Then populate `.env` with your keys:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- Razorpay keys
- Cloudinary values

### 4) Provision database

1. Create a new Supabase project.
2. Enable PostGIS:

   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```

3. Run `supabase_schema.sql` in the SQL editor.
4. Verify Row Level Security policies are enabled.

### 5) Generate code (if needed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6) Run the app

```bash
flutter run
```

---

## 🧭 Project Status

**Current phase:** Foundation complete, feature implementation in progress.

### Completed

- ✅ Database schema with PostGIS
- ✅ Clean Architecture foundation
- ✅ Core theme/utilities scaffolding
- ✅ Initial domain entity modeling

### Next

1. Authentication module completion
2. End-to-end geospatial search flow
3. Booking + payment integration hardening
4. Production deployment workflow

---

## 🗂️ Project Structure

```text
lib/
├── core/                      # Shared infrastructure
│   ├── constants/            # App-wide constants and strings
│   ├── error/                # Failure models and error mapping
│   ├── network/              # Connectivity and network helpers
│   ├── theme/                # Material 3 design system
│   └── utils/                # Generic helpers and validators
├── features/                 # Vertical feature modules
│   ├── auth/                 # OTP-based authentication
│   ├── profile/              # Multi-role user profiles
│   ├── equipment/            # Listings and discovery
│   ├── labour/               # Labour profiles and search
│   ├── booking/              # Request-to-completion flow
│   └── payment/              # Razorpay integration
└── main.dart                 # App bootstrap
```

---

## 🧠 Architecture

AgriServe follows **Clean Architecture**:

- **Domain**: Entities, repository contracts, use-cases.
- **Data**: Models, data sources, repository implementations.
- **Presentation**: UI widgets/pages, Riverpod providers, state.

### Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`

---

## 🔐 Core Product Flows

### Geospatial Search

- Providers define service radius (5–100 km).
- Farmers search from live/current location.
- Filtering is handled with `ST_DWithin` and sorted by distance.

### Booking Lifecycle

1. **Pending** – Request created by farmer.
2. **Accepted** – Provider approves.
3. **In Progress** – OTP-verified start.
4. **Completed** – OTP-verified closure + payment release.

### Role Switching

- Single account can operate as Farmer or Provider.
- Context-aware UI updates by active role.

---

## 🧪 Testing

```bash
flutter test
flutter test --coverage
```

---

## 🤝 Contributing

When contributing:

1. Respect Clean Architecture boundaries.
2. Preserve bilingual UX (Hindi/English).
3. Maintain accessible Material 3 patterns (e.g., touch targets).
4. Validate offline resilience where applicable.

---

## 📚 Additional Docs

- `QUICK_SETUP.md`
- `SETUP.md`
- `DEPLOYMENT_CHECKLIST.md`
- `AUTH_FIXES_DOCUMENTATION.md`
- `AUTH_FIXES_INDEX.md`

---

## 📄 License

Proprietary © AgriServe 2026
