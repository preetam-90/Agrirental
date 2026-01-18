-- Phase 2: Core Marketplace Architecture & Geospatial Engine
-- Run this script in your Supabase SQL Editor

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Create Role Enum if not exists
DO $$ BEGIN
    CREATE TYPE user_role_v2 AS ENUM ('farmer', 'provider');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone_number TEXT,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    current_role user_role_v2 DEFAULT 'farmer',
    location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create equipment_listings table
CREATE TABLE IF NOT EXISTS equipment_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT NOT NULL, -- Tractor, Harvester, etc.
    hourly_rate NUMERIC NOT NULL,
    description TEXT,
    images TEXT[] DEFAULT '{}',
    location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create labour_profiles table
CREATE TABLE IF NOT EXISTS labour_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    skills TEXT[] DEFAULT '{}',
    hourly_rate NUMERIC NOT NULL,
    service_radius_km INTEGER DEFAULT 25,
    home_location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 5. RPC Function: search_nearby_items
CREATE OR REPLACE FUNCTION search_nearby_items(
    user_lat DOUBLE PRECISION,
    user_long DOUBLE PRECISION,
    radius_km DOUBLE PRECISION,
    item_type TEXT -- 'equipment' or 'labour'
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    category_or_skills TEXT,
    rate NUMERIC,
    distance_km DOUBLE PRECISION,
    location_geog GEOGRAPHY
) AS $$
BEGIN
    IF item_type = 'equipment' THEN
        RETURN QUERY
        SELECT 
            el.id,
            el.name,
            el.category as category_or_skills,
            el.hourly_rate as rate,
            ST_Distance(el.location, ST_SetSRID(ST_Point(user_long, user_lat), 4326)::geography) / 1000 as distance_km,
            el.location as location_geog
        FROM equipment_listings el
        WHERE ST_DWithin(el.location, ST_SetSRID(ST_Point(user_long, user_lat), 4326)::geography, radius_km * 1000)
        ORDER BY distance_km;
    ELSIF item_type = 'labour' THEN
        RETURN QUERY
        SELECT 
            lp.id,
            p.full_name as name,
            array_to_string(lp.skills, ', ') as category_or_skills,
            lp.hourly_rate as rate,
            ST_Distance(lp.home_location, ST_SetSRID(ST_Point(user_long, user_lat), 4326)::geography) / 1000 as distance_km,
            lp.home_location as location_geog
        FROM labour_profiles lp
        JOIN profiles p ON lp.user_id = p.id
        WHERE ST_DWithin(lp.home_location, ST_SetSRID(ST_Point(user_long, user_lat), 4326)::geography, radius_km * 1000)
        ORDER BY distance_km;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 6. Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE labour_profiles ENABLE ROW LEVEL SECURITY;

-- 7. Policies (Basic open policies for development, refine for production)
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Equipment listings are viewable by everyone" ON equipment_listings FOR SELECT USING (true);
CREATE POLICY "Users can insert their own equipment" ON equipment_listings FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owners can update own equipment" ON equipment_listings FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Labour profiles are viewable by everyone" ON labour_profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own labour profile" ON labour_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own labour profile" ON labour_profiles FOR UPDATE USING (auth.uid() = user_id);
