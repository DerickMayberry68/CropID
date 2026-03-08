# CropID — Phased Implementation Plan

---

## Phase 1 — Foundation ✅ (Scaffold complete)

**Goal:** Working app with auth, map display, and basic spray planning.

### Deliverables
- Flutter project scaffold with all dependencies
- Supabase project setup (run `schema.sql` + `seed_chemicals.sql`)
- User registration and login (email/password)
- Farm map with OpenStreetMap tiles
- Manual field polygon entry via Supabase (no in-app drawing yet)
- Chemical selector from seeded DB
- Danger computation (client-side)
- Bottom nav shell + all 5 screens wired up

### Tasks
- [ ] Create Supabase project at supabase.com
- [ ] Run `supabase/schema.sql` in SQL Editor
- [ ] Run `supabase/seed_chemicals.sql` in SQL Editor
- [ ] Add your `SUPABASE_URL` and `SUPABASE_ANON_KEY` to `supabase_constants.dart`
- [ ] Add `assets/` folders (fonts, images, icons) or remove from `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Run `dart run build_runner build` to generate Freezed/JSON models
- [ ] Configure iOS `Info.plist` for location permissions
- [ ] Configure Android `AndroidManifest.xml` for location permissions
- [ ] Test auth flow on device/simulator
- [ ] Manually insert a test field via Supabase Dashboard to verify map rendering

---

## Phase 2 — Map Drawing + Field Management

**Goal:** Farmers can draw field boundaries on-device and manage them.

### Deliverables
- In-app polygon drawing on the flutter_map (tap to add points, close polygon)
- Field CRUD screen (create, rename, update crop, delete)
- Profile edit screen with farm location save
- Avatar upload via Supabase Storage
- PostGIS `ST_DWithin` integration for accurate adjacent-field radius
- Password reset flow
- GDPR consent checkbox on registration

### Key work
- Add `flutter_map_toolkit` or custom polygon drawing layer
- Wire up `FieldRepository.createField()` from drawn polygon
- Replace bounding-box adjacent-field query with PostGIS RPC call
- Implement `LocationService.positionStream()` for live map centering

---

## Phase 3 — Danger Alerts + Realtime + Notifications

**Goal:** Full danger detection pipeline with push notifications.

### Deliverables
- Move danger computation to Supabase Edge Function (`send_notification`)
- Deploy `supabase/functions/send_notification/index.ts`
- Wire `sprayPlanNotifier.save()` to call edge function post-save
- Supabase Realtime subscription for incoming danger notifications
- `flutter_local_notifications` push for foreground alerts
- Notification badge count on bottom nav Alerts tab
- Map highlighting of dangerous adjacent fields (red overlay)
- Chemical incompatibility warning in `ChemicalSelectorScreen`

### Key work
- `supabase functions deploy send_notification`
- Add `SUPABASE_SERVICE_ROLE_KEY` to edge function secrets
- Implement `NotificationRepository.subscribeToNotifications()` listener
- Wire listener to `flutter_local_notifications` for background alerts

---

## Phase 4 — Crop Duster Communication + Polish

**Goal:** Full end-to-end spray request workflow.

### Deliverables
- Twilio SMS for neighboring farmers via `send_notification`
- Twilio SMS for registered crop duster services via `contact_crop_duster`
- SendGrid email for neighboring farmers and registered crop duster services
- `ContactScreen` SMS button fully wired
- Crop duster proximity search using PostGIS
- Offline mode: Hive cache for fields + chemicals with connectivity check
- `connectivity_plus` banner when offline
- Web (Flutter Web) build testing and responsive layout
- App store metadata and icons

### Key work
- Extend `send_notification` for optional farmer SMS/email fanout
- New edge function `supabase/functions/contact_crop_duster/index.ts` using Twilio and SendGrid
- Add `TWILIO_SID`, `TWILIO_TOKEN`, `TWILIO_FROM_NUMBER` to Supabase secrets
- Add `SENDGRID_API_KEY`, `SENDGRID_FROM_EMAIL`, `SENDGRID_FROM_NAME` to Supabase secrets
- `CacheService` — populate on first load, serve from cache when offline
- Add Hive adapters for `Field` and `Chemical` models via `hive_generator`
- Add `ConnectivityBanner` widget in `MainShell`

---

## Phase 5 — Advanced Features

**Goal:** Competitive differentiation.

### Ideas
- Historical spray plans with archive view
- Weather API integration (wind speed/direction warnings before spray)
- Photo capture of field conditions (Supabase Storage)
- Farmer-to-farmer in-app messaging
- Crop duster rating/review system
- Government compliance report export (PDF)
- Multi-language support (Spanish for Hispanic farming communities)
