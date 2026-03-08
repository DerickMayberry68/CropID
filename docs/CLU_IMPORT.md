# Field Boundary Import Plan

## Data Sources — What's Actually Available

### USDA FSA Common Land Unit (CLU) — Restricted

The CLU is the authoritative farm field boundary dataset maintained by FSA. It includes
field geometry linked to farm/tract numbers from the FSA program enrollment system.

**Access status:** CLU is NOT public. Congress restricted it in 2008 to FSA and
authorized agency partnerships only. It is not downloadable from the Geospatial Data
Gateway or any public source.

**How to obtain:** Contact your local FSA state office directly and inquire about a
**data sharing agreement**. Some agtech companies have obtained CLU under cooperative
agreements. If pursuing a purchase, ask specifically:
- Does the data include producer contact information, or only geometry + farm/tract numbers?
- Producer PII (names, phone numbers, emails) lives in FSA's SCIMS system and is
  separately restricted — CLU geometry alone does not tell you who to notify.

### USDA NASS Crop Sequence Boundaries (CSB) — Free, Public Domain

CSB is derived from public Cropland Data Layer (CDL) rasters + TIGER road/rail lines
using an open algorithm. It approximates field boundaries based on where crops were
historically grown.

- **URL:** https://www.nass.usda.gov/Research_and_Science/Crop-Sequence-Boundaries/
- **License:** Public domain, free to redistribute
- **Coverage:** ~16 million field boundaries nationwide, updated annually
- **Format:** Shapefile / GeoJSON, downloadable by state
- **Latest release:** 2017–2024 dataset released March 2025
- **Limitation:** Geometry-only — no ownership, no farmer contact info

**Use case for CropID:** Show CSB boundaries as a "claim a field" discovery layer.
Farmers tap an existing boundary instead of drawing from scratch. Works well enough
for geometry; ownership is handled by the CropID registration model (see below).

### USDA NASS Cropland Data Layer (CDL) — Free, Raster

30-meter resolution raster showing crop type per pixel going back to 2008. Not field
boundaries, but useful for pre-populating `current_crop` when a field is claimed and
for showing historical crop rotation data on adjacent fields.

- **URL:** https://www.nass.usda.gov/Research_and_Science/Cropland/
- **API:** CropScape / CroplandCROS for programmatic lookups by coordinate

---

## Ownership Architecture

### The Core Problem

Neither CSB nor CLU (even if obtained) solves the "who do I notify?" problem.
CLU links to FSA farm/tract numbers, not phone numbers or emails. Producer contact
data is in SCIMS and is not for sale.

### The Solution: Network-Effect Ownership Model

CropID owns the ownership layer. A field has a registered owner only when a farmer
has claimed it in the app. This is the standard model for every agtech platform
that does spray/drift notifications (Climate Corp, Granular, etc.).

```
fields table
├── id
├── farmer_id          ← NULL until a CropID user claims the field
├── csb_id             ← FK to csb_fields if claimed from CSB boundary
├── clu_id             ← FK to clu_fields if CLU data is ever obtained
├── boundary           ← GEOGRAPHY POLYGON (drawn or imported)
├── boundary_points    ← JSONB for client-side rendering
└── ...
```

**Spray notification logic:**
- Adjacent field has `farmer_id` set → notify that CropID user
- Adjacent field has no `farmer_id` → flag as "Unknown owner — notification not sent"
  in the spray plan danger report

**Business implication:** CropID becomes more valuable as more farmers in a region
sign up. Notification coverage is a direct function of platform adoption. This is
a feature, not a limitation — it's the core growth driver.

---

## Recommended Import Architecture

### Step 1 — CSB import table

```sql
CREATE TABLE csb_fields (
  csb_id        TEXT PRIMARY KEY,        -- USDA CSB identifier
  state         TEXT NOT NULL,           -- 'AR'
  county_fips   TEXT NOT NULL,
  boundary      GEOGRAPHY(POLYGON, 4326) NOT NULL,
  boundary_points JSONB DEFAULT '[]',    -- for client-side rendering
  acres         NUMERIC(10,2),
  crop_year     INTEGER                  -- CSB vintage year
);

CREATE INDEX idx_csb_boundary ON csb_fields USING GIST (boundary);
CREATE INDEX idx_csb_state_county ON csb_fields (state, county_fips);
```

If CLU data is later obtained, add a `clu_fields` table with the same structure
plus `farm_number TEXT` and `tract_number TEXT` columns.

### Step 2 — RPC for "find boundaries near me"

```sql
CREATE OR REPLACE FUNCTION csb_fields_near(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_m DOUBLE PRECISION DEFAULT 1000
)
RETURNS SETOF csb_fields AS $$
  SELECT * FROM csb_fields
  WHERE ST_DWithin(
    boundary::geography,
    ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
    radius_m
  );
$$ LANGUAGE sql STABLE;
```

### Step 3 — Shapefile → PostGIS import

```bash
# Requires GDAL (ogr2ogr)
ogr2ogr -f "PostgreSQL" \
  PG:"host=db.vwyeasxwrwejlxyydjnf.supabase.co user=postgres password=YOUR_PW dbname=postgres" \
  CSB_Arkansas.shp \
  -nln csb_fields \
  -nlt POLYGON \
  -t_srs EPSG:4326
```

Then run a migration to populate `boundary_points` JSONB from the PostGIS geometry
for efficient client-side rendering without needing ST_AsGeoJSON on every request.

### Step 4 — "Claim a field" flow in the app

1. App calls `csb_fields_near` with farmer's GPS location
2. CSB boundaries render as a faint blue outline layer on the map
3. Farmer taps a CSB boundary → bottom sheet: "Claim this field as yours?"
4. On confirm → create a `fields` row stamped with `farmer_id` and `csb_id`
5. Copy `boundary_points` from `csb_fields` into the new `fields` row
6. Field transitions from ghost outline to solid colored polygon on the map

---

## Flutter App Changes Needed (Phase 5)

- [ ] New provider: `csbFieldsNearProvider` — calls `csb_fields_near` RPC
- [ ] New map layer in `FarmMapScreen` — renders CSB boundaries as faint blue outlines
- [ ] New screen: `ClaimFieldScreen` — "Tap your fields to claim them" onboarding flow
- [ ] Update `DrawFieldScreen` — offer "Draw manually" vs "Select from map" options
- [ ] `fields` table: add `csb_id` and `clu_id` FK columns (migration)
- [ ] Spray plan danger report: show "Unknown owner" for unclaimed adjacent fields

---

## CLU Procurement Checklist (when pursuing FSA agreement)

- [ ] Contact Arkansas FSA State Office — ask about data sharing agreement for agtech use
- [ ] Confirm whether delivery includes geometry only or geometry + farm/tract numbers
- [ ] Confirm SCIMS producer contact data is separately restricted (it is)
- [ ] If geometry + farm/tract numbers only: plan manual outreach strategy or
      in-app "Is this your field?" invitation campaign to drive CLU field registration
- [ ] Evaluate whether CLU geometry is materially better than CSB for Arkansas
      (CLU is ownership-bounded, CSB is crop-activity-bounded — meaningful difference
      for irregular or multi-crop parcels)
