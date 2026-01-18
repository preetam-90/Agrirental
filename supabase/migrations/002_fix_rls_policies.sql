-- Fix RLS policies for user_profiles table
-- This allows authenticated users to read and update their own profiles

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;

-- Create new policies with proper permissions

-- Allow authenticated users to view all profiles (for discovery/search)
CREATE POLICY "Authenticated users can view all profiles"
  ON user_profiles
  FOR SELECT
  TO authenticated
  USING (TRUE);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
  ON user_profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON user_profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow users to delete their own profile (optional, but good practice)
CREATE POLICY "Users can delete own profile"
  ON user_profiles
  FOR DELETE
  TO authenticated
  USING (auth.uid() = id);
