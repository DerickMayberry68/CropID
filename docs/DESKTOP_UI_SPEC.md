# CropID Desktop UI Spec

This document translates the desktop screenshot reference into a practical information architecture and layout specification for future CropID web products.

It is not a final visual design file. It is a planning document meant to guide product decisions, desktop wireframes, and eventual implementation.

## Purpose

The goal of the desktop experience is not to mirror the mobile app one-to-one. The desktop/web products should feel like operational workspaces built for office use, planning, scheduling, risk review, and data-heavy decision making.

This spec applies primarily to:

- Farmer desktop/web app
- Ag spraying service portal

The two products should share a design language, but each should have its own workflow emphasis.

## Core Desktop Design Principles

The desktop UI should feel:

- rugged
- operational
- high-trust
- data-aware
- map-centered
- efficient for frequent use

Desktop should optimize for:

- broad situational awareness
- faster scanning of multiple datasets
- table and map usage together
- operational decision support
- persistent navigation and context

## Layout Model

The reference screenshot implies a five-part layout model:

1. Left sidebar navigation
2. Top page header
3. KPI summary row
4. Main workspace zone
5. Lower detail zone

### 1. Left Sidebar Navigation

Purpose:

- persistent movement between major product areas
- visible operational grouping
- quick access to risk-heavy sections

Expected structure:

- brand block at top
- grouped navigation sections
- account / organization area at bottom

Suggested farmer web sections:

- Dashboard
- Field Map
- Spray Planning
- Chemicals
- Crop Dusters
- Risk Alerts
- Saved Plans
- Reports
- Profile / Settings

Suggested ag spraying service portal sections:

- Dashboard
- Incoming Requests
- Jobs / Schedule
- Service Area Map
- Customers
- Equipment / Fleet
- Team / Dispatch
- Alerts
- Billing / Subscription
- Settings

### 2. Top Page Header

Purpose:

- establish current page context
- show live operational summary
- hold global actions

Header contents:

- page title
- subtitle/status line
- organization / region / context label
- notification bell
- primary action button
- utility controls if needed

Farmer examples:

- `Dashboard`
- `North County Sector • 78°F • Wind 4 mph NW`
- `+ New Log`

Service portal examples:

- `Operations`
- `West Territory • 12 active jobs • 3 pending responses`
- `+ New Dispatch`

## KPI Summary Row

Purpose:

- provide immediate operational scan value
- show the most important counts/statuses at a glance

Card pattern:

- label
- large metric
- small contextual status
- optional icon/watermark
- strong state color

Suggested farmer KPI cards:

- Active Fields
- Spray Tasks
- Risk Alerts
- Neighbor Notifications

Suggested service portal KPI cards:

- Open Requests
- Scheduled Jobs
- High-Risk Conditions
- Active Equipment

Color guidance:

- green for normal / safe / active-ready
- amber for pending / due soon
- red for high risk / blocked
- steel-blue for system/equipment/informational states

## Main Workspace Zone

This is the core value area of the desktop product.

The screenshot suggests a two-column primary workspace:

- large map/content area on the left
- status/detail panel stack on the right

### Left Workspace

Farmer web app:

- field overview map
- selected field outline and status
- adjacent field risk overlays
- map mode toggles
- layer controls

Service portal:

- service territory map
- job markers
- customer locations
- route or cluster overview
- filterable operational layers

### Right Workspace

Farmer web app:

- field conditions
- spray suitability summary
- wind / soil / moisture / drift-related indicators
- selected alert summary

Service portal:

- job details
- dispatch status
- crew/equipment readiness
- weather risk summary
- customer instructions

## Lower Detail Zone

Purpose:

- support execution-oriented work after high-level review
- present structured records in tables or cards

Farmer web app lower-zone modules:

- Scheduled operations table
- Saved spray plans
- Recent alerts
- Compliance/reporting queue

Service portal lower-zone modules:

- Incoming request queue
- Active jobs table
- Customer activity
- Equipment maintenance list

## Farmer Web App Screen Model

### Dashboard

Primary modules:

- KPI summary cards
- field overview map
- field conditions / spray readiness panel
- current risk panel
- scheduled operations table
- quick actions

### Field Map

Primary modules:

- larger full-width map
- field list or filter panel
- selected field detail drawer
- adjacency/risk overlays

### Spray Planning

Primary modules:

- selected field summary
- selected chemical stack
- risk detection panel
- scheduling controls
- save/send actions

### Saved Plans

Primary modules:

- historical spray plans table
- status filters
- plan detail view
- duplicate/edit/archive actions

### Alerts

Primary modules:

- unread risk queue
- by-field grouping
- status filters
- detail side panel

## Ag Spraying Service Portal Screen Model

### Operations Dashboard

Primary modules:

- KPI row
- territory/jobs map
- incoming requests panel
- active jobs table
- equipment/team readiness

### Incoming Requests

Primary modules:

- request queue
- filters by urgency, location, customer, date
- request detail panel
- accept/decline/schedule actions

### Jobs / Schedule

Primary modules:

- schedule table or board
- status changes
- assigned crew/equipment
- weather risk flagging

### Service Area Map

Primary modules:

- service boundary
- customer and field markers
- route clusters
- territory filters

## Shared Component Guidance

Desktop components should feel substantial and structured.

Key component families:

- left nav items
- dashboard stat cards
- map panels
- status chips
- risk banners
- action bars
- data tables
- detail drawers
- right-rail panels

Component style:

- strong borders and panel separation
- dense but readable spacing
- large headings
- muted surfaces with strong accent colors
- obvious action buttons

## Responsive Behavior

Desktop-first does not mean fixed-width desktop only.

Recommended breakpoints:

- Large desktop: full dashboard layout
- Laptop / narrow desktop: compress right rail and card spacing
- Tablet landscape: reduce panel density and stack some sections
- Mobile: continue using the separate mobile-first UI patterns

Important:

- do not force the desktop dashboard structure onto mobile
- do not force the mobile shell onto desktop

## Relationship to Mobile

The mobile app should remain the interaction reference for core workflows.

The desktop products should:

- reuse the same domain logic
- preserve terminology
- preserve business rules
- adapt the layout to desktop tasks

Desktop should add:

- broader visibility
- richer tables
- more simultaneous context
- better planning and reporting tools

## What This Spec Is Not

This spec does not yet define:

- pixel-perfect wireframes
- final component library
- exact page counts
- implementation technology decisions
- final farmer vs service role permissions

Those should be added in later planning docs.

## Next Planning Docs Recommended

After this spec, the next useful documents would be:

1. Farmer web feature matrix
2. Ag spraying service portal feature matrix
3. Shared backend/domain roadmap
4. Desktop component inventory
5. Role and permission model
