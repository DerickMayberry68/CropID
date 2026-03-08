# CropID Implementation Sequence

This document turns the planning set into a practical execution order.

It is intentionally sequencing-oriented rather than feature-exhaustive. The purpose is to keep the team from splitting effort too early across mobile, farmer web, service portal, and backend platform work.

## Primary Rule

Active implementation should remain focused on the farmer mobile app until the core workflow is stable.

Parallel work is allowed only when it reduces future risk without derailing mobile delivery.

## Current Planning Inputs

This sequence is based on:

- `PLATFORM_ROADMAP.md`
- `DESKTOP_UI_SPEC.md`
- `FEATURE_MATRIX.md`
- `ROLE_AND_PERMISSION_MODEL.md`
- `BACKEND_DOMAIN_ROADMAP.md`
- `SERVICE_REQUEST_DOMAIN_SPEC.md`

## Sequence Overview

1. Mobile core stabilization
2. Mobile UX and persistence hardening
3. Backend discipline and migration readiness
4. Shared platform domain design
5. Public web presence
6. Farmer web dashboard MVP
7. Service request workflow implementation
8. Ag spraying service portal MVP
9. Cross-platform operational integration

## Stage 1: Mobile Core Stabilization

Goal:

- make the existing farmer mobile app operationally sound

Priority work:

- finish spray plan save clarity and history expectations
- harden field workflows
- harden alert flows
- harden crop duster contact flow
- continue rugged mobile UI refinement

Definition of done:

- farmer can manage fields reliably
- farmer can create and save spray plans reliably
- alerts work reliably
- crop duster contact flow feels coherent

## Stage 2: Mobile UX And Persistence Hardening

Goal:

- ensure the mobile app reflects the backend state clearly

Priority work:

- add visible saved spray plan behavior
- decide whether to add a plan history/archive view now or later
- align button labels and product language with real behavior
- reduce “invisible save” patterns

Why now:

- this closes the gap between current backend persistence and current user experience

## Stage 3: Backend Discipline And Migration Readiness

Goal:

- stop treating the database as a single evolving SQL dump

Priority work:

- move to migration-based Supabase changes
- define naming and status conventions
- review current RLS coverage
- establish schema change discipline

Deliverables:

- migration workflow
- schema review checklist
- updated backend planning docs

## Stage 4: Shared Platform Domain Design

Goal:

- define the future-safe backend shape before building web products

Priority work:

- role model
- service organization model
- service request domain
- job domain outline

Important:

- this stage is mostly design, not full implementation

## Stage 5: Public Web Presence

Goal:

- create a marketing and sales surface while mobile continues to mature

Priority work:

- home page
- product overview
- farmer workflow explanation
- spraying service workflow explanation
- contact/demo flow
- login entry points

Why this comes first on web:

- supports positioning and sales without requiring full dashboard products first

## Stage 6: Farmer Web Dashboard MVP

Goal:

- create a desktop planning and operations surface for farmers

Priority work:

- dashboard shell
- desktop navigation
- field overview workspace
- saved spray plan review
- alerts review
- scheduling/reporting skeleton

Dependency:

- mobile workflow should already be stable enough to reuse

## Stage 7: Service Request Workflow Implementation

Goal:

- add the first real bridge between farmer products and service-side products

Priority work:

- implement `service_requests`
- request submission workflow
- request status visibility
- request notification flow

Why this stage matters:

- it is the hinge between “contact a service” and “operate a real service portal”

## Stage 8: Ag Spraying Service Portal MVP

Goal:

- launch the first service-side operational product

Priority work:

- request intake queue
- accept/decline workflow
- dashboard shell
- job list / schedule
- customer and field context panel

Not required yet:

- advanced dispatch
- fleet management
- billing depth

## Stage 9: Cross-Platform Operational Integration

Goal:

- make the full farmer-to-service workflow visible on both sides

Priority work:

- request conversion to job
- job status feedback to farmer
- status history
- communication history
- compliance and reporting support

## Suggested Work Streams

### Stream A: Active Build Stream

- farmer mobile app

### Stream B: Architecture/Platform Stream

- backend domain design
- RLS strategy
- migration discipline

### Stream C: Future Product Planning

- farmer web
- service portal
- desktop design system

The active build stream should get the most engineering effort.

## What To Avoid

- building farmer web and service portal before the request/job domain is clear
- copying mobile UI directly into desktop layouts
- exposing farmer spray plans directly to service users
- building admin concepts before role boundaries are stable

## Recommended Immediate Next Moves

1. Continue refining mobile
2. Add visible saved spray plan behavior
3. Move new backend changes to migrations
4. Prepare Spec Kit specs from the current planning set

## Spec Kit Spec Candidates In Order

Recommended first specs:

1. Mobile Core Stabilization
2. Saved Spray Plans And History
3. Service Request Domain
4. Supabase Schema V2
5. Farmer Web Dashboard MVP
6. Ag Spraying Service Portal MVP
