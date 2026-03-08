# CropID Feature Matrix

This document separates feature responsibility across the three planned CropID product surfaces:

- Farmer mobile app
- Farmer web app
- Ag spraying service portal

The goal is to avoid building the same product three times and to keep each surface aligned with the work it is best suited for.

## Status Key

- `Now`: active or near-term priority
- `Later`: planned, but not current focus
- `No`: should not be a primary feature on that surface

## Product Roles

### Farmer Mobile App

Best for:

- field use
- quick logging
- on-the-go spray planning
- notifications
- fast contact actions

### Farmer Web App

Best for:

- office workflows
- map review on a larger screen
- plan history
- reporting
- scheduling and analysis

### Ag Spraying Service Portal

Best for:

- inbound request handling
- dispatch and scheduling
- customer/job management
- operational oversight
- commercial service workflow

## Core Feature Matrix

| Feature | Farmer Mobile | Farmer Web | Service Portal | Notes |
|---|---|---|---|---|
| Authentication | Now | Later | Later | Shared auth foundation, role-specific access |
| Profile management | Now | Later | Later | Same account concepts, different fields by role |
| Field map viewing | Now | Later | Later | Web version should be broader and more data-dense |
| Field creation/editing | Now | Later | No | Farmer-owned workflow |
| Adjacent field detection | Now | Later | No | Farmer risk-awareness feature |
| Chemical selection | Now | Later | No | Farmer workflow, not service workflow |
| Spray plan creation | Now | Later | No | Core farmer action |
| Spray plan saving | Now | Later | No | Already persists in backend; needs better surfaced history |
| Spray plan history/archive | Later | Later | No | Better fit for web once mobile flow stabilizes |
| Neighbor-risk detection | Now | Later | No | Core farmer safety logic |
| Risk alerts inbox | Now | Later | No | Mobile first, richer queue on web later |
| Push/local alerts | Now | No | No | Mobile-native feature |
| Weather-aware spray readiness | Later | Later | Later | Shared risk/input source, different presentations |
| Contact crop duster | Now | Later | No | Farmer outbound action |
| Saved crop duster directory | Now | Later | No | Farmer-facing service discovery |
| Compliance/report export | Later | Later | Later | More useful on web than mobile |
| Photo capture / field evidence | Later | Later | Later | Mobile capture, web review |
| Dashboard overview | Later | Later | Later | Different dashboard per product |

## Farmer Mobile Feature Breakdown

| Capability | Status | Why it belongs here |
|---|---|---|
| Field selection and quick map inspection | Now | Primary in-field interaction |
| Spray plan draft flow | Now | Fast mobile workflow tied to selected field |
| Neighbor-risk alerts | Now | Time-sensitive and mobile-friendly |
| Contact spraying services | Now | Immediate action from the field |
| Quick status capture / future logs | Later | Natural mobile behavior |
| Historical plan browsing | Later | Lower-value on small screens than desktop |
| Reporting/export | No | Better on web/desktop |

## Farmer Web Feature Breakdown

| Capability | Status | Why it belongs here |
|---|---|---|
| Dashboard with operations summary | Later | Strong desktop fit |
| Large-screen field map management | Later | Better visibility and planning context |
| Saved spray plan history | Later | Desktop is better for archive/review |
| Scheduling calendar/table | Later | Better on larger screens |
| Alert review and filtering | Later | Easier triage with table/panel layouts |
| Reporting/export/compliance views | Later | Desktop-first use case |
| Bulk editing and analysis tools | Later | Poor fit for mobile, strong fit for web |

## Ag Spraying Service Portal Feature Breakdown

| Capability | Status | Why it belongs here |
|---|---|---|
| Receive service requests | Later | Core commercial product workflow |
| Accept/decline incoming jobs | Later | Service-owned workflow |
| Dispatch/scheduling board | Later | Desktop operations use case |
| Territory/service area map | Later | Better on large screen |
| Customer/job queue | Later | Service management workflow |
| Equipment/fleet tracking | Later | Service portal concern, not farmer concern |
| Crew/team assignment | Later | Service portal concern |
| Message/contact history | Later | Service portal concern |
| Subscription/billing/admin | Later | Commercial service product need |

## Shared Backend Features

These should be treated as shared platform capabilities rather than UI-specific features:

- auth and role model
- fields
- spray plans
- chemicals
- danger/risk logic
- notifications
- crop duster service directory
- service requests
- job statuses
- audit/history records

## Recommended Delivery Order

### Short Term

- stabilize farmer mobile
- improve saved spray plan visibility
- continue refining rugged mobile UI
- keep web planning/documentation moving

### Mid Term

- launch public website
- define shared desktop component system
- build farmer web dashboard MVP

### Longer Term

- build ag spraying service portal MVP
- connect farmer-to-service workflow end to end
- add reporting, compliance, and operational analytics

## Immediate Product Clarifications Needed

These questions should be answered before full web implementation starts:

1. Does the farmer web app need full parity with mobile, or only planning/reporting parity?
2. Is the service portal a lead-management tool, a dispatch tool, or both?
3. Will service requests become first-class backend entities separate from spray plans?
4. What subscription model will apply to the service portal?
5. Which data is shared between farmers and services, and at what permission level?

## Current Recommendation

Continue active implementation on the farmer mobile app.

Use the farmer web app and ag spraying service portal docs for:

- planning
- architecture alignment
- future UI direction
- backend readiness decisions

Do not split execution focus too early. The mobile product should establish the workflow truth first.
