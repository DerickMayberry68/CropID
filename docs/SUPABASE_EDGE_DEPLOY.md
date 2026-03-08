# Supabase Edge Function Deployment

This project currently uses the Supabase project:

- Project ref: `vwyeasxwrwejlxyydjnf`

## Prerequisites

- Supabase CLI installed
- Logged in with `supabase login`
- Linked to the project with:

```powershell
supabase link --project-ref vwyeasxwrwejlxyydjnf
```

## Required Secrets

Both edge functions require:

```powershell
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
```

Optional SMS support for farmers and crop duster services:

```powershell
supabase secrets set TWILIO_SID="your-twilio-sid"
supabase secrets set TWILIO_TOKEN="your-twilio-token"
supabase secrets set TWILIO_FROM_NUMBER="your-twilio-from-number"
```

Optional email support for farmers and crop duster services:

```powershell
supabase secrets set SENDGRID_API_KEY="your-sendgrid-api-key"
supabase secrets set SENDGRID_FROM_EMAIL="no-reply@your-domain.com"
supabase secrets set SENDGRID_FROM_NAME="CropID"
```

## Deploy Commands

Deploy neighboring-farmer notifications:

```powershell
supabase functions deploy send_notification
```

Deploy registered crop duster outreach:

```powershell
supabase functions deploy contact_crop_duster
```

## What Each Function Does

- `send_notification`
  - Creates `danger_notifications` records
  - Optionally sends SMS/email to affected neighboring farmers

- `contact_crop_duster`
  - Sends SMS/email to a registered spray service from `crop_duster_services`
  - Used by the Flutter `ContactScreen`

## Suggested Verification

After deployment:

1. Save a spray plan with dangerous adjacent fields and confirm:
   - `danger_notifications` rows are inserted
   - SMS/email is sent when Twilio/SendGrid secrets are configured
2. Open the crop duster contact flow in the app and confirm:
   - SMS returns `sent` or a clear fallback status
   - Email returns `sent` or `missing_service_email`
