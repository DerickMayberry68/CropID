-- Crops referenced by USDA CDL codes, so imported field boundaries can carry a
-- predicted crop (csb_fields.predicted_crop_id has an FK to crops.id).
--
-- Scope is the crop cover actually reported across Arkansas CDL data, including
-- pasture and hay: a neighbor running livestock still cares about drift, and
-- grazing restrictions are a real label constraint.
--
-- sensitive_to is intentionally left empty. Chemical-to-crop sensitivity drives
-- safety warnings and must be sourced from EPA label data rather than inferred
-- here; see chemicals.dangerous_to_crop_ids for the mapping the danger check
-- actually reads.

begin;

insert into public.crops (id, name, scientific_name, tags) values
  ('rice',          'Rice',              'Oryza sativa',            array['grain','grass','flooded']),
  ('barley',        'Barley',            'Hordeum vulgare',         array['grain','grass']),
  ('oats',          'Oats',              'Avena sativa',            array['grain','grass']),
  ('rye',           'Rye',               'Secale cereale',          array['grain','grass','cover']),
  ('peanuts',       'Peanuts',           'Arachis hypogaea',        array['legume','oilseed']),
  ('dry_beans',     'Dry Beans',         'Phaseolus vulgaris',      array['legume','broadleaf']),
  ('sweet_potato',  'Sweet Potato',      'Ipomoea batatas',         array['vegetable','root']),
  ('tomatoes',      'Tomatoes',          'Solanum lycopersicum',    array['vegetable','specialty']),
  ('watermelon',    'Watermelon',        'Citrullus lanatus',       array['vegetable','specialty']),
  ('grapes',        'Grapes',            'Vitis vinifera',          array['perennial','specialty','drift_sensitive']),
  ('peaches',       'Peaches',           'Prunus persica',          array['orchard','specialty','drift_sensitive']),
  ('pecans',        'Pecans',            'Carya illinoinensis',     array['orchard','specialty']),
  ('hay_other',     'Hay (Non-Alfalfa)', null,                      array['forage']),
  ('pasture',       'Grassland / Pasture', null,                    array['forage','grazing']),
  ('fallow',        'Fallow / Idle',     null,                      array['non_crop'])
on conflict (id) do nothing;

commit;
