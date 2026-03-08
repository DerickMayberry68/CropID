# Data Model: Mobile Core Stabilization

## Scope

Feature-level data/state model for reliability hardening. This does not introduce new domain entities.

## Entities

## Field
- id
- owner_id
- display_name
- visibility_status
- location_summary

## Spray Plan
- id
- farmer_id
- field_id
- treatment_summary
- risk_summary
- saved_at
- save_state (ui-derived: idle | saving | saved | failed)

## Risk Alert
- id
- recipient_farmer_id
- source_field_id
- risk_summary
- created_at
- review_state (unread | reviewed)

## Crop Duster Listing
- id
- display_name
- contact_channels
- listing_status

## Contact Context Payload
- spray_plan_id
- field_display_name
- location_summary
- treatment_summary
- risk_summary

## State Transition Rules

1. Spray plan save
- idle -> saving -> saved
- idle -> saving -> failed
- failed -> saving -> saved (retry)

2. Alert review
- unread -> reviewed
- reviewed remains visible in history

3. Contact context
- Generated from latest saved spray plan state
- Must not use stale draft-only values

## Consistency Rules

- UI must not show saved unless persistence succeeded.
- Saved plan retrieval must reflect persisted backend values.
- Contact payload must match current saved plan snapshot.
- Farmer-only visibility remains unchanged.