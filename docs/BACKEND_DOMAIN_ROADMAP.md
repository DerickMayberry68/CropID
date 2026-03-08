# CropID Backend Domain Roadmap

This document defines the backend evolution plan for CropID using Supabase.

It is intended to guide how the current farmer-mobile backend grows into a shared platform backend that also supports:

- farmer web
- ag spraying service portal
- future admin/support tooling

## Backend Platform Choice

CropID will use Supabase as the primary backend platform.

Primary Supabase capabilities in scope:

- Auth
- Postgres
- Row Level Security
- Realtime
- Edge Functions
- Storage
- SQL migrations

## Current State

The current schema already supports the farmer mobile app reasonably well.

Existing domain tables:

- `profiles`
- `crops`
- `fields`
- `chemicals`
- `spray_plans`
- `spray_plan_chemicals`
- `danger_notifications`
- `crop_duster_services`

Existing platform patterns:

- auth-backed farmer identity
- RLS for farmer-owned data
- PostGIS for field/location logic
- edge functions for notifications and service contact
- realtime for danger notifications

## Target Backend Shape

The backend should evolve from a farmer-only application schema into a role-aware shared platform schema.

Long-term domain families:

1. Identity and access
2. Farmer operations
3. Risk and alerting
4. Service marketplace / directory
5. Service request and job workflow
6. Communication and audit history
7. Reporting and compliance

## Guiding Principles

### 1. Keep farmer-owned data farmer-owned

Spray plans, fields, and farmer operational records should not become globally visible just because the platform later supports service operators.

### 2. Share through explicit workflow objects

When data needs to cross between farmers and spraying services, it should happen through first-class entities such as:

- `service_requests`
- `jobs`
- `job_status_history`

Not through broad cross-table access to farmer records.

### 3. Use RLS as the main access boundary

Supabase Row Level Security should remain the primary enforcement layer.

App code should not be the only thing protecting data visibility.

### 4. Keep privileged actions in Edge Functions

Cross-user writes, notifications, and multi-step workflow automation should run in Edge Functions with controlled service-role access.

### 5. Design for migrations, not one-time schema dumps

As the backend becomes more complex, `schema.sql` alone will not be enough.

The project should move toward:

- versioned migrations
- repeatable seed strategy
- environment-aware deployment workflow

## Domain Roadmap By Phase

### Phase A: Stabilize Current Farmer Backend

Goal: Make the current farmer domain reliable and worth building on.

Focus:

- confirm current schema matches app behavior
- improve spray plan persistence visibility
- tighten existing RLS and indexes
- formalize migrations

Recommended tasks:

- move from ad hoc SQL editing toward Supabase migrations
- review all current RLS policies for insert/update/delete behavior
- add missing indexes for commonly queried farmer data
- define canonical status values and naming rules
- document current edge function responsibilities

Immediate schema review items:

- verify `spray_plan_chemicals` RLS expectations
- verify `danger_notifications` insert path only happens via backend logic
- confirm `fields_within_radius` and field visibility behavior align with product intent

### Phase B: Introduce Identity And Role Model

Goal: Support more than one kind of platform user.

Current limitation:

- `profiles` is farmer-centric

Recommended additions:

- `user_roles`
- `service_organizations`
- `service_users`

Suggested model:

- `profiles` remains user-centric for shared person/account data
- role assignment becomes explicit
- service organizations become separate top-level entities

Suggested new tables:

- `user_roles`
  - `user_id`
  - `role`
  - `organization_id` nullable
  - `created_at`

- `service_organizations`
  - `id`
  - `name`
  - `billing_email`
  - `phone`
  - `website`
  - `address`
  - `service_area`
  - `is_active`
  - `created_at`

- `service_users`
  - link between auth user/profile and service organization
  - manager/operator role inside the organization

Important:

Do not overload `crop_duster_services` into both public directory listing and full internal organization record unless the model stays clean. It may remain the public listing layer while `service_organizations` becomes the internal business entity.

### Phase C: Normalize Service Directory And Discovery

Goal: Turn the current crop duster listing into a real service-side domain.

Current state:

- `crop_duster_services` works as a public directory

Target state:

- public directory listing
- internal organization record
- optional approval/moderation lifecycle

Recommended options:

Option 1:

- keep `crop_duster_services` as the public-facing listing table
- add `service_organizations` as the operational entity

Option 2:

- replace `crop_duster_services` with a richer `service_organizations` table plus public visibility fields

Recommended direction:

- prefer separate public listing vs internal operational organization if the service portal is a serious product

Likely additions:

- `service_listing_status`
- `approved_at`
- `approved_by`
- `subscription_status`
- `service_categories`
- `coverage_rules`

### Phase D: Introduce Service Request Domain

Goal: Create the explicit bridge between farmer workflow and service workflow.

This is the most important backend addition for multi-role support.

Recommended new table:

- `service_requests`

Suggested fields:

- `id`
- `farmer_id`
- `spray_plan_id` nullable but likely useful
- `field_id`
- `target_service_organization_id` nullable if marketplace broadcast is allowed
- `status`
- `requested_date`
- `requested_service_notes`
- `shared_payload`
- `created_at`
- `updated_at`

