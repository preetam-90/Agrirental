#!/bin/bash
# This file contains all the commands you need to fix the auth issues
# Follow these steps exactly

echo "=========================================="
echo "AGRIFLUTTER AUTH FIX - SETUP INSTRUCTIONS"
echo "=========================================="
echo ""

echo "STEP 1: RUN DATABASE MIGRATION"
echo "------"
echo "1. Open https://app.supabase.com"
echo "2. Select your project"
echo "3. Go to 'SQL Editor' on the left"
echo "4. Click 'New Query'"
echo "5. Copy and paste the following SQL:"
echo ""
echo "---START COPY FROM HERE---"
cat << 'SQL'
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
SQL
echo "---END COPY---"
echo ""
echo "6. Click 'Run' button"
echo "7. Wait for success message"
echo ""

echo "STEP 2: CONFIGURE GOOGLE OAUTH (Optional but recommended)"
echo "------"
echo "1. Still in Supabase Dashboard"
echo "2. Go to 'Authentication' → 'Providers'"
echo "3. Find 'Google' and click to expand"
echo "4. Click the toggle to enable Google"
echo "5. In 'Authorized redirect URIs', add:"
echo ""
echo "   http://localhost:3000"
echo "   http://localhost:8080"
echo "   io.supabase.agriflutter://login-callback/"
echo ""
echo "   Plus your production domain like:"
echo "   https://yourdomain.com"
echo ""
echo "6. Click 'Save'"
echo ""

echo "STEP 3: REBUILD THE APP"
echo "------"
echo "Run these commands in terminal:"
echo ""
echo "cd /home/pk/Desktop/agriflutter"
echo "flutter clean"
echo "flutter pub get"
echo "flutter run"
echo ""

echo "=========================================="
echo "THAT'S IT! Auth should now work."
echo "=========================================="
echo ""
echo "Test by trying to:"
echo "  ✓ Create a new account with email"
echo "  ✓ Login with email"  
echo "  ✓ Sign in with Google (if configured)"
echo "  ✓ Complete profile with phone number"
echo ""
