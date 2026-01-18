-- Migration: Make phone_number optional to support email and Google auth
-- This allows users to sign up with email/Google without requiring a phone number upfront

BEGIN;

-- Make phone_number nullable and remove unique constraint
ALTER TABLE public.user_profiles 
ALTER COLUMN phone_number DROP NOT NULL;

-- Drop the unique constraint if it exists
ALTER TABLE public.user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_phone_number_key;

-- Add a unique constraint that allows multiple NULLs (PostgreSQL ignores NULLs in unique indexes)
ALTER TABLE public.user_profiles 
ADD CONSTRAINT user_profiles_phone_number_unique UNIQUE NULLS NOT DISTINCT (phone_number) WHERE phone_number IS NOT NULL;

-- Add is_profile_complete column if it doesn't exist
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS is_profile_complete BOOLEAN DEFAULT FALSE;

COMMIT;
