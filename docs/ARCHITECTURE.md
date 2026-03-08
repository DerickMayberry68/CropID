# CropID — Architecture Reference

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile/Web | Flutter 3.x |
| State Management | Riverpod 2 (StateNotifier + FutureProvider + StreamProvider) |
| Navigation | go_router 13 (ShellRoute for bottom nav) |
| Backend | Supabase (Auth, Postgres, Realtime, Storage, Edge Functions) |
| Maps | flutter_map + OpenStreetMap (no API key required) |
| Geospatial DB | PostGIS (via Supabase) |
| Local Cache | Hive |
| Communication | url_launcher (call), Twilio SMS + SendGrid email via Edge Functions in Phase 4 |
| Codegen | Freezed + json_serializable + Riverpod generator |

---

## Folder Structure

```
lib/
├── main.dart                   # App bootstrap (Supabase, Hive init)
├── app.dart                    # MaterialApp.router
├── core/
│   ├── constants/              # Supabase table names, app defaults
│   ├── router/                 # go_router config + route constants
│   ├── shell/                  # Bottom nav shell widget
│   ├── theme/                  # AppTheme (light + dark)
│   └── utils/                  # Validators, extensions
├── features/
│   ├── auth/                   # Login, register, profile
│   ├── farm_map/               # Map screen, field polygons
│   ├── spray_planning/         # Chemical selection, danger check
│   ├── notifications/          # Danger alert inbox
│   └── crop_duster/            # Service directory, contact screen
└── shared/
    ├── widgets/                # PrimaryButton, LoadingOverlay, ErrorWidget
    └── services/               # SupabaseService, LocationService, CacheService

supabase/
├── schema.sql                  # Full DB schema + RLS + PostGIS functions
├── seed_chemicals.sql          # Initial chemical/crop/crop-duster data
└── functions/
    ├── send_notification/      # Deno function: creates danger notifications + farmer outreach
    │   └── index.ts
    └── contact_crop_duster/    # Deno function: contacts registered spray services
        └── index.ts
```

---

## Data Flow: Danger Detection

```
Farmer selects field
       ↓
adjacentFieldsProvider fetches nearby non-private fields
       ↓
selectedChemicalsProvider holds chosen chemicals
       ↓
dangerousFieldsProvider (computed) cross-references
  chemical.dangerousToCropIds vs adjacent field.currentCropId
       ↓
DangerAlertBanner shown + AdjacentFieldsOverlay renders red polygons
       ↓
On Save → call Supabase Edge Function `send_notification`
       ↓
Edge Function inserts danger_notifications rows for affected farmers
       ↓
Supabase Realtime pushes to affected farmers' apps
```

---

## Data Flow: Crop Duster Contact

```
Farmer saves spray plan (field + chemicals + danger fields)
       ↓
Route to CropDusterScreen (list of nearby services)
       ↓
Tap service → ContactScreen
       ↓
Auto-built message: field name, GPS link, chemicals, danger count
       ↓
Call (url_launcher tel:) | Phase 4: SMS/email via `contact_crop_duster`
       ↓
Delivered to registered crop duster services in `crop_duster_services`
```

---

## Supabase RLS Summary

| Table | Policy |
|---|---|
| profiles | User reads/writes own row only |
| fields | Owner has full CRUD; others read non-private |
| spray_plans | Owner only |
| danger_notifications | Recipient reads/updates own; service role inserts |
| chemicals | Public read |
| crops | Public read |
| crop_duster_services | Public read (active only) |

---

## Key Dependencies and Versions

```yaml
supabase_flutter: ^2.5.6
flutter_riverpod: ^2.5.1
go_router: ^13.2.4
flutter_map: ^6.2.1
latlong2: ^0.9.1
geolocator: ^12.0.0
hive_flutter: ^1.1.0
freezed_annotation: ^2.4.1
dartz: ^0.10.1
url_launcher: ^6.3.0
```

---

## Platform Setup Checklist

### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>CropID needs your location to center the map on your farm.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>CropID uses your location to find nearby fields and crop duster services.</string>
```

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Web (web/index.html)
No special config needed for flutter_map on web.
Geolocation uses browser's native permission dialog.
