-- =============================================================================
-- AgriServe Database Schema
-- PostgreSQL with PostGIS Extension for Geospatial Agriculture Marketplace
-- =============================================================================

-- Enable PostGIS extension for geography types and spatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================================================
-- ENUMS
-- =============================================================================

-- User role types
CREATE TYPE user_role AS ENUM ('farmer', 'equipment_provider', 'labour_provider');

-- Booking status lifecycle
CREATE TYPE booking_status AS ENUM (
  'pending',      -- Initial request sent
  'accepted',     -- Provider approved
  'rejected',     -- Provider declined
  'in_progress',  -- Job started (OTP verified)
  'completed',    -- Job ended (OTP verified)
  'cancelled'     -- Either party cancelled
);

-- Payment states for escrow
CREATE TYPE payment_status AS ENUM (
  'pending',      -- Payment initiated
  'held',         -- Amount held in escrow
  'released',     -- Transferred to provider
  'refunded',     -- Returned to farmer
  'failed'        -- Payment error
);

-- Equipment categories
CREATE TYPE equipment_type AS ENUM (
  'tractor',
  'harvester',
  'seeder',
  'plough',
  'sprayer',
  'irrigation_pump',
  'thresher',
  'other'
);

-- Labour skill types
CREATE TYPE labour_skill AS ENUM (
  'tractor_operator',
  'harvesting',
  'crop_spraying',
  'irrigation_management',
  'soil_preparation',
  'general_farm_work',
  'veterinary',
  'other'
);

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- User Profiles: Multi-role system where users can be both farmers and providers
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone_number VARCHAR(15) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  
  -- Multi-role support
  active_role user_role NOT NULL DEFAULT 'farmer',
  enabled_roles user_role[] NOT NULL DEFAULT ARRAY['farmer']::user_role[],
  
  -- Location data (user's primary address)
  location GEOGRAPHY(Point, 4326),  -- WGS84 coordinates
  address_text TEXT,
  district VARCHAR(100),
  state VARCHAR(100),
  
  -- Profile metadata
  profile_image_url TEXT,
  preferred_language VARCHAR(10) DEFAULT 'en',  -- 'en' or 'hi'
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Equipment Listings: Agricultural machinery available for rent
CREATE TABLE equipment_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  
  -- Equipment details
  equipment_type equipment_type NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  brand VARCHAR(100),
  model VARCHAR(100),
  manufacturing_year INTEGER,
  
  -- Geospatial data
  location GEOGRAPHY(Point, 4326) NOT NULL,  -- Current parking/storage location
  service_radius_km NUMERIC(6,2) NOT NULL CHECK (service_radius_km > 0 AND service_radius_km <= 200),
  
  -- Pricing
  hourly_rate NUMERIC(10,2) NOT NULL CHECK (hourly_rate > 0),
  daily_rate NUMERIC(10,2),
  
  -- Images (Cloudinary URLs)
  images TEXT[],
  primary_image_url TEXT,
  
  -- Availability & ratings
  is_available BOOLEAN DEFAULT TRUE,
  total_bookings INTEGER DEFAULT 0,
  average_rating NUMERIC(3,2) DEFAULT 0.0 CHECK (average_rating >= 0 AND average_rating <= 5),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Labour Profiles: Skilled workers available for hire
CREATE TABLE labour_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  
  -- Labour details
  skills labour_skill[] NOT NULL,
  experience_years INTEGER CHECK (experience_years >= 0),
  bio TEXT,
  
  -- Geospatial data
  location GEOGRAPHY(Point, 4326) NOT NULL,  -- Home/base location
  service_radius_km NUMERIC(6,2) NOT NULL CHECK (service_radius_km > 0 AND service_radius_km <= 200),
  
  -- Pricing
  daily_rate NUMERIC(10,2) NOT NULL CHECK (daily_rate > 0),
  hourly_rate NUMERIC(10,2),
  
  -- Profile image
  profile_image_url TEXT,
  
  -- Availability & ratings
  is_available BOOLEAN DEFAULT TRUE,
  total_bookings INTEGER DEFAULT 0,
  average_rating NUMERIC(3,2) DEFAULT 0.0 CHECK (average_rating >= 0 AND average_rating <= 5),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)  -- One labour profile per user
);

