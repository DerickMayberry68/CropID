# Supabase Schema V2 Plan

This document maps the current CropID schema to the next planned schema expansion for the broader platform.

It is not a final migration file. It is a design-level schema plan that should guide future Supabase migrations.

## Purpose

Schema V2 is the transition from:

- farmer-mobile-first backend

to:

- shared multi-role platform backend

Schema V2 should enable:

- farmer mobile continuation
- future farmer web support
- future ag spraying service portal support
- explicit cross-role workflow objects

## Current Schema Summary

Current major tables:

- `profiles`
- `crops`
- `fields`
- `chemicals`
- `spray_plans`
- `spray_plan_chemicals`
- `danger_notifications`
- `crop_duster_services`

Current strengths:

- farmer-owned field data
- spray plan persistence
- risk notification pipeline
- service directory presence
- geospatial base via PostGIS

Current limitations:

- no role model beyond farmer-centric assumptions
- no service organization model
- no service request domain
- no job/dispatch domain
- no audit/history tables for multi-role workflow

## Schema V2 Goals

1. Preserve the working farmer schema
2. Add explicit role-aware identity support
3. Add explicit service request and job workflow entities
4. Keep RLS enforceable and understandable
5. Avoid exposing farmer data broadly to service users

## Schema V2 Modules

### Module 1: Identity And Roles

Recommended new tables:

- `user_roles`
- `service_organizations`
- `service_users`

#### `user_roles`

Purpose:

- assign platform-level role type to authenticated users

Suggested fields:

- `id`
- `user_id`
- `role`
- `organization_id` nullable
- `created_at`

Suggested role values:

- `farmer`
- `service_operator`
- `service_manager`
- `platform_admin`

#### `service_organizations`

Purpose:

- represent the operating business entity for ag spraying services

Suggested fields:

- `id`
- `name`
- `billing_email`
- `phone`
- `website`
- `address`
- `state`
- `service_radius_miles`
- `location`
- `is_active`
- `created_at`
- `updated_at`

#### `service_users`

Purpose:

- link authenticated users to a service organization

Suggested fields:

- `id`
- `user_id`
- `service_organization_id`
- `organization_role`
- `created_at`

Suggested organization role values:

- `operator`
- `manager`

## Module 2: Public Service Directory

Current table:

- `crop_duster_services`

Schema V2 options:

### Option A: Keep as public listing table

Pros:

- clean separation between public listing and internal service org data

Cons:

- requires sync/link between listing and organization records

### Option B: Fold listing into `service_organizations`

Pros:

- fewer entities

Cons:

- public and internal concerns become mixed

Recommended direction:

- keep a public listing layer separate if the service portal becomes serious

Potential future fields on listing:

- `service_organization_id`
- `listing_status`
- `approved_at`
- `approved_by`
- `subscription_status`

## Module 3: Farmer Operations

These tables should remain intact, with limited structural evolution:

- `fields`
- `spray_plans`
- `spray_plan_chemicals`

Recommended enhancements:

### `spray_plans`

Potential additions:

- `updated_at`
- `archived_at`
- `last_modified_by`
- `plan_source`

Potential status refinement:

- keep current status values unless product requires more detail

### `fields`

Potential additions:

- `archived_at`
- `last_risk_evaluated_at`
- optional normalized location summary fields if useful for web filters

## Module 4: Risk And Notifications

Current table:

- `danger_notifications`

Recommended additions:

- `status` if future acknowledgement states become more complex
- `read_at`
- `delivery_summary` if communication history becomes relevant

Possible future support tables:

- `notification_events`
- `notification_deliveries`

These are not required immediately, but will become useful when notifications span:

- in-app
- SMS
- email

## Module 5: Service Request Domain

Recommended new table:

- `service_requests`

Purpose:

- explicit bridge between farmer workflow and service workflow

Suggested MVP fields:

