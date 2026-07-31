# CropID Supabase backend

The timestamped files in `migrations/` are the database source of truth.
`legacy/schema_v1_reference.sql` is retained only as historical source material
and must not be applied to a current project.

## Migration order

1. `20260725045408_cropid_baseline.sql`
   - Core application tables
   - PostGIS helpers and indexes
   - Row-level security and explicit Data API grants
   - Avatar Storage bucket and policies
   - Realtime publication membership
2. `20260725045418_field_import_and_seasons.sql`
   - Claimable USDA field boundaries
   - Field source metadata
   - Seasonal crop history

`seed_chemicals.sql` contains idempotent reference crops, chemicals, and sample
crop-duster listings. The seed path is configured in `config.toml`.

## Local verification

Requires Docker and Supabase CLI:

```powershell
supabase start
supabase db reset
supabase db lint
flutter analyze
flutter test
```

## Deploy to the CropID project

Target project ref: `yffrxorputpzlumsgxlv`.

Review the migration plan before applying it:

```powershell
supabase login
supabase link --project-ref yffrxorputpzlumsgxlv
supabase db push --dry-run
```

Apply migrations and reference seeds:

```powershell
supabase db push --include-seed
```

Deploy the authenticated Edge Functions:

```powershell
supabase functions deploy send_notification contact_crop_duster
```

Hosted Edge Functions receive `SUPABASE_URL` and `SUPABASE_SECRET_KEYS`
automatically. Do not add a secret key to the Flutter client or source control.
Twilio and SendGrid secrets remain optional:

```powershell
supabase secrets set TWILIO_SID="..."
supabase secrets set TWILIO_TOKEN="..."
supabase secrets set TWILIO_FROM_NUMBER="..."
supabase secrets set SENDGRID_API_KEY="..."
supabase secrets set SENDGRID_FROM_EMAIL="..."
supabase secrets set SENDGRID_FROM_NAME="CropID"
```

After deployment, run the Supabase database advisors and verify:

- A new Auth user receives exactly one `profiles` row.
- Authenticated users can only manage their own fields and spray plans.
- `spray_plan_chemicals` follows parent-plan ownership.
- Avatar upload, overwrite, and public retrieval work.
- `fields` and `danger_notifications` emit Realtime changes.
- Both Edge Functions reject missing or mismatched user identities.