-- Bookings: Complete lifecycle tracking
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Parties involved
  farmer_id UUID NOT NULL REFERENCES user_profiles(id),
  provider_id UUID NOT NULL REFERENCES user_profiles(id),
  
  -- Service details (polymorphic - either equipment OR labour)
  equipment_id UUID REFERENCES equipment_listings(id) ON DELETE CASCADE,
  labour_id UUID REFERENCES labour_profiles(id) ON DELETE CASCADE,
  
  -- Location (farmer's field coordinates)
  job_location GEOGRAPHY(Point, 4326) NOT NULL,
  job_address TEXT NOT NULL,
  
  -- Scheduling
  requested_start_date DATE NOT NULL,
  requested_end_date DATE,
  actual_start_time TIMESTAMPTZ,
  actual_end_time TIMESTAMPTZ,
  
  -- Pricing
  agreed_rate NUMERIC(10,2) NOT NULL,
  rate_unit VARCHAR(20) NOT NULL,  -- 'hourly', 'daily', 'fixed'
  total_amount NUMERIC(10,2),
  
  -- Status tracking
  status booking_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  cancellation_reason TEXT,
  
  -- Farmer notes
  special_instructions TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraint: Must have either equipment OR labour, not both
  CONSTRAINT valid_service CHECK (
    (equipment_id IS NOT NULL AND labour_id IS NULL) OR
    (equipment_id IS NULL AND labour_id IS NOT NULL)
  )
);

-- OTP Verifications: Secure job start/end verification
CREATE TABLE otp_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  
  -- OTP details
  otp_code VARCHAR(6) NOT NULL,
  otp_type VARCHAR(20) NOT NULL,  -- 'start_job' or 'end_job'
  
  -- Verification state
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL,
  
  -- Who receives and who verifies
  sent_to_user_id UUID NOT NULL REFERENCES user_profiles(id),
  verified_by_user_id UUID REFERENCES user_profiles(id),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments: Razorpay escrow tracking
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  
  -- Razorpay transaction data
  razorpay_payment_id VARCHAR(100) UNIQUE,
  razorpay_order_id VARCHAR(100),
  razorpay_signature VARCHAR(255),
  
  -- Payment details
  amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) DEFAULT 'INR',
  
  -- Escrow state
  status payment_status NOT NULL DEFAULT 'pending',
  held_at TIMESTAMPTZ,
  released_at TIMESTAMPTZ,
  
  -- Transfer details (when released)
  razorpay_transfer_id VARCHAR(100),
  provider_account_id VARCHAR(100),
  
  -- Metadata
  failure_reason TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews: Rating and feedback system
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  
  -- Review details
  reviewer_id UUID NOT NULL REFERENCES user_profiles(id),
  reviewee_id UUID NOT NULL REFERENCES user_profiles(id),
  
  -- Rating (1-5 stars)
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  
  -- Feedback text
  comment TEXT,
  
  -- Service-specific ratings
  punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
  quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(booking_id, reviewer_id)  -- One review per user per booking
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Geospatial indexes (GIST for geography types)
CREATE INDEX idx_equipment_location ON equipment_listings USING GIST(location);
CREATE INDEX idx_labour_location ON labour_profiles USING GIST(location);
CREATE INDEX idx_user_location ON user_profiles USING GIST(location);

-- Booking queries
CREATE INDEX idx_bookings_farmer ON bookings(farmer_id, status, created_at DESC);
CREATE INDEX idx_bookings_provider ON bookings(provider_id, status, created_at DESC);
CREATE INDEX idx_bookings_equipment ON bookings(equipment_id) WHERE equipment_id IS NOT NULL;
CREATE INDEX idx_bookings_labour ON bookings(labour_id) WHERE labour_id IS NOT NULL;

-- Equipment search filters
CREATE INDEX idx_equipment_type ON equipment_listings(equipment_type, is_available);
CREATE INDEX idx_equipment_rating ON equipment_listings(average_rating DESC) WHERE is_available = TRUE;

-- Labour search filters
CREATE INDEX idx_labour_skills ON labour_profiles USING GIN(skills);
CREATE INDEX idx_labour_rating ON labour_profiles(average_rating DESC) WHERE is_available = TRUE;

-- OTP lookups
CREATE INDEX idx_otp_booking ON otp_verifications(booking_id, otp_type, is_verified);

