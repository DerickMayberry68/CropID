# Feature Specification: Farmer Web Dashboard MVP

**Feature Branch**: `001-farmer-web-dashboard`  
**Created**: 2026-03-08  
**Status**: Draft  
**Input**: User description: "Create spec `farmer-web-dashboard-mvp` for CropID to deliver a desktop-friendly farmer dashboard for fields, saved application plans, alerts, and service-request status with mobile-coherent terminology and behavior."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Review Farm Operations On Web (Priority: P1)

As a farmer, I can sign in on web and review my fields, active field details, and saved application plans in one desktop-oriented workspace so I can plan and coordinate work faster than on mobile.

**Why this priority**: This is the core value of the farmer web surface and the minimum feature set required for desktop usefulness.

**Independent Test**: Can be fully tested by signing in as a farmer, loading owned fields, selecting a field, opening saved plans, and confirming read-only plan details match persisted records.

**Acceptance Scenarios**:

1. **Given** an authenticated farmer with mapped fields, **When** the farmer opens the dashboard, **Then** the workspace shows field overview data and allows selecting a field for detail context.
2. **Given** saved application plans for the selected field, **When** the farmer opens plan history and filters results, **Then** the list and plan details reflect persisted data with newest records first.
3. **Given** the farmer is unauthenticated, **When** they attempt to access the dashboard, **Then** they are redirected to sign-in and cannot view farmer data.

---

### User Story 2 - Triage Alerts Reliably On Desktop (Priority: P2)

As a farmer, I can review alerts in a coherent inbox on web and mark items reviewed so safety-related notifications remain actionable and organized.

**Why this priority**: Alert visibility and triage is essential for safe coordination and should be available on desktop in addition to mobile.

**Independent Test**: Can be fully tested by loading alert history, verifying ordering/context, marking alerts reviewed, and confirming state persists after reload.

**Acceptance Scenarios**:

1. **Given** a farmer has unread alerts, **When** the farmer opens the web inbox, **Then** alerts display with clear unread/reviewed status and relevant context.
2. **Given** an unread alert, **When** the farmer marks it reviewed, **Then** the alert state updates and remains consistent on subsequent refreshes.

---

### User Story 3 - Track Service Request Status On Web (Priority: P3)

As a farmer, I can view my service request statuses on web so I can track progress with applicators without switching surfaces.

**Why this priority**: Request-status visibility is the bridge to future service workflows and is required to avoid fragmented farmer communication.

**Independent Test**: Can be fully tested by loading farmer-owned requests, viewing status timeline/details, and confirming only authorized request records are visible.

**Acceptance Scenarios**:

1. **Given** a farmer has submitted service requests, **When** they open the request-status area, **Then** each request shows current status and core shared context.
2. **Given** requests in different states, **When** the farmer filters by status/date, **Then** results and counts remain consistent with persisted backend records.

---

### Edge Cases
- Farmer account has no fields, plans, alerts, or requests: dashboard shows empty-state guidance without errors or misleading counts.
- Session expires during active use: user is prompted to re-authenticate and protected data is hidden until session is restored.
- Data updates from mobile while web is open: refresh or sync actions show updated field/plan/alert/request states without conflicting terminology.
- Farmer attempts to access another farmer's data via URL or filter manipulation: access is denied and only owned/authorized records are shown.
- A request references archived/deleted supporting context: request row remains visible with clear fallback labels instead of breaking the view.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide farmer authentication/session behavior on web consistent with existing farmer role boundaries.
- **FR-002**: The system MUST present a desktop-oriented field overview workspace with map/list context and selected-field detail panel.
- **FR-003**: The system MUST provide saved application plan visibility with filtering and read-only plan detail inspection.
- **FR-004**: The system MUST show saved application plans in newest-first order by default and preserve selected filters during the same session.
- **FR-005**: The system MUST provide alert inbox visibility with clear unread/reviewed state labels and coherent detail context.
- **FR-006**: The system MUST allow farmers to mark alerts reviewed and persist review-state changes across reloads.
- **FR-007**: The system MUST provide farmer-facing service-request status visibility, including current status and core shared request context.
- **FR-008**: The system MUST ensure fields, plans, alerts, and requests shown on web are limited to records the authenticated farmer is authorized to view.
- **FR-009**: The system MUST keep terminology and status language coherent with the mobile app, including use of "Application Plan" naming.
- **FR-010**: The system MUST provide clear empty, loading, and failure states for each workflow area without implying successful data retrieval when data is unavailable.
- **FR-011**: The system MUST keep this MVP scope limited to farmer web workflows and exclude applicator portal operations, billing/marketplace/admin tooling, and full dispatch/job management UI.

### Non-Goals

- Building applicator service portal workflows.
- Building billing, marketplace matching, subscription packaging, or admin-control tooling.
- Delivering full dispatch/scheduling optimization and job operations UI.
- Expanding cross-role permissions beyond existing farmer-authorized boundaries.

### Dependencies And Sequencing Notes

- This spec depends on completed mobile core stabilization as workflow truth for terminology and status expectations.
- Stage alignment:
  - Stage 6: Farmer web dashboard MVP delivery.
  - Stage 7 dependency awareness: request status visibility should align with service-request workflow evolution but not require full service portal build.
- Data availability for request status relies on service-request domain progression and must gracefully handle partial rollout states.

### Assumptions

- Farmer remains the active user role for this MVP surface.
- Existing farmer-owned data boundaries and authorization rules remain authoritative for web.
- A desktop-friendly dashboard layout improves planning/review speed relative to mobile for office workflows.
- Request status visibility can launch in MVP form before full service-portal operations are implemented.

### Key Entities *(include if feature involves data)*

- **Farmer Session**: Authenticated farmer access context used to gate all web data retrieval and actions.
- **Field Summary**: Farmer-owned field overview record used in map/list workspace and selected-field detail panel.
- **Application Plan Record**: Saved farmer plan entry with field linkage, plan status, chemical summary, and timestamp context.
- **Alert Record**: Neighbor-risk notification entry with affected field context and review-state status.
- **Service Request Record**: Farmer-owned request tracking record containing current status and shared request snapshot fields.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of farmers in MVP validation can sign in and complete field/plan/alert/request review workflow on first attempt without assistance.
- **SC-002**: At least 95% of dashboard page loads display field, plan, alert, and request sections with correct farmer-owned data in under 5 seconds under normal network conditions.
- **SC-003**: At least 99% of reviewed-alert actions persist correctly when the user refreshes and reopens the inbox.
- **SC-004**: At least 95% of sampled plan and request records match persisted backend values for status, timestamps, and linked field context.
- **SC-005**: At least 85% of validation users rate terminology/state coherence between mobile and web as clear (4/5 or better).
- **SC-006**: Support requests related to "cannot find my saved plan/alert/request on web" decrease by at least 30% within one release cycle after launch.
