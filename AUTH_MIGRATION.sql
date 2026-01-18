-- ============================================================================
-- SUPABASE MIGRATION: Fix Authentication Issues
-- ============================================================================
-- This migration fixes the database schema to support email and Google auth
-- without requiring a phone number upfront
--
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================================================

BEGIN;

-- Make phone_number optional (currently NOT NULL, causing signup to fail)
ALTER TABLE public.user_profiles 
ALTER COLUMN phone_number DROP NOT NULL;

-- Remove old unique constraint that was causing issues
ALTER TABLE public.user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_phone_number_key;

-- Add proper unique constraint that allows multiple NULLs
-- This allows users to not have phone numbers when signing up via email/Google
-- but ensures phone numbers are unique when provided
ALTER TABLE public.user_profiles 
ADD CONSTRAINT user_profiles_phone_number_unique UNIQUE NULLS NOT DISTINCT (phone_number) WHERE phone_number IS NOT NULL;

-- Add is_profile_complete flag if missing
-- Used to track if user completed their profile setup
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS is_profile_complete BOOLEAN DEFAULT FALSE;

COMMIT;

-- ============================================================================
-- Verify changes
-- ============================================================================
-- After running this, check:
-- SELECT column_name, is_nullable FROM information_schema.columns 
-- WHERE table_name = 'user_profiles';
-- 
-- phone_number should show: YES (nullable)
-- ============================================================================