-- Payment tracking
CREATE INDEX idx_payment_booking ON payments(booking_id);
CREATE INDEX idx_payment_razorpay ON payments(razorpay_payment_id) WHERE razorpay_payment_id IS NOT NULL;

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE labour_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE otp_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- User Profiles Policies
CREATE POLICY "Users can view all profiles" ON user_profiles
  FOR SELECT USING (TRUE);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Equipment Listings Policies
CREATE POLICY "Anyone can view available equipment" ON equipment_listings
  FOR SELECT USING (is_available = TRUE OR owner_id = auth.uid());

CREATE POLICY "Owners can insert equipment" ON equipment_listings
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update own equipment" ON equipment_listings
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete own equipment" ON equipment_listings
  FOR DELETE USING (auth.uid() = owner_id);

-- Labour Profiles Policies
CREATE POLICY "Anyone can view available labour" ON labour_profiles
  FOR SELECT USING (is_available = TRUE OR user_id = auth.uid());

CREATE POLICY "Users can insert own labour profile" ON labour_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own labour profile" ON labour_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own labour profile" ON labour_profiles
  FOR DELETE USING (auth.uid() = user_id);

-- Bookings Policies
CREATE POLICY "Users can view own bookings" ON bookings
  FOR SELECT USING (auth.uid() = farmer_id OR auth.uid() = provider_id);

CREATE POLICY "Farmers can create bookings" ON bookings
  FOR INSERT WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Involved parties can update bookings" ON bookings
  FOR UPDATE USING (auth.uid() = farmer_id OR auth.uid() = provider_id);

-- OTP Verifications Policies
CREATE POLICY "Users can view own OTPs" ON otp_verifications
  FOR SELECT USING (
    auth.uid() = sent_to_user_id OR 
    auth.uid() = verified_by_user_id OR
    auth.uid() IN (
      SELECT farmer_id FROM bookings WHERE id = booking_id
      UNION
      SELECT provider_id FROM bookings WHERE id = booking_id
    )
  );

CREATE POLICY "System can insert OTPs" ON otp_verifications
  FOR INSERT WITH CHECK (TRUE);  -- Only via backend Edge Functions

CREATE POLICY "Recipients can verify OTPs" ON otp_verifications
  FOR UPDATE USING (auth.uid() = verified_by_user_id);

-- Payments Policies
CREATE POLICY "Involved parties can view payments" ON payments
  FOR SELECT USING (
    auth.uid() IN (
      SELECT farmer_id FROM bookings WHERE id = booking_id
      UNION
      SELECT provider_id FROM bookings WHERE id = booking_id
    )
  );

CREATE POLICY "System can manage payments" ON payments
  FOR ALL USING (TRUE);  -- Only via backend Edge Functions

-- Reviews Policies
CREATE POLICY "Anyone can view reviews" ON reviews
  FOR SELECT USING (TRUE);

CREATE POLICY "Reviewers can insert reviews" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

CREATE POLICY "Reviewers can update own reviews" ON reviews
  FOR UPDATE USING (auth.uid() = reviewer_id);

-- =============================================================================
-- FUNCTIONS & TRIGGERS
-- =============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_listings_updated_at
  BEFORE UPDATE ON equipment_listings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_labour_profiles_updated_at
  BEFORE UPDATE ON labour_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
  BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Update average ratings after review
CREATE OR REPLACE FUNCTION update_average_rating()
RETURNS TRIGGER AS $$
BEGIN
  -- Update equipment rating
  IF EXISTS (
    SELECT 1 FROM bookings 
    WHERE id = NEW.booking_id AND equipment_id IS NOT NULL
  ) THEN
    UPDATE equipment_listings
    SET average_rating = (
      SELECT COALESCE(AVG(r.rating), 0)
      FROM reviews r
      INNER JOIN bookings b ON r.booking_id = b.id
      WHERE b.equipment_id = (
        SELECT equipment_id FROM bookings WHERE id = NEW.booking_id
      )
    )
    WHERE id = (SELECT equipment_id FROM bookings WHERE id = NEW.booking_id);
  END IF;
  
  -- Update labour rating
  IF EXISTS (
    SELECT 1 FROM bookings 
    WHERE id = NEW.booking_id AND labour_id IS NOT NULL
  ) THEN
    UPDATE labour_profiles
    SET average_rating = (
      SELECT COALESCE(AVG(r.rating), 0)
      FROM reviews r
      INNER JOIN bookings b ON r.booking_id = b.id
      WHERE b.labour_id = (
        SELECT labour_id FROM bookings WHERE id = NEW.booking_id
      )
    )
    WHERE id = (SELECT labour_id FROM bookings WHERE id = NEW.booking_id);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_rating
  AFTER INSERT OR UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_average_rating();

