-- Fix: Create user_profiles table that aligns with the application code
-- This migration ensures the table name matches the application's expectations

-- Drop all dependent tables first to avoid constraint violations
DROP TABLE IF EXISTS public.bookings CASCADE;
DROP TABLE IF EXISTS public.equipment_listings CASCADE;
DROP TABLE IF EXISTS public.labour_profiles CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- Create the user_profiles table as expected by the application
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    
    -- Multi-role support
    active_role TEXT NOT NULL DEFAULT 'farmer',
    enabled_roles TEXT[] NOT NULL DEFAULT ARRAY['farmer'],
    
    -- Location data (user's primary address)
    location GEOGRAPHY(Point, 4326),
    address_text TEXT,
    district VARCHAR(100),
    state VARCHAR(100),
    
    -- Profile metadata
    profile_image_url TEXT,
    preferred_language VARCHAR(10) DEFAULT 'en',
    is_profile_complete BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create equipment_listings table
CREATE TABLE public.equipment_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Equipment details
    equipment_type TEXT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    model VARCHAR(100),
    manufacturing_year INTEGER,
    
    -- Location and pricing
    location GEOGRAPHY(Point, 4326),
    address_text TEXT,
    hourly_rate NUMERIC(10, 2),
    daily_rate NUMERIC(10, 2),
    monthly_rate NUMERIC(10, 2),
    
    -- Images and status
    images TEXT[] DEFAULT '{}',
    is_available BOOLEAN DEFAULT TRUE,
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create labour_profiles table
CREATE TABLE public.labour_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Labour details
    skills TEXT[] DEFAULT '{}',
    hourly_rate NUMERIC(10, 2),
    service_radius_km INTEGER DEFAULT 25,
    
    -- Location
    location GEOGRAPHY(Point, 4326),
    address_text TEXT,
    
    -- Availability
    is_available BOOLEAN DEFAULT TRUE,
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create bookings table
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booker_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    equipment_id UUID REFERENCES public.equipment_listings(id) ON DELETE SET NULL,
    labour_id UUID REFERENCES public.labour_profiles(id) ON DELETE SET NULL,
    
    -- Booking details
    booking_type TEXT NOT NULL, -- 'equipment' or 'labour'
    status TEXT DEFAULT 'pending',
    
    -- Dates
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    
    -- Pricing
    total_amount NUMERIC(10, 2),
    payment_status TEXT DEFAULT 'pending',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS policies
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.labour_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Anyone can view equipment listings" ON public.equipment_listings;
DROP POLICY IF EXISTS "Users can insert their own equipment" ON public.equipment_listings;
DROP POLICY IF EXISTS "Users can update their own equipment" ON public.equipment_listings;
DROP POLICY IF EXISTS "Anyone can view labour profiles" ON public.labour_profiles;

-- Create RLS policies for user_profiles
CREATE POLICY "Users can view all profiles" ON public.user_profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Create RLS policies for equipment_listings
CREATE POLICY "Anyone can view equipment listings" ON public.equipment_listings
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own equipment" ON public.equipment_listings
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own equipment" ON public.equipment_listings
    FOR UPDATE USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Create RLS policies for labour_profiles
CREATE POLICY "Anyone can view labour profiles" ON public.labour_profiles
    FOR SELECT USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_equipment_owner ON public.equipment_listings(owner_id);
CREATE INDEX IF NOT EXISTS idx_equipment_location ON public.equipment_listings USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_labour_user ON public.labour_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_labour_location ON public.labour_profiles USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_bookings_booker ON public.bookings(booker_id);
