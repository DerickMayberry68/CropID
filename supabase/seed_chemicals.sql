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
ON CONFLICT (id) DO NOTHING;

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

ON CONFLICT (id) DO NOTHING;

-- ── Sample crop duster services ─────────────────────────────
INSERT INTO crop_duster_services (name, phone, email, address, state, service_radius_miles, is_active)
VALUES
  ('Midwest AirSpray LLC',   '555-0101', 'info@midwestairspray.example',  '100 Airfield Rd, Springfield, IL',  'IL', 150, true),
  ('Central Plains Aerial',  '555-0202', 'fly@centralplains.example',     '45 Crop Way, Wichita, KS',          'KS', 200, true),
  ('Delta AgAir Services',   '555-0303', NULL,                             '77 Hangar Ln, Memphis, TN',         'TN', 120, true),
  ('High Plains Ag Aviation','555-0404', 'contact@highplains.example',    '12 Skyway Blvd, Lubbock, TX',       'TX', 175, true),
  ('Corn Belt Air Ag',        '555-0505', 'info@cornbeltair.example',      '8 Spray Lane, Ames, IA',            'IA', 100, true)
ON CONFLICT DO NOTHING;
