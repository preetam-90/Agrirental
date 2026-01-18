# Quick Setup Guide - Auth Fixes

## What Was Wrong?

Your app couldn't sign up or login because:

1. ❌ **Wrong Table Name** - App looked for `profiles` table but database has `user_profiles`
2. ❌ **Wrong Field Names** - Model fields didn't match database fields
3. ❌ **Missing Profiles** - When users signed up, their profile wasn't created in the database
4. ❌ **Phone Number Required** - Database required phone number for email/Google signup (doesn't make sense)
5. ❌ **Bad Google Redirect URL** - Hardcoded localhost URL only worked locally

**Error on screen**: `"Server error: Could not find the table 'public.profiles'..."`

## What Was Fixed?

✅ All table references changed from `profiles` → `user_profiles`
✅ All field names aligned with database schema
✅ Profile auto-creation when user signs up
✅ Phone number made optional
✅ Google redirect URL now works on any deployment

## What You Need To Do

### Step 1: Apply Database Migration

Open Supabase Dashboard → SQL Editor and paste:

```sql
BEGIN;

ALTER TABLE public.user_profiles 
ALTER COLUMN phone_number DROP NOT NULL;

ALTER TABLE public.user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_phone_number_key;

ALTER TABLE public.user_profiles 
ADD CONSTRAINT user_profiles_phone_number_unique UNIQUE NULLS NOT DISTINCT (phone_number) WHERE phone_number IS NOT NULL;

ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS is_profile_complete BOOLEAN DEFAULT FALSE;

COMMIT;
```

Click "Run" button to execute.

### Step 2: Configure Google OAuth (If Using Google Sign-In)

1. Go to Supabase Dashboard
2. Authentication → Providers → Google
3. Enable Google
4. Under Redirect URLs, add:
   - `http://localhost:3000` (for local testing)
   - Your production domain (e.g., `https://agriflutter.com`)
   - `io.supabase.agriflutter://login-callback/` (for Android)

### Step 3: Rebuild and Test

```bash
# Clean build
cd /home/pk/Desktop/agriflutter
flutter clean
flutter pub get

# Test on your device
flutter run -d RMX2156  # Your Android device
# OR
flutter run -d linux    # Linux desktop
# OR
flutter run -d web      # Web
```

## Test Checklist

After applying migration:

- [ ] Try email signup with new account
- [ ] Try email login with existing account  
- [ ] Try Google Sign-In (if configured)
- [ ] Try OTP signup (should still work)
- [ ] Complete profile with location/phone
- [ ] Switch between farmer and provider roles

## If Still Not Working

**Issue**: "Could not find table 'public.profiles'"
- Solution: Make sure you ran the SQL migration above

**Issue**: Google login redirects to wrong page
- Solution: Make sure Supabase has your domain in redirect URLs

**Issue**: Compile errors about providers
- Solution: Run `flutter clean && flutter pub get`

## Files Changed

1. `lib/features/auth/data/datasources/auth_remote_datasource.dart` - 4 fixes
2. `lib/features/auth/data/models/user_model.dart` - 3 fixes  
3. `supabase/migrations/001_make_phone_optional.sql` - NEW migration file
4. `AUTH_FIXES_DOCUMENTATION.md` - Detailed documentation

All changes are backwards compatible and should not break existing functionality.
