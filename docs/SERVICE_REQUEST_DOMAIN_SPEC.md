# CropID Service Request Domain Spec

This document defines the proposed `service_request` domain for CropID.

It exists to solve the most important future platform boundary:

- farmers need to request spraying services
- spraying services need enough information to review and accept work
- farmer-owned operational data must not become broadly visible to services

The `service_request` object should be the formal bridge between the farmer products and the ag spraying service portal.

## Purpose

Today, the product flow is:

1. farmer creates a spray plan
2. farmer browses crop duster services
3. farmer contacts a service

That flow works for lightweight outreach, but it is not strong enough for a full marketplace or dispatch product because it lacks:

- a durable request record
- status tracking
- scoped data sharing
- workflow ownership boundaries
- an operational handoff into the service portal

The `service_request` domain is intended to provide that structure.

## Primary Design Goals

The service request model should:

- preserve farmer ownership of core farm data
- explicitly define what is shared with a service
- support one-way outreach and future two-way workflows
- work for both mobile-first and desktop-first experiences
- allow future conversion into a service-side job
- support auditability and status tracking

## Core Principles

### 1. A service request is not the same as a spray plan

A spray plan is a farmer-owned operational planning record.

A service request is a cross-party workflow object created from, or alongside, a spray plan.

That distinction matters because:

- spray plans should stay private to the farmer by default
- only request-scoped data should be visible to the service

### 2. Shared data should be explicit

The request should carry its own shared snapshot or shared fields rather than forcing the service portal to read broad farmer-side tables directly.

### 3. Requests should support a status lifecycle

Even the first MVP should not behave like an untracked contact event.

At minimum, a request should move through clear statuses.

### 4. Requests should be convertible into jobs

If the service accepts the work, the request should be able to spawn or link to a `job`.

## Domain Scope

The service request domain sits between:

- farmer workflow
- service discovery
- service acceptance/rejection
- future dispatch/job handling

Related objects:

- `spray_plans`
- `fields`
- `crop_duster_services` or future `service_organizations`
- future `jobs`
- future `job_status_history`

## Recommended Table

Recommended new table:

- `service_requests`

## Recommended Core Fields

### Identity And Relationships

- `id`
- `farmer_id`
- `spray_plan_id` nullable
- `field_id`
- `target_service_organization_id` nullable
- `target_service_listing_id` nullable if public listing and org are still separated

### Request Content

- `request_title`
- `requested_service_notes`
- `requested_date`
- `requested_window_start`
- `requested_window_end`
- `urgency`

### Shared Snapshot

This data should reflect what the farmer is intentionally sharing with the service.

Suggested snapshot fields:

- `shared_field_name`
- `shared_field_location_summary`
- `shared_crop_name`
- `shared_chemical_names`
- `shared_danger_count`
- `shared_map_link`
- `shared_coordinates`

Recommended implementation approach:

- use explicit columns for high-value/filterable items
- use JSON only for flexible supplemental payload if needed

### Status And Workflow

- `status`
- `submitted_at`
- `viewed_at`
- `responded_at`
- `accepted_at`
- `declined_at`
- `withdrawn_at`
- `converted_to_job_at`

### Audit Metadata

- `created_at`
- `updated_at`
- `created_by_user_id`
- `last_status_changed_by_user_id`

## Recommended Status Lifecycle

Suggested initial status values:

- `draft`
- `submitted`
- `viewed`
- `accepted`
- `declined`
- `withdrawn`
- `expired`
- `converted_to_job`

### Status Meaning

`draft`
- request exists but has not yet been sent to a service

`submitted`
- request has been formally sent

`viewed`
- service has opened or acknowledged the request

`accepted`
- service intends to take the work

`declined`
- service rejected the request

`withdrawn`
- farmer cancelled the request

`expired`
- request timed out or is no longer actionable

`converted_to_job`
- request has been turned into a service-side operational job

## Request Creation Rules

### Initial Recommendation

A farmer should be able to create a service request from:

- a saved spray plan
- a current selected field workflow

Preferred product rule:

- service request should usually link to a `spray_plan_id`

Reason:

- preserves a stable internal relationship
- allows future history/reporting
- avoids duplicating farmer planning logic

