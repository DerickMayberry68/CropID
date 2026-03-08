# CropID Spec Kit Prep

This document organizes the current planning set into Spec Kit-ready inputs.

It is intended to make the transition from planning documents to executable specs straightforward once Spec Kit is initialized in this repository.

## Purpose

The current docs are planning and architecture documents.

Spec Kit works best when those documents are translated into discrete specification units with:

- clear scope
- explicit goals
- constraints
- acceptance boundaries

This document identifies the spec candidates and the source material each spec should use.

## Current Planning Docs

- `PLATFORM_ROADMAP.md`
- `DESKTOP_UI_SPEC.md`
- `FEATURE_MATRIX.md`
- `ROLE_AND_PERMISSION_MODEL.md`
- `BACKEND_DOMAIN_ROADMAP.md`
- `SERVICE_REQUEST_DOMAIN_SPEC.md`
- `IMPLEMENTATION_SEQUENCE.md`
- `SUPABASE_SCHEMA_V2_PLAN.md`

## Recommended Initial Spec Backlog

Recommended spec order:

1. Mobile Core Stabilization
2. Saved Spray Plans And History
3. Service Request Domain
4. Supabase Schema V2
5. Farmer Web Dashboard MVP
6. Ag Spraying Service Portal MVP

## Spec Candidate 1: Mobile Core Stabilization

Purpose:

- improve the current mobile product without introducing new platform complexity

Primary source docs:

- `PLATFORM_ROADMAP.md`
- `FEATURE_MATRIX.md`
- `IMPLEMENTATION_SEQUENCE.md`

Likely feature areas:

- field workflow polish
- spray plan flow polish
- alert workflow polish
- crop duster contact polish
- rugged UI consistency

## Spec Candidate 2: Saved Spray Plans And History

Purpose:

- turn backend persistence into visible product value

Primary source docs:

- `FEATURE_MATRIX.md`
- `IMPLEMENTATION_SEQUENCE.md`
- current code behavior in `spray_plans`

Likely scope:

- saved plan visibility
- history/archive screen
- terminology alignment
- farmer-facing retrieval and status review

## Spec Candidate 3: Service Request Domain

Purpose:

- define the bridge object between farmer workflows and future service workflows

Primary source docs:

- `SERVICE_REQUEST_DOMAIN_SPEC.md`
- `ROLE_AND_PERMISSION_MODEL.md`
- `BACKEND_DOMAIN_ROADMAP.md`

Likely scope:

- request lifecycle
- shared data model
- request statuses
- request permissions
- request creation flow

## Spec Candidate 4: Supabase Schema V2

Purpose:

- plan the database and RLS expansion required for multi-role support

Primary source docs:

- `BACKEND_DOMAIN_ROADMAP.md`
- `SUPABASE_SCHEMA_V2_PLAN.md`
- `ROLE_AND_PERMISSION_MODEL.md`

Likely scope:

- roles
- service organizations
- service requests
- jobs
- RLS evolution
- migration grouping

## Spec Candidate 5: Farmer Web Dashboard MVP

Purpose:

- define the first desktop experience for farmers

Primary source docs:

- `DESKTOP_UI_SPEC.md`
- `FEATURE_MATRIX.md`
- `PLATFORM_ROADMAP.md`

Likely scope:

- dashboard layout
- field overview workspace
- saved spray plan review
- alert review
- desktop navigation and workspace composition

## Spec Candidate 6: Ag Spraying Service Portal MVP

Purpose:

- define the first commercial-facing portal for spraying services

Primary source docs:

- `PLATFORM_ROADMAP.md`
- `DESKTOP_UI_SPEC.md`
- `FEATURE_MATRIX.md`
- `ROLE_AND_PERMISSION_MODEL.md`
- `SERVICE_REQUEST_DOMAIN_SPEC.md`

Likely scope:

- incoming request queue
- request review workflow
- dashboard shell
- initial job and status workflow

## Recommended Spec Kit Workflow For This Repo

Once Spec Kit is initialized, recommended first commands/concepts are:

1. Establish constitution
2. Create the first mobile-focused spec
3. Create the service-request spec
4. Create the schema-v2 spec
5. Move on to web dashboard and service portal specs

## Recommended Constitution Themes

When creating the project constitution, emphasize:

- mobile-first product truth
- least-privilege data access
- Supabase-first backend discipline
- rugged field-usable UX
- no broad cross-role data leakage
- spec before implementation for major platform changes

## Suggested Spec Kit Spec Names

Suggested naming direction:

- `mobile-core-stabilization`
- `saved-spray-plans-history`
- `service-request-domain`
- `supabase-schema-v2`
- `farmer-web-dashboard-mvp`
- `ag-spraying-service-portal-mvp`

## What Is Ready Now

Ready for Spec Kit use:

- product direction
- desktop IA direction
- feature ownership split
- role model
- backend roadmap
- service request domain
- implementation order
- schema-v2 planning

## What Still Needs Clarification Later

- exact service marketplace model
- billing/subscription approach for service portal
- exact job/dispatch depth for V1 service portal
- admin tooling scope

## Recommendation

Initialize Spec Kit in this repository and use the docs above as source material rather than rewriting the strategy from scratch.

The first two specs should remain mobile and backend-domain focused before shifting execution energy toward web products.