-- Function: Geospatial search for equipment within service radius
CREATE OR REPLACE FUNCTION search_equipment_nearby(
  farmer_lat DOUBLE PRECISION,
  farmer_lng DOUBLE PRECISION,
  equipment_filter equipment_type DEFAULT NULL,
  min_rating NUMERIC DEFAULT 0,
  max_hourly_rate NUMERIC DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  equipment_type equipment_type,
  hourly_rate NUMERIC,
  average_rating NUMERIC,
  distance_km NUMERIC,
  owner_name VARCHAR,
  primary_image_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.id,
    e.title,
    e.equipment_type,
    e.hourly_rate,
    e.average_rating,
    ST_Distance(
      e.location::geography,
      ST_SetSRID(ST_MakePoint(farmer_lng, farmer_lat), 4326)::geography
    ) / 1000 AS distance_km,
    u.full_name AS owner_name,
    e.primary_image_url
  FROM equipment_listings e
  INNER JOIN user_profiles u ON e.owner_id = u.id
  WHERE 
    e.is_available = TRUE
    AND ST_DWithin(
      e.location::geography,
      ST_SetSRID(ST_MakePoint(farmer_lng, farmer_lat), 4326)::geography,
      e.service_radius_km * 1000  -- Convert km to meters
    )
    AND (equipment_filter IS NULL OR e.equipment_type = equipment_filter)
    AND e.average_rating >= min_rating
    AND (max_hourly_rate IS NULL OR e.hourly_rate <= max_hourly_rate)
  ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- Function: Geospatial search for labour within service radius
CREATE OR REPLACE FUNCTION search_labour_nearby(
  farmer_lat DOUBLE PRECISION,
  farmer_lng DOUBLE PRECISION,
  skill_filter labour_skill DEFAULT NULL,
  min_rating NUMERIC DEFAULT 0,
  max_daily_rate NUMERIC DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  skills labour_skill[],
  daily_rate NUMERIC,
  average_rating NUMERIC,
  distance_km NUMERIC,
  worker_name VARCHAR,
  profile_image_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.user_id,
    l.skills,
    l.daily_rate,
    l.average_rating,
    ST_Distance(
      l.location::geography,
      ST_SetSRID(ST_MakePoint(farmer_lng, farmer_lat), 4326)::geography
    ) / 1000 AS distance_km,
    u.full_name AS worker_name,
    l.profile_image_url
  FROM labour_profiles l
  INNER JOIN user_profiles u ON l.user_id = u.id
  WHERE 
    l.is_available = TRUE
    AND ST_DWithin(
      l.location::geography,
      ST_SetSRID(ST_MakePoint(farmer_lng, farmer_lat), 4326)::geography,
      l.service_radius_km * 1000
    )
    AND (skill_filter IS NULL OR skill_filter = ANY(l.skills))
    AND l.average_rating >= min_rating
    AND (max_daily_rate IS NULL OR l.daily_rate <= max_daily_rate)
  ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- SAMPLE DATA FOR TESTING (Optional - Comment out for production)
-- =============================================================================

-- Note: Insert test data after setting up Supabase Auth users
-- Example:
-- INSERT INTO user_profiles (id, phone_number, full_name, location, active_role, enabled_roles)
-- VALUES (
--   'user-uuid-from-auth',
--   '+919876543210',
--   'Rajesh Kumar',
--   ST_SetSRID(ST_MakePoint(77.5946, 12.9716), 4326)::geography,
--   'farmer',
--   ARRAY['farmer', 'equipment_provider']::user_role[]
-- );

-- =============================================================================
-- COMPLETION MESSAGE
-- =============================================================================
DO $$
BEGIN
  RAISE NOTICE '✓ AgriServe database schema created successfully!';
  RAISE NOTICE '✓ PostGIS extension enabled';
  RAISE NOTICE '✓ Row Level Security policies configured';
  RAISE NOTICE '✓ Geospatial search functions ready';
  RAISE NOTICE 'Next: Configure Supabase Auth and create test users';
END $$;