However:

- service visibility should still be restricted to request-scoped shared data

### Request Creation Inputs

Suggested required inputs:

- farmer identity
- field reference
- selected service
- request note or request intent

Suggested optional inputs:

- linked spray plan
- preferred date/window
- chemicals to be used
- risk context

## Data Sharing Model

The request should define what a service can see.

### Service Should Typically See

- farmer name or farm name
- field name
- approximate location or approved map link
- crop name if relevant
- relevant chemicals if intentionally shared
- timing window
- service notes
- request status

### Service Should Not Automatically See

- all farmer fields
- all spray plan history
- unrelated farmer notifications
- private internal farmer notes unrelated to the request

## One-Service vs Multi-Service Model

This is a major product decision.

### Option A: One Request, One Service

Pros:

- simpler permissions
- simpler workflow
- easier status tracking
- easier MVP

Cons:

- less marketplace flexibility

### Option B: One Farmer Intent, Many Service Targets

Pros:

- better marketplace or bidding model
- easier comparison across service providers

Cons:

- more complex permissions
- more complex status logic
- more complex UX

### Recommended MVP

Use:

- one request sent to one service

If multi-service workflows become important later, introduce a parent object such as:

- `service_request_groups`

and treat each service-facing request as its own child request record.

## Relationship To Jobs

When a service accepts a request, the request should either:

- create a linked `job`
- or be manually converted into a `job`

Recommended future field:

- `job_id` nullable

Recommended workflow:

1. request is `submitted`
2. service reviews request
3. service accepts request
4. backend creates `job`
5. request status becomes `converted_to_job`

This keeps request and job concerns separate:

- request = intake and decision
- job = execution and dispatch

## RLS Model

Recommended RLS intent for `service_requests`:

### Farmer

- can create their own requests
- can read their own requests
- can withdraw or edit allowed fields while request is not yet accepted

### Service Operator / Service Manager

- can read requests assigned to their organization
- can update only allowed workflow fields
- cannot rewrite farmer-owned content beyond controlled response fields

### Platform Admin

- limited oversight access with audit expectations

## Recommended RLS Policy Concepts

These may eventually be implemented using helper SQL functions:

- request belongs to farmer
- request belongs to service organization
- current user is service manager
- request is still editable by farmer

## Edge Function Responsibilities

The request workflow should use Edge Functions for cross-role operations.

Recommended function responsibilities:

- submit request
- notify targeted service
- transition accepted request into job
- notify farmer of service response

Reasons:

- avoids privileged client-side writes
- centralizes workflow validation
- keeps audit and status logic consistent

## Realtime Opportunities

`service_requests` are a strong candidate for Realtime once the service portal exists.

Useful live events:

- farmer submits request
- service views request
- service accepts/declines
- request converted to job

Realtime audiences:

- farmer app/web
- service portal

## Recommended First MVP Scope

The MVP service request domain should support:

- one farmer submits one request to one service
- request links to a spray plan when available
- service can view and accept/decline
- farmer can see request status
- request can later convert into a job

That is enough to support meaningful platform growth without prematurely overbuilding marketplace complexity.

## Suggested Table Shape For MVP

Suggested initial fields:

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

This is intentionally pragmatic rather than maximal.

## Recommended Follow-On Tables

After the MVP, likely additions:

- `service_request_status_history`
- `service_request_messages`
- `service_request_attachments`
- `service_request_groups` if multi-service workflows are added

## Product Impact

Once this domain exists:

- the farmer mobile app can show durable service request history
- the farmer web app can show request tracking and filtering
- the service portal can operate from a real intake queue
- the backend gains a clean bridge between planning and execution workflows

## Open Questions

These still need product decisions:

1. Does a farmer request include exact chemicals by default, or is that optional?
2. Should a service be able to counter-propose timing or terms inside the platform?
3. Can a farmer edit a submitted request, or only withdraw and recreate it?
4. What farmer contact details are shared automatically?
5. Should service requests expire automatically after a configured time window?

## Recommendation

Make `service_requests` the next major backend domain after the current farmer-mobile backend is stabilized.

It is the cleanest way to:

- preserve security boundaries
- support the future service portal
- create a durable operational workflow between the two sides of the platform
