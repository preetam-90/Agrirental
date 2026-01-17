# AgriServe - Setup Guide

## Prerequisites

1. **Flutter SDK**: Version 3.2 or higher
   ```bash
   flutter --version
   ```

2. **Supabase Account**: Create at https://supabase.com

3. **API Keys**: 
   - Razorpay account (for payments)
   - Cloudinary account (for images)

## Step-by-Step Setup

### 1. Install Flutter

Follow the official guide: https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Clone and Setup Project

```bash
cd /home/pk/Desktop/agriflutter
flutter pub get
```

### 3. Configure Supabase Database

#### A. Create Supabase Project
1. Go to https://app.supabase.com
2. Click "New Project"
3. Fill in project details
4. Copy your Project URL and Anon Key

#### B. Enable PostGIS Extension
1. Go to SQL Editor in Supabase dashboard
2. Run:
   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```

#### C. Execute Database Schema
1. Open `supabase_schema.sql`
2. Copy entire contents
3. Paste into SQL Editor
4. Click "Run"
5. Verify all tables created:
   - user_profiles
   - equipment_listings
   - labour_profiles
   - bookings
   - otp_verifications
   - payments
   - reviews

#### D. Enable Phone Authentication
1. Go to Authentication → Providers
2. Enable "Phone" provider
3. Configure SMS provider (Twilio recommended):
   - Add Twilio credentials
   - Or use Supabase built-in (limited free tier)

### 4. Configure Environment Variables

Create `.env` file in project root:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
# Supabase Configuration
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Razorpay Configuration
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=xxxxx

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
CLOUDINARY_UPLOAD_PRESET=agriflutter_preset
```

**Important**: Update `lib/core/constants/app_constants.dart` to load from `.env` or hardcode for testing:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 5. Install Dependencies

```bash
flutter pub get
```

If you encounter issues, run:
```bash
flutter pub upgrade
flutter clean
flutter pub get
```

### 6. Run the Application

#### For Android:
```bash
flutter run
```

#### For iOS (macOS only):
```bash
flutter run -d ios
```

#### For Web (testing only):
```bash
flutter run -d chrome
```

## Testing the Authentication Flow

### Test OTP Login:

1. Launch app
2. Enter a valid Indian mobile number (10 digits)
3. Click "Send OTP"
4. **Check Supabase logs** for OTP code:
   - Go to Supabase Dashboard → Authentication → Logs
   - Or check your phone for SMS (if SMS provider configured)
5. Enter the 6-digit OTP
6. Click "Verify OTP"
7. Should see home screen with user details

### Test Offline Functionality:

1. Login successfully
2. Close app
3. **Enable airplane mode**
4. Relaunch app
5. Should automatically login from cached data

### Test Sign Out:

1. From home screen, click logout icon
2. Should return to login screen
3. Cache should be cleared

## Troubleshooting

### Issue: "No such table: user_profiles"
**Solution**: Run `supabase_schema.sql` in Supabase SQL Editor

### Issue: "OTP not sending"
**Solution**: 
- Check Supabase Authentication → Providers → Phone is enabled
- Verify SMS provider configured (Twilio, etc.)
- Check Supabase logs for errors

### Issue: "Invalid or expired OTP"
**Solution**:
- OTP expires in 10 minutes (configurable in Supabase)
- Request new OTP
- Check phone number format (+91XXXXXXXXXX)

### Issue: Build errors with dependencies
**Solution**:
```bash
flutter clean
rm -rf .dart_tool
flutter pub get
```

### Issue: Hive database errors
**Solution**:
- Clear app data
- Or delete Hive files manually:
```bash
find . -name "*.hive" -delete
find . -name "*.lock" -delete
```

## Next Steps

After authentication works:

1. **Complete Profile Setup**: Enable users to update name, location, role
2. **Implement Equipment Listings**: Create, read, update equipment
3. **Build Geospatial Search**: ST_DWithin queries with live GPS
4. **Add Booking System**: Request, accept, OTP verification
5. **Integrate Payments**: Razorpay escrow

## Development Notes

- **Hot Reload**: Press `r` in terminal for hot reload during development
- **Hot Restart**: Press `R` for hot restart
- **Quit**: Press `q` to stop the app

## Useful Commands

```bash
# Check Flutter doctor
flutter doctor -v

# Run with specific device
flutter devices
flutter run -d <device-id>

# Build APK for testing
flutter build apk --release

# View logs
flutter logs

# Format code
dart format .

# Analyze code
flutter analyze
```

## Support

For issues or questions, refer to:
- Flutter docs: https://docs.flutter.dev
- Supabase docs: https://supabase.com/docs
- Project README.md
