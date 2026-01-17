# AgriServe - Hyperlocal Agriculture Marketplace

A production-ready Flutter application connecting farmers with agricultural equipment and specialized labour services through geospatial matching.

## Project Status

**Current Phase:** Planning & Foundation Setup ✅

**Completed:**
- ✅ Database schema with PostGIS
- ✅ Clean Architecture structure
- ✅ Core utilities and theme
- ✅ Domain entities

**Next Steps:**
1. Install Flutter SDK
2. Configure Supabase project
3. Implement authentication module
4. Build geospatial search

## Tech Stack

- **Frontend:** Flutter 3.2+ with Material 3
- **Backend:** Supabase (PostgreSQL + PostGIS)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Local Storage:** Hive
- **Image Storage:** Cloudinary
- **Payments:** Razorpay
- **Localization:** Hindi + English

## Project Structure

```
lib/
├── core/                      # Shared utilities
│   ├── constants/            # App constants, strings
│   ├── error/                # Error handling
│   ├── network/              # Network connectivity
│   ├── theme/                # Material 3 theme
│   └── utils/                # Helpers, validators
│
├── features/                 # Feature modules
│   ├── auth/                 # OTP authentication
│   ├── profile/              # Multi-role profile
│   ├── equipment/            # Equipment listings & search
│   ├── labour/               # Labour profiles & search
│   ├── booking/              # Booking lifecycle
│   └── payment/              # Razorpay integration
│
└── main.dart                 # App entry point
```

## Setup Instructions

### 1. Install Flutter

```bash
# Follow official Flutter installation guide
# https://docs.flutter.dev/get-started/install

flutter doctor
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Required credentials:
- Supabase URL and Anon Key
- Razorpay API keys
- Cloudinary configuration

### 3. Database Setup

1. Create Supabase project at https://supabase.com
2. Enable PostGIS extension in SQL Editor:
   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```
3. Execute `supabase_schema.sql` in SQL Editor
4. Verify Row Level Security policies are enabled

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run Application

```bash
flutter run
```

## Key Features

### Geospatial Search
- Providers define service radius (5-100 km)
- Farmers search based on live GPS location
- PostGIS `ST_DWithin` for radius-based filtering
- Results sorted by distance

### Multi-Role System
- Single account, switchable roles (Farmer/Provider)
- Context-aware UI based on active role
- Seamless role switching

### Booking Lifecycle
1. **Pending** - Farmer sends request
2. **Accepted** - Provider approves
3. **In Progress** - Job started (OTP verified)
4. **Completed** - Job ended (OTP verified)

### OTP Verification
- 6-digit OTP for job start/end
- SMS delivery via Supabase Auth
- Prevents fraudulent job completion claims

### Escrow Payments
- Farmer pays upfront via Razorpay
- Amount held until job completion
- Auto-release after OTP verification
- Provider protection with escrow

### Offline-First
- Hive caches user profile, bookings
- Graceful degradation for geospatial searches
- Sync when connection restored

## Development Guidelines

### Clean Architecture Layers

**Domain Layer:**
- Pure Dart entities
- Use cases (business logic)
- Repository interfaces

**Data Layer:**
- Repository implementations
- Data sources (remote/local)
- Models with JSON serialization

**Presentation Layer:**
- Pages and widgets
- Riverpod providers
- State management

### Naming Conventions

- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables:** `camelCase`
- **Constants:** `SCREAMING_SNAKE_CASE`

## Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## Contributing

1. Follow Clean Architecture principles
2. Use Either<Failure, Success> for error handling
3. Maintain bilingual support (Hindi/English)
4. Ensure Material 3 accessibility (48dp touch targets)
5. Test offline functionality

## License

Proprietary - AgriServe 2026

## Contact

For questions or support, contact the development team.
