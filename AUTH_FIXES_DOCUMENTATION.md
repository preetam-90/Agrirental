# Authentication Issues - Fixed

## Issues Found and Fixed

### 1. ❌ Table Name Mismatch
**Problem**: The app was querying a `profiles` table but the database has `user_profiles`
**Locations Fixed**:
- `auth_remote_datasource.dart` line 181 - Changed `from('profiles')` to `from('user_profiles')`
- `auth_remote_datasource.dart` line 263 - Changed upsert to use `user_profiles`
- `auth_remote_datasource.dart` line 278 - Changed update to use `user_profiles`

### 2. ❌ Field Name Mismatches
**Problem**: Database fields didn't match model/entity expectations
**Fixes**:
- Changed `avatar_url` → `profile_image_url` (in UserModel)
- Changed `current_role` → `active_role` (in UserModel and queries)
- Changed role value `'provider'` → `'equipment_provider'` (matches schema enum)

**Files Updated**:
- `user_model.dart` - Updated field mappings in `fromJson()` and `toJson()`
- `auth_remote_datasource.dart` - Updated role conversion in `updateProfileRole()`

### 3. ❌ Missing Profile Creation
**Problem**: When users signed up with email or Google, profile was queried but never created
**Fix**: Updated `_getOrCreateUserProfile()` to actually insert the profile record when it doesn't exist

### 4. ⚠️ Required Phone Number Issue
**Problem**: `phone_number` was NOT NULL but email/Google signup don't provide it
**Solution Created**: 
- Migration file: `supabase/migrations/001_make_phone_optional.sql`
- Makes `phone_number` nullable (optional)
- Adds proper UNIQUE constraint that allows NULL values
- This migration must be run in Supabase

### 5. ⚠️ Hardcoded Google Redirect URL
**Problem**: Web redirect was hardcoded to `http://localhost:8080` (development only)
**Fix**: 
- Now uses `Uri.base.toString()` for web to use the actual deployment URL
- Maintains `io.supabase.agriflutter://login-callback/` for mobile

### 6. ✅ Compile Error (Already Fixed)
**Note**: The `undefined name 'currentUserProvider'` error in equipment_providers.dart is already resolved since `currentUserProvider` is properly defined in `auth_state_provider.dart` and imported.

## Required Actions

### 1. Apply the Migration to Supabase
Run this SQL in Supabase SQL Editor:
```sql
-- Migration: Make phone_number optional
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

### 2. Configure Google OAuth in Supabase
For Google Sign-In to work:
1. Go to Supabase Dashboard → Authentication → Providers
2. Enable Google OAuth
3. Add these redirect URLs:
   - For Web: Your deployed domain (e.g., `https://yourdomain.com`)
   - For Mobile: `io.supabase.agriflutter://login-callback/`
   - For Testing: `http://localhost:3000` (if testing locally)

### 3. Test Authentication Flow
After running migration:
1. Test email signup: Should create user_profiles record
2. Test Google Sign-In: Should create user_profiles with email-based identifier
3. Test OTP: Should work as before
4. Test profile completion: Users should be able to add phone number during onboarding

## Code Changes Summary

**Files Modified**:
1. `lib/features/auth/data/datasources/auth_remote_datasource.dart`
   - 3 table name fixes (profiles → user_profiles)
   - Fixed Google redirect URL handling
   - Added profile auto-creation logic
   - Fixed role value mapping

2. `lib/features/auth/data/models/user_model.dart`
   - Fixed field mappings (avatar_url → profile_image_url, current_role → active_role)
   - Updated role enum parsing ('provider' → 'equipment_provider')

3. `supabase/migrations/001_make_phone_optional.sql` (NEW)
   - Migration to make phone_number optional
   - Must be applied to Supabase database

## Sign-Up Flow After Fix

**Email Signup**:
1. User enters email & password
2. Supabase creates auth user
3. App creates user_profiles entry with null phone_number
4. User taken to onboarding to complete profile
5. User can add phone number during onboarding

**Google Signup**:
1. User clicks "Sign in with Google"
2. Google OAuth redirect (dynamic URL based on environment)
3. Supabase creates auth user with email from Google
4. App creates user_profiles entry with null phone_number
5. User taken to onboarding to complete profile

**OTP Signup** (unchanged):
1. User enters phone number
2. OTP sent to phone
3. User verifies OTP
4. Supabase creates auth user
5. App creates user_profiles with phone_number
6. User taken to onboarding if needed
