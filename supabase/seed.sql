-- ============================================================
-- CropID - Local seed data
-- Sample crop duster services for local/dev resets.
-- ============================================================

-- â”€â”€ Sample crop duster services â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
INSERT INTO crop_duster_services (name, phone, email, address, state, service_radius_miles, is_active)
VALUES
  ('Midwest AirSpray LLC',   '555-0101', 'info@midwestairspray.example',  '100 Airfield Rd, Springfield, IL',  'IL', 150, true),
  ('Central Plains Aerial',  '555-0202', 'fly@centralplains.example',     '45 Crop Way, Wichita, KS',          'KS', 200, true),
  ('Delta AgAir Services',   '555-0303', NULL,                             '77 Hangar Ln, Memphis, TN',         'TN', 120, true),
  ('High Plains Ag Aviation','555-0404', 'contact@highplains.example',    '12 Skyway Blvd, Lubbock, TX',       'TX', 175, true),
  ('Corn Belt Air Ag',        '555-0505', 'info@cornbeltair.example',      '8 Spray Lane, Ames, IA',            'IA', 100, true)
ON CONFLICT DO NOTHING;