Suggested statuses:

- `draft`
- `submitted`
- `viewed`
- `accepted`
- `declined`
- `withdrawn`
- `expired`
- `converted_to_job`

Important design rule:

The service request should define exactly what farmer data is shared with a service.

That allows:

- strong permission boundaries
- auditability
- future marketplace workflows

### Phase E: Introduce Jobs And Dispatch Domain

Goal: Support the service portal as an operational product.

Recommended new tables:

- `jobs`
- `job_status_history`
- `job_assignments`
- `equipment`
- `equipment_status_history`

Minimum practical MVP:

- `jobs`
- `job_status_history`

Suggested `jobs` fields:

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

Suggested statuses:

- `pending`
- `scheduled`
- `in_progress`
- `completed`
- `cancelled`
- `blocked_weather`
- `blocked_equipment`

Suggested `job_status_history` fields:

- `id`
- `job_id`
- `old_status`
- `new_status`
- `changed_by_user_id`
- `customer_visible`
- `note`
- `created_at`

### Phase F: Communication And Activity History

Goal: Stop burying communication inside one-off function calls.

Current state:

- outbound service contact and farmer notifications are mostly event-driven

Target state:

- persistent communication and workflow trail

Recommended future tables:

- `notification_events`
- `contact_events`
- `request_messages`

Use cases:

- store SMS/email delivery attempts
- track service contact attempts
- store status-change notifications
- expose customer-facing history later

This does not need to be first, but it becomes important once service workflow becomes commercial.

### Phase G: Reporting, Compliance, And Audit

Goal: Support serious operational use and future admin tooling.

Recommended additions:

- `audit_logs`
- `compliance_reports`
- `report_exports`
- possibly `document_files` via Storage

Use cases:

- admin support actions
- sensitive role-based changes
- export history
- job/spray-related compliance tracking

## Recommended Schema Modules

The schema should gradually be thought of in modules rather than one flat file.

Suggested domain modules:

- identity
- farmer_operations
- risk_and_notifications
- service_directory
- service_requests
- jobs_and_dispatch
- reporting_and_audit

Even if the project keeps a single generated schema snapshot, the migration files should be organized conceptually by these modules.

## Recommended Supabase Implementation Strategy

### Auth

Use Supabase Auth for all user identities.

Recommended practices:

- one auth identity per human user
- explicit role assignment table
- avoid encoding all authorization logic in raw user metadata

### Postgres

Use Postgres as the source of truth for all workflow state.

Recommended practices:

- use explicit status enums or constrained text values
- add `created_at` and `updated_at` consistently
- add supporting indexes when a table becomes query-heavy
- avoid storing important workflow state only in JSON

### RLS

RLS should enforce:

- farmer ownership
- service organization scope
- admin exceptions only where necessary

Recommended approach:

- use helper SQL functions for role checks as complexity grows
- keep policies readable and testable
- document each table’s read/write model

### Edge Functions

Use Edge Functions for:

- notification fanout
- request submission workflows
- cross-role writes
- secure multi-table transaction-like operations
- outbound integrations such as Twilio/SendGrid

Do not use client code for privileged cross-user operations.

### Realtime

Use Realtime for:

- danger notifications
- future service request updates
- future job status updates

Recommended principle:

- only enable Realtime on tables where live updates matter

### Storage

Use Supabase Storage for:

- avatars
- field photos
- compliance attachments
- exported documents

## Migration Roadmap

### Near Term

- keep `schema.sql` as the readable full snapshot
- start adding versioned migrations for all new backend work

### Mid Term

- create migration discipline for all schema changes
- separate seeds from schema
- create environment setup checklist for local/dev/prod

### Longer Term

- add automated schema deployment workflow
- add migration review/check process before releases

## RLS Evolution Roadmap

### Current RLS Model

- mostly farmer-owned
- public reads for crops, chemicals, and service directory

### Future RLS Model

Need support for:

- farmer-only ownership
- service-organization-scoped access
- request-scoped cross-party access
- admin support access

Recommended future helpers:

- function to test whether `auth.uid()` belongs to a service organization
- function to test whether a user is a service manager
- function to test whether a request/job belongs to the viewer’s organization

## Suggested Near-Term Supabase Backlog

1. Move to migration-based schema changes
2. Review and tighten current RLS coverage
3. Add missing spray-plan visibility/history support in app layer
4. Design `service_requests`
5. Design `service_organizations` and `service_users`
6. Design `jobs` and `job_status_history`
7. Add audit/event logging strategy

## Open Design Decisions

These should be resolved before building the service portal:

1. Is a farmer request sent to one service or many services?
2. Does one service organization have many users?
3. Are dispatcher and operator separate roles?
4. Does every accepted request become a job?
5. How much of job progress is visible back to the farmer?
6. Will billing/subscription data live inside Supabase or externally?

## Recommended Current Priority

Keep active implementation focused on the farmer mobile app.

Use this roadmap to make sure new backend work does not trap the platform in a farmer-only schema that will be hard to evolve later.

Immediate backend design work should focus on:

- migration discipline
- role model
- service request domain
- job domain

Those four areas are the main bridge from today’s app to the broader platform.
