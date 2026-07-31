-- LEGACY REFERENCE ONLY. Use the timestamped files in supabase/migrations.
-- ============================================================
-- CropID Supabase Schema
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- Requires: PostGIS extension (enabled by default on Supabase)
-- ============================================================

-- Enable PostGIS for geospatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- ── Profiles ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email                 TEXT NOT NULL,
  full_name             TEXT NOT NULL,
  phone_number          TEXT,
  farm_name             TEXT,
  farm_latitude         DOUBLE PRECISION,
  farm_longitude        DOUBLE PRECISION,
  avatar_url            TEXT,
  field_sharing_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ── Crops ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS crops (
  id                TEXT PRIMARY KEY,   -- e.g. 'corn', 'soybeans'
  name              TEXT NOT NULL,
  scientific_name   TEXT,
  icon_url          TEXT,
  sensitive_to      TEXT[] DEFAULT '{}',  -- array of chemical_id strings
  tags              TEXT[] DEFAULT '{}'
);

-- ── Fields ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fields (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farmer_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  -- PostGIS geometry for accurate spatial queries
  boundary        GEOGRAPHY(POLYGON, 4326),
  -- Fallback JSON for client-side polygon rendering
  boundary_points JSONB DEFAULT '[]',
  current_crop_id TEXT REFERENCES crops(id),
  current_crop_name TEXT,     -- denormalized for quick reads
  visibility      TEXT NOT NULL DEFAULT 'private'
                    CHECK (visibility IN ('private', 'anonymous', 'public')),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial index for fast proximity queries
CREATE INDEX IF NOT EXISTS idx_fields_boundary ON fields USING GIST (boundary);
CREATE INDEX IF NOT EXISTS idx_fields_farmer ON fields (farmer_id);
CREATE INDEX IF NOT EXISTS idx_fields_visibility ON fields (visibility);

-- ── PostGIS helper: fields within radius ────────────────────────────────────
CREATE OR REPLACE FUNCTION fields_within_radius(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_m DOUBLE PRECISION DEFAULT 500
)
RETURNS SETOF fields AS $$
  SELECT * FROM fields
  WHERE visibility != 'private'
    AND ST_DWithin(
      boundary::geography,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
      radius_m
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ── Chemicals ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chemicals (
  id                           TEXT PRIMARY KEY,
  name                         TEXT NOT NULL,
  common_name                  TEXT,
  manufacturer                 TEXT,
  toxicity_level               TEXT NOT NULL DEFAULT 'moderate'
                                 CHECK (toxicity_level IN ('low','moderate','high','extreme')),
  dangerous_to_crop_ids        TEXT[] DEFAULT '{}',
  dangerous_to_crop_names      TEXT[] DEFAULT '{}',
  incompatible_with_chemical_ids TEXT[] DEFAULT '{}',
  withdrawal_period_days       TEXT,
  notes                        TEXT
);

-- ── Spray Plans ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS spray_plans (
  id                            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farmer_id                     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  field_id                      UUID NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
  field_name                    TEXT,
  status                        TEXT NOT NULL DEFAULT 'draft'
                                  CHECK (status IN ('draft','scheduled','completed','cancelled')),
  dangerous_adjacent_field_ids  UUID[] DEFAULT '{}',
  notes                         TEXT,
  scheduled_date                DATE,
  created_at                    TIMESTAMPTZ DEFAULT NOW()
);

-- ── Spray Plan Chemicals (junction) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS spray_plan_chemicals (
  spray_plan_id UUID NOT NULL REFERENCES spray_plans(id) ON DELETE CASCADE,
  chemical_id   TEXT NOT NULL REFERENCES chemicals(id),
  PRIMARY KEY (spray_plan_id, chemical_id)
);

-- ── Danger Notifications ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS danger_notifications (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_farmer_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sender_farmer_id         UUID NOT NULL REFERENCES profiles(id),
  spray_plan_id            UUID NOT NULL REFERENCES spray_plans(id),
  affected_field_id        UUID NOT NULL REFERENCES fields(id),
  affected_field_name      TEXT,
  sender_farm_name         TEXT,
  dangerous_chemical_names TEXT[] DEFAULT '{}',
  spray_scheduled_date     DATE,
  is_read                  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at               TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifs_recipient ON danger_notifications (recipient_farmer_id);
CREATE INDEX IF NOT EXISTS idx_notifs_unread ON danger_notifications (recipient_farmer_id, is_read);

-- ── Crop Duster Services ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS crop_duster_services (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                 TEXT NOT NULL,
  phone                TEXT NOT NULL,
  email                TEXT,
  website              TEXT,
  latitude             DOUBLE PRECISION,
  longitude            DOUBLE PRECISION,
  address              TEXT,
  state                TEXT,
  service_radius_miles INTEGER,
  location             GEOGRAPHY(POINT, 4326),
  is_active            BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_cropdusters_location ON crop_duster_services USING GIST (location);

-- ── Row Level Security ────────────────────────────────────────────────────────
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE spray_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE danger_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_duster_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE chemicals ENABLE ROW LEVEL SECURITY;
ALTER TABLE crops ENABLE ROW LEVEL SECURITY;

-- Profiles: users see/edit only their own profile
CREATE POLICY "profiles_own" ON profiles
  FOR ALL USING (auth.uid() = id);

-- Fields: farmers manage their own; others see non-private fields
CREATE POLICY "fields_own_manage" ON fields
  FOR ALL USING (auth.uid() = farmer_id);

CREATE POLICY "fields_public_read" ON fields
  FOR SELECT USING (visibility != 'private');

-- Spray plans: own only
CREATE POLICY "spray_plans_own" ON spray_plans
  FOR ALL USING (auth.uid() = farmer_id);

-- Notifications: recipients read their own; system inserts
CREATE POLICY "notifs_read_own" ON danger_notifications
  FOR SELECT USING (auth.uid() = recipient_farmer_id);

CREATE POLICY "notifs_update_own" ON danger_notifications
  FOR UPDATE USING (auth.uid() = recipient_farmer_id);

-- Chemicals and crops: public read-only
CREATE POLICY "chemicals_read" ON chemicals FOR SELECT USING (true);
CREATE POLICY "crops_read" ON crops FOR SELECT USING (true);

-- Crop duster services: public read-only
CREATE POLICY "cropdusters_read" ON crop_duster_services
  FOR SELECT USING (is_active = true);

-- ── Realtime ──────────────────────────────────────────────────────────────────
-- Enable realtime for key tables in Supabase Dashboard:
-- Database → Replication → enable for: fields, danger_notifications
