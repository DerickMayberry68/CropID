# Data Model: Farmer Web Dashboard MVP

## Overview

This model describes farmer-facing web dashboard entities and state behavior for fields, application plans, alerts, and service-request status tracking.

## Entities

## 1. FarmerSession

Purpose:
- Represents authenticated farmer access context for all dashboard data retrieval.

Key Fields:
- `farmer_id` (required)
- `session_state` (`active`, `expired`, `signed_out`)
- `last_validated_at`

Validation Rules:
- Dashboard data reads require `session_state = active`.
- Expired or signed-out states must block protected data views.

State Transitions:
- `active -> expired` (token timeout or invalidation)
- `expired -> active` (successful re-authentication)
- `active|expired -> signed_out` (explicit logout)

Relationships:
- One FarmerSession gates many FieldSummary, ApplicationPlanRecord, AlertRecord, and ServiceRequestRecord reads.

## 2. FieldSummary

Purpose:
- Farmer-owned field overview used in map/list and selected-field context panel.

Key Fields:
- `field_id` (required)
- `farmer_id` (required)
- `field_name` (required)
- `current_crop_name` (optional)
- `visibility` (required)
- `boundary_summary` (optional)
- `updated_at`

Validation Rules:
- Only records with matching authenticated `farmer_id` are displayed as owned records.
- Missing crop context must render fallback labels rather than blank failures.

State Notes:
- Selection state is UI-level: `unselected` or `selected` for one active field at a time.

Relationships:
- One FieldSummary can relate to many ApplicationPlanRecord entries and many ServiceRequestRecord entries.

## 3. ApplicationPlanRecord

Purpose:
- Saved farmer application plan visible in web history and detail panels.

Key Fields:
- `plan_id` (required)
- `farmer_id` (required)
- `field_id` (required)
- `field_name` (optional fallback)
- `status` (`draft`, `scheduled`, `completed`, `cancelled`)
- `chemical_names` (0..n)
- `danger_count`
- `created_at`
- `updated_at` (optional)

Validation Rules:
- Must be farmer-owned (`farmer_id` match) for visibility.
- Default sort order is newest-first by timestamp.
- If linked field context is unavailable, display resilient fallback labels.

State Notes:
- MVP web behavior is read-focused; no write transition required in this model.

Relationships:
- Many ApplicationPlanRecord entries belong to one FieldSummary.
- One ApplicationPlanRecord may link to zero or many ServiceRequestRecord entries over time.

## 4. AlertRecord

Purpose:
- Farmer alert inbox item with review-state tracking.

Key Fields:
- `alert_id` (required)
- `recipient_farmer_id` (required)
- `affected_field_id` (required)
- `affected_field_name` (optional)
- `sender_farm_name` (optional)
- `dangerous_chemical_names` (0..n)
- `is_read` (boolean)
- `created_at`

Validation Rules:
- Only alerts addressed to authenticated farmer are visible.
- Review action must persist `is_read = true` across refresh.

State Transitions:
- `unread -> reviewed` (farmer review action)
- `reviewed -> reviewed` (idempotent re-open)

Relationships:
- Many AlertRecord entries can reference one FieldSummary over time.

## 5. ServiceRequestRecord

Purpose:
- Farmer-facing tracking record for requested spraying services.

Key Fields:
- `request_id` (required)
- `farmer_id` (required)
- `field_id` (required)
- `linked_plan_id` (optional)
- `status` (`draft`, `submitted`, `viewed`, `accepted`, `declined`, `withdrawn`, `expired`, `converted_to_job`)
- `shared_field_name`
- `shared_crop_name` (optional)
- `shared_chemical_names` (0..n)
- `shared_danger_count` (optional)
- `submitted_at` (optional)
- `responded_at` (optional)
- `created_at`
- `updated_at`

Validation Rules:
- Only request records owned by authenticated farmer are visible.
- Status and timestamps must be consistent with persisted request lifecycle data.
- Missing linked references must not break rendering; fallback presentation required.

State Transitions:
- `draft -> submitted`
- `submitted -> viewed`
- `submitted|viewed -> accepted|declined|withdrawn|expired`
- `accepted -> converted_to_job`

Relationships:
- Many ServiceRequestRecord entries belong to one farmer and can reference one FieldSummary.
- Optional many-to-one linkage from ServiceRequestRecord to ApplicationPlanRecord.

## Cross-Entity Rules

- Authorization boundary: all dashboard entities are farmer-scoped by authenticated identity.
- Terminology coherence: "Application Plan" naming applies across list/detail surfaces.
- Sync behavior: stale or partial data must be represented with explicit loading/error/empty states, not implied success.
