# CropID Platform Roadmap

This document outlines the phased approach for expanding CropID beyond the current farmer mobile app into a broader platform with desktop/web surfaces and a separate commercial-facing portal for ag spraying services.

## Product Tracks

CropID should be treated as three related products built on a shared backend and shared design language:

1. Farmer mobile app
2. Farmer desktop/web app
3. Ag spraying service web portal

The current active priority remains the farmer mobile app.

## Strategic Direction

The mobile app should continue as the primary build track until the core workflows feel stable and valuable. In parallel, we should plan the web products so they inherit the same data model, notification logic, risk logic, and visual system rather than branching into separate product definitions later.

The desktop/web direction should follow an operations-dashboard model:

- persistent left navigation
- high-signal operational summary cards
- map-centered workflow
- right-side status and risk panels
- table-based planning and scheduling views

This style is a better fit for office/desktop usage than simply stretching the mobile UI onto a larger screen.

## Desktop UI Reference

The provided desktop screenshot should be treated as a visual reference for the farmer web app and as a directional reference for the ag spraying service portal.

Key traits from the reference:

- fixed left sidebar navigation with grouped operational sections
- bold dashboard heading and status line at the top
- top-row KPI cards for operational summaries
- large central map panel as the main workspace
- right-side conditions and risk panels
- lower table section for scheduled operations and action tracking
- earthy agricultural palette with green, amber, red, and muted industrial tones
- high-density but still readable layout designed for office/PC use

What should carry into CropID web:

- dashboard-first layout rather than mobile-first layout
- map + status + table composition
- clear operational hierarchy
- obvious safety/risk emphasis
- practical management-console feel

What should not be copied blindly:

- placeholder weather/equipment modules unless they map to real CropID features
- generic field-management labels that do not match CropID terminology
- visual elements that imply functionality we do not yet support

For implementation planning, this screenshot should be considered a style and layout benchmark, not a literal one-to-one UI specification.

## Phased Roadmap

### Phase 0: Mobile Stabilization

Goal: Make the farmer mobile app feel complete enough to serve as the source of truth for workflows and UX patterns.

Focus:

- field management
- spray planning
- notifications and neighbor-risk alerts
- crop duster contact flow
- saved spray plan behavior and history expectations
- rugged agricultural visual identity

Definition of done:

- core workflows are reliable
- the mobile IA feels coherent
- domain entities and states are stable enough to reuse on web

### Phase 1: Shared Product Foundation

Goal: Define the system that all platform surfaces will build on.

Focus:

- shared design language and tokens
- shared backend/data model validation
- role and permission model
- reusable status vocabulary
- cross-platform information architecture

Key domain concepts to lock down:

- fields
- spray plans
- alerts
- chemicals
- crop duster services
- service requests
- statuses
- audit/history records

### Phase 2: Public Web Presence

Goal: Launch a public-facing website that explains the product and supports demos/sales before the full web apps are complete.

Suggested pages:

- Home
- Features
- Pricing
- Farmer workflow
- Ag spraying service workflow
- Contact / Demo request
- Login

Purpose:

- support sales conversations
- validate positioning
- provide an entry point for future web products

### Phase 3: Farmer Desktop/Web App MVP

Goal: Build the farmer experience for PC and office use.

This should prioritize workflows that are easier on a desktop than on a phone.

Suggested MVP modules:

- dashboard
- field map management
- spray plan history
- scheduling and status review
- alert review
- reporting / export

Design direction:

- left rail navigation
- dashboard cards at top
- central map workspace
- right-side operational panels
- bottom tables for plans and scheduled work

This product should feel like an operational dashboard, not a mobile app port.

### Phase 4: Ag Spraying Service Portal MVP

Goal: Build the separate commercial-facing portal sold to spraying services.

This should not be treated as a farmer feature. It is a separate role-based product with its own workflow priorities.

Suggested MVP modules:

- receive service requests
- manage incoming jobs
- map of assigned territory and job locations
- customer queue
- scheduling board
- equipment/team status
- contact/message history
- request status tracking

Positioning:

- operations console
- service team workflow tool
- commercial product distinct from the farmer app

### Phase 5: Cross-Platform Workflow Integration

Goal: Connect the farmer and spraying-service products into a complete workflow.

End-to-end workflow:

1. Farmer creates spray plan
2. Farmer requests spraying service
3. Service receives lead/job
4. Service accepts or updates status
5. Farmer sees progress and outcomes

Future additions:

- notifications
- audit trail
- attachments/photos
- compliance reporting
- exports and reporting

## Recommended Execution Order

To reduce product and engineering risk:

1. Finish the mobile core workflows
2. Create shared design tokens and visual rules
3. Launch the public marketing website
4. Build the farmer desktop/web dashboard MVP
5. Build the ag spraying service portal MVP

## What We Should Start Planning Now

These items should begin now, even while mobile remains the active implementation focus:

- product architecture for all three surfaces
- shared design system
- desktop information architecture
- service portal feature list
- backend roadmap for cross-role workflows
- pricing and packaging thoughts for service portal sales

## What We Should Delay

These should wait until the mobile app is more mature:

- full farmer desktop implementation
- full spraying-service portal implementation
- advanced reporting/admin surfaces

## Design Direction for Web Products

Use a rugged operational dashboard style inspired by agricultural workspaces and field operations.

Visual characteristics:

- earthy neutral surfaces
- crop green, amber, oxide red, and steel-blue accents
- strong typography
- card and panel hierarchy
- dashboard-oriented layouts
- map plus data-table composition

The desktop products should feel:

- grounded
- durable
- practical
- high-trust
- visually distinctive

## Current Product Priority

The current product priority remains the farmer mobile app.

Web planning should continue in parallel, but implementation effort should stay focused on mobile until the team feels confident in the core experience.
