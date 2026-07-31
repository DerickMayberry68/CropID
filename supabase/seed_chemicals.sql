-- ============================================================
-- CropID — Seed Data: Chemicals and Common Crops
-- ============================================================

-- ── Common crops ─────────────────────────────────────────────
INSERT INTO crops (id, name, scientific_name, tags) VALUES
  ('corn',        'Corn',             'Zea mays',             ARRAY['grain','broadleaf']),
  ('soybeans',    'Soybeans',         'Glycine max',          ARRAY['legume','broadleaf']),
  ('wheat',       'Wheat',            'Triticum aestivum',    ARRAY['grain','grass']),
  ('cotton',      'Cotton',           'Gossypium hirsutum',   ARRAY['fiber']),
  ('canola',      'Canola',           'Brassica napus',       ARRAY['oilseed','broadleaf']),
  ('sunflower',   'Sunflower',        'Helianthus annuus',    ARRAY['oilseed','broadleaf']),
  ('sorghum',     'Sorghum',          'Sorghum bicolor',      ARRAY['grain','grass']),
  ('alfalfa',     'Alfalfa',          'Medicago sativa',      ARRAY['legume','forage']),
  ('potato',      'Potato',           'Solanum tuberosum',    ARRAY['vegetable','tuber']),
  ('sugar_beet',  'Sugar Beet',       'Beta vulgaris',        ARRAY['root','sugar'])
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  scientific_name = EXCLUDED.scientific_name,
  tags = EXCLUDED.tags;

-- ── Common herbicides / insecticides ─────────────────────────
INSERT INTO chemicals (id, name, common_name, toxicity_level,
    dangerous_to_crop_ids, dangerous_to_crop_names, notes) VALUES

  ('glyphosate', 'Glyphosate', 'Roundup', 'moderate',
    ARRAY['soybeans','canola','cotton','sugar_beet'],
    ARRAY['Soybeans','Canola','Cotton','Sugar Beet'],
    'Broad-spectrum herbicide. Drift can damage non-GMO broadleaf crops.'),

  ('atrazine', 'Atrazine', 'AAtrex', 'high',
    ARRAY['soybeans','sunflower','canola','alfalfa','potato'],
    ARRAY['Soybeans','Sunflower','Canola','Alfalfa','Potato'],
    'Corn herbicide. Significant drift risk to many crops. EPA restricted.'),

  ('dicamba', 'Dicamba', 'Banvel / Clarity', 'high',
    ARRAY['soybeans','cotton','sunflower','potato','canola'],
    ARRAY['Soybeans','Cotton','Sunflower','Potato','Canola'],
    'Extreme volatility and drift potential. Always notify neighbors.'),

  ('2-4d', '2,4-D', 'Weedone', 'moderate',
    ARRAY['soybeans','cotton','sunflower','grape'],
    ARRAY['Soybeans','Cotton','Sunflower'],
    'Broadleaf herbicide. Vapor drift in warm weather.'),

  ('chlorpyrifos', 'Chlorpyrifos', 'Lorsban', 'extreme',
    ARRAY['corn','soybeans','wheat','cotton'],
    ARRAY['Corn','Soybeans','Wheat','Cotton'],
    'Organophosphate insecticide. High toxicity to bees and birds.'),

  ('malathion', 'Malathion', 'Cythion', 'moderate',
    ARRAY['corn','soybeans','wheat'],
    ARRAY['Corn','Soybeans','Wheat'],
    'Broad-spectrum insecticide.'),

  ('paraquat', 'Paraquat', 'Gramoxone', 'extreme',
    ARRAY['corn','soybeans','wheat','cotton','alfalfa','potato'],
    ARRAY['Corn','Soybeans','Wheat','Cotton','Alfalfa','Potato'],
    'Contact herbicide. Restricted use. Lethal if drifts to green crops.'),

  ('imidacloprid', 'Imidacloprid', 'Admire Pro', 'moderate',
    ARRAY['sunflower','canola','alfalfa'],
    ARRAY['Sunflower','Canola','Alfalfa'],
    'Neonicotinoid. High toxicity to bees — avoid during bloom.'),

  ('pendimethalin', 'Pendimethalin', 'Prowl', 'low',
    ARRAY['soybeans','wheat'],
    ARRAY['Soybeans','Wheat'],
    'Pre-emergent herbicide. Low drift risk.'),

  ('propiconazole', 'Propiconazole', 'Tilt', 'low',
    ARRAY[]::text[],
    ARRAY[]::text[],
    'Fungicide. Generally low crop cross-contamination risk.')

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  common_name = EXCLUDED.common_name,
  toxicity_level = EXCLUDED.toxicity_level,
  dangerous_to_crop_ids = EXCLUDED.dangerous_to_crop_ids,
  dangerous_to_crop_names = EXCLUDED.dangerous_to_crop_names,
  notes = EXCLUDED.notes;

-- ── Sample crop duster services ─────────────────────────────
INSERT INTO crop_duster_services (
  id,
  name,
  phone,
  email,
  address,
  state,
  service_type,
  service_radius_miles,
  is_active
)
VALUES
  (
    '10000000-0000-4000-8000-000000000001',
    'Midwest AirSpray LLC',
    '555-0101',
    'info@midwestairspray.example',
    '100 Airfield Rd, Springfield, IL',
    'IL',
    'ag_air',
    150,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'Central Plains Aerial',
    '555-0202',
    'fly@centralplains.example',
    '45 Crop Way, Wichita, KS',
    'KS',
    'ag_air',
    200,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'Delta AgAir Services',
    '555-0303',
    NULL,
    '77 Hangar Ln, Memphis, TN',
    'TN',
    'ag_air',
    120,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000004',
    'High Plains Ag Aviation',
    '555-0404',
    'contact@highplains.example',
    '12 Skyway Blvd, Lubbock, TX',
    'TX',
    'ag_air',
    175,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000005',
    'Corn Belt Air Ag',
    '555-0505',
    'info@cornbeltair.example',
    '8 Spray Lane, Ames, IA',
    'IA',
    'ag_air',
    100,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000006',
    'Prairie Drone Applications',
    '555-0606',
    'dispatch@prairiedrone.example',
    '240 Technology Dr, Lincoln, NE',
    'NE',
    'drone',
    60,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000007',
    'Heartland Drone Spraying',
    '555-0707',
    'service@heartlanddrone.example',
    '19 Innovation Way, Columbia, MO',
    'MO',
    'drone',
    75,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000008',
    'Farmers Cooperative Crop Services',
    '555-0808',
    'agronomy@farmerscoop.example',
    '310 Cooperative Ave, Des Moines, IA',
    'IA',
    'co_op',
    90,
    true
  ),
  (
    '10000000-0000-4000-8000-000000000009',
    'County Line Co-op Agronomy',
    '555-0909',
    'spraying@countylinecoop.example',
    '62 County Line Rd, Salina, KS',
    'KS',
    'co_op',
    110,
    true
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  phone = EXCLUDED.phone,
  email = EXCLUDED.email,
  address = EXCLUDED.address,
  state = EXCLUDED.state,
  service_type = EXCLUDED.service_type,
  service_radius_miles = EXCLUDED.service_radius_miles,
  is_active = EXCLUDED.is_active;