- `id`
- `farmer_id`
- `spray_plan_id`
- `field_id`
- `target_service_id`
- `status`
- `requested_service_notes`
- `shared_field_name`
- `shared_crop_name`
- `shared_chemical_names`
- `shared_danger_count`
- `requested_window_start`
- `requested_window_end`
- `submitted_at`
- `responded_at`
- `created_at`
- `updated_at`

Suggested future fields:

- `accepted_at`
- `declined_at`
- `withdrawn_at`
- `converted_to_job_at`
- `shared_location_summary`
- `shared_map_link`
- `job_id`

## Module 6: Request History And Communication

Recommended future tables:

- `service_request_status_history`
- `service_request_messages`
- `service_request_attachments`

Purpose:

- keep request lifecycle auditable
- support two-way communication later
- avoid overloading the base request row

These can be introduced after the initial `service_requests` table.

## Module 7: Jobs And Dispatch

Recommended new tables:

- `jobs`
- `job_status_history`

Possible later additions:

- `job_assignments`
- `equipment`
- `equipment_status_history`

### `jobs`

Suggested fields:

- `id`
- `service_request_id`
- `service_organization_id`
- `farmer_id`
- `field_id`
- `status`
- `scheduled_start`
- `scheduled_end`
- `internal_notes`
- `customer_visible_notes`
- `created_at`
- `updated_at`

### `job_status_history`

Suggested fields:

- `id`
- `job_id`
- `old_status`
- `new_status`
- `changed_by_user_id`
- `customer_visible`
- `note`
- `created_at`

## Module 8: Audit And Compliance

Recommended future tables:

- `audit_logs`
- `compliance_reports`
- `report_exports`

Purpose:

- internal support visibility
- admin actions
- export history
- future compliance workflows

## Suggested Migration Order

### Migration Group 1: Foundation Discipline

- convert new changes to migration-based workflow
- add missing timestamps/indexes where needed

### Migration Group 2: Identity And Roles

- add `user_roles`
- add `service_organizations`
- add `service_users`

### Migration Group 3: Service Request MVP

- add `service_requests`
- add initial RLS
- add edge function workflow hooks

### Migration Group 4: Job Domain MVP

- add `jobs`
- add `job_status_history`

### Migration Group 5: Communication And Audit

- add request/notification history support
- add admin/audit tables

## RLS Plan For Schema V2

### Farmer-Owned Tables

- `fields`
- `spray_plans`
- `spray_plan_chemicals`
- farmer-visible `service_requests`
- farmer-visible `jobs` statuses

Primary rule:

- farmer can access only their own workflow records

### Service-Scoped Tables

- `service_requests` assigned to their org
- `jobs` belonging to their org
- future dispatch/equipment tables

Primary rule:

- service operators can access only organization-scoped records

### Admin-Sensitive Tables

- `audit_logs`
- approval/moderation fields
- support-access views

Primary rule:

- highly restricted and auditable

## Edge Function Implications

Schema V2 will likely require new or expanded Edge Functions for:

- submitting service requests
- notifying services about incoming requests
- converting accepted requests into jobs
- updating farmer-facing workflow events

Recommended principle:

- cross-role writes should happen through Edge Functions, not directly from clients

## Recommended Constraints And Conventions

To keep Schema V2 maintainable:

- use constrained status values consistently
- add `created_at` and `updated_at` on workflow tables
- add foreign keys for ownership and linkage
- avoid overusing JSON for primary workflow fields
- use explicit naming for shared snapshot fields

## Open Decisions

These must be answered before finalizing V2 migrations:

1. Will the public service directory remain separate from service organizations?
2. Will one farmer request target one service or multiple services?
3. Should accepted requests immediately create jobs?
4. How much job detail should be farmer-visible?
5. Should service users be modeled through `profiles`, separate tables, or both?

## Recommended Next Step

Use this document as the design input for:

- the first real Supabase migration plan
- RLS design review
- service request implementation planning

Schema V2 should begin with:

- roles
- service organizations
- service requests

Those are the minimum additions that unlock the future service portal without breaking the current farmer app.
