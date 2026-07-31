# CropID — Architecture & Reference

Single source of truth for the CropID app. (Older planning docs were consolidated
into this file on 2026-07-24; see git history if you need the originals.)

**Product in one line:** farmers claim their fields, log what's growing each season,
and get warned before a spray endangers a neighbor's sensitive crop — with a fast
path to contact a spraying service.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Client (mobile + web) | Flutter 3.41 |
| State | Riverpod 2 |
| Navigation | go_router 13 (ShellRoute bottom nav) |
| Backend | Supabase — Auth, Postgres + PostGIS, Realtime, Storage, Edge Functions |
| Maps | flutter_map + OpenStreetMap (no API key) |
| Local cache | Hive |
| Comms | url_launcher (tel:), Twilio SMS + SendGrid email via edge functions |
| Codegen | Freezed + json_serializable + Riverpod generator |

Regenerate generated files after model changes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Folder Structure

```
lib/
├── main.dart            # bootstrap (Supabase, Hive, notifications init)
├── app.dart             # MaterialApp.router
├── core/                # constants, router, shell, theme, utils
├── features/
│   ├── auth/            # login, register, profile
│   ├── farm_map/        # map, field polygons, (WIP) claim-a-field
│   ├── spray_planning/  # chemical selection, danger check
│   ├── notifications/   # neighbor risk-alert inbox
│   └── crop_duster/     # service directory, contact
└── shared/              # widgets + services (Supabase, location, cache)

supabase/
├── config.toml
├── migrations/20260725045408_cropid_baseline.sql
├── migrations/20260725045418_field_import_and_seasons.sql
├── seed_chemicals.sql
├── functions/{send_notification,contact_crop_duster}/index.ts
└── legacy/schema_v1_reference.sql
```

---

## Data Model

Base tables (`20260725045408_cropid_baseline.sql`): `profiles`, `crops`, `fields`, `chemicals`,
`spray_plans`, `spray_plan_chemicals`, `danger_notifications`,
`crop_duster_services`.

The field-import migration adds the two pieces the product vision needs:

- **`csb_fields`** — imported public USDA field boundaries used as a *claim source*.
  Geometry only; ownership is established when a farmer claims one.
- **`fields.source` / `csb_id` / `clu_id` / `acres`** — link a claimed field back to
  its import source (`manual` | `csb` | `clu` | `oauth`).
- **`csb_fields_near(lat,lng,radius)`** — returns unclaimed nearby boundaries for the
  "tap to claim" map layer.
- **`claim_csb_field(csb_id, name)`** — atomically turns a CSB boundary into an owned field.
- **`field_crop_seasons`** — per-season crop history ("what's growing this season");
  `fields.current_crop_id` stays as the denormalized active-season pointer.

### RLS summary
| Table | Policy |
|---|---|
| profiles | own row only |
| fields | owner full CRUD; others read non-private |
| spray_plans / field_crop_seasons | owner only |
| danger_notifications | recipient reads/updates own; service role inserts |
| chemicals / crops / csb_fields | authenticated read |
| crop_duster_services | public read (active only) |

---

## Field Onboarding Strategy — no hand-drawing

Farmers should **not** draw fields. Boundaries already exist; we import them and let
the farmer claim theirs.

**Shipping now — USDA CSB (free, national):** import public USDA Crop Sequence
Boundaries into `csb_fields`; the app shows real outlines around the farmer's GPS and
they tap to claim. One-time ~2-minute onboarding.

**Import (out-of-band, requires GDAL):**
```bash
ogr2ogr -f PostgreSQL PG:"host=... user=postgres password=... dbname=postgres" \
  CSB_<State>.shp -nln csb_fields -nlt POLYGON -t_srs EPSG:4326
```
Then backfill `boundary_points` (JSONB) from the geometry for client rendering.

**Later upgrades to true auto-import (schema already supports via `source`/`*_id`):**

| Source | What it gives | How to get it |
|---|---|---|
| **USDA CSB / CDL** | free boundaries + predicted crop | `nass.usda.gov` — download, public domain |
| **FieldWatch / DriftWatch** | state-backed sensitive-crop registry + locations | `fieldwatch.com` — partner/API; also the key incumbent to study |
| **Leaf Agriculture** | one API federating John Deere / Climate FieldView / CNH / Trimble; farmer OAuth → real fields | `withleaf.io` — paid SaaS |
| **Regrid** | nationwide parcels **with owner names** (parcels ≠ agronomic fields) | `regrid.com` — licensable |
| **USDA FSA CLU** | authoritative, ownership-linked | per-state FSA **data-sharing agreement** only — not for public sale |

Note: name-based "enter an ID → all my fields" is legally blocked for FSA/CLU (2008
Farm Bill restriction; producer PII is separately restricted in SCIMS). The claim
model + the paid sources above are the realistic paths.

---

## Key Data Flows

**Danger detection:** select field → `adjacentFieldsProvider` fetches nearby
non-private fields → `dangerousFieldsProvider` cross-references
`chemical.dangerous_to_crop_ids` vs adjacent `field.current_crop_id` → red overlay +
banner → on save, `send_notification` edge fn inserts `danger_notifications` → Realtime
pushes to affected neighbors. Adjacent fields with no `farmer_id` are flagged
"Unknown owner — not notified" (coverage grows with adoption).

**Crop duster contact:** saved plan → `CropDusterScreen` (nearby services) → tap →
`ContactScreen` with auto-built message (field, GPS link, chemicals, danger count) →
`tel:` now, or `contact_crop_duster` edge fn for SMS/email.

---

## Edge Function Deployment

Project ref: `yffrxorputpzlumsgxlv`. Requires Supabase CLI + `supabase login`.

```powershell
supabase link --project-ref yffrxorputpzlumsgxlv
supabase db push --include-seed
# optional: TWILIO_SID / TWILIO_TOKEN / TWILIO_FROM_NUMBER
# optional: SENDGRID_API_KEY / SENDGRID_FROM_EMAIL / SENDGRID_FROM_NAME
supabase functions deploy send_notification
supabase functions deploy contact_crop_duster
```

- `send_notification` — inserts `danger_notifications`; optional SMS/email to neighbors.
- `contact_crop_duster` — SMS/email to a registered service; used by `ContactScreen`.

---

## Platform Setup

**iOS** (`ios/Runner/Info.plist`): `NSLocationWhenInUseUsageDescription`,
`NSLocationAlwaysUsageDescription`.
**Android** (`AndroidManifest.xml`): `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
`INTERNET`.
**Web:** no special config; geolocation uses the browser permission dialog.

---

## Roadmap (condensed)

1. **Mobile core stabilization** *(active — branch `001-mobile-core-stabilization`)*:
   reliable save, trustworthy alerts, coherent service-contact handoff.
2. **Claim-a-field + seasonal crops** *(next — migration `0002` is the backend)*:
   CSB import, tap-to-claim onboarding, per-season crop logging.
3. **Spray-timing intelligence:** weather/wind (drift) + label constraints (REI/PHI) +
   growth stage → "safe to spray today / wait".
4. **Farmer web dashboard** and **ag-service portal** (two-sided workflow) — shared
   backend, dashboard-style UI, deferred until mobile is trusted.

**Liability guardrail:** position as decision *support*, not prescription; source
chemical/label data (REI/PHI) from verifiable EPA label origins.
