# Feature Specification: Mobile Core Stabilization

**Feature Branch**: `001-mobile-core-stabilization`  
**Created**: 2026-03-07  
**Status**: Draft  
**Input**: User description: "Create spec `mobile-core-stabilization` for CropID to stabilize and polish the farmer mobile app so core workflows are reliable, coherent, and clearly reflect backend state."

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

### User Story 1 - Reliable Field And Spray Planning Flow (Priority: P1)

As a farmer, I can select a field, create a spray plan, save it, and immediately see confirmed saved state so I trust that my work is not lost.

**Why this priority**: This is the core production workflow and the highest-value action in the mobile product. If this is unreliable or unclear, the product fails its primary purpose.

**Independent Test**: Can be fully tested by creating and saving plans across multiple owned fields and verifying that each saved plan is visible with consistent status after app restarts and network interruptions.

**Acceptance Scenarios**:

1. **Given** an authenticated farmer with at least one field, **When** the farmer creates and saves a spray plan, **Then** the app shows an immediate success state and the saved plan is retrievable from a visible saved-plans surface.
2. **Given** the farmer edits a draft before saving, **When** the save action is completed, **Then** the stored plan reflects the latest edits and no stale values are shown in the confirmation state.
3. **Given** temporary connectivity loss during save, **When** the farmer attempts to save, **Then** the app shows clear failure or retry guidance and does not falsely indicate success.

---

### User Story 2 - Trustworthy Risk Alerts (Priority: P2)

As a farmer, I can rely on risk alerts to appear consistently and review them in a coherent inbox so I can make safe spraying decisions quickly.

**Why this priority**: Risk awareness is safety-critical and directly tied to user trust, but depends on the planning flow being functional first.

**Independent Test**: Can be fully tested by triggering risk conditions for adjacent fields and verifying alert creation, delivery, inbox visibility, unread/read state handling, and clear status labeling.

**Acceptance Scenarios**:

1. **Given** a spray plan that creates a neighboring risk condition, **When** the plan is saved, **Then** a corresponding alert is available in the recipient farmer’s alert inbox with accurate field and risk context.
2. **Given** an unread alert in the inbox, **When** the farmer opens and reviews it, **Then** the alert transitions to a reviewed state and remains visible in history.

---

### User Story 3 - Coherent Service Contact Handoff (Priority: P3)

As a farmer, I can move from a saved spray plan into contacting a crop duster with prefilled, accurate request context so outreach is fast and reliable.

**Why this priority**: This is a high-value downstream action after planning, but not as foundational as creating/saving plans and receiving alerts.

**Independent Test**: Can be fully tested by selecting a saved spray plan, launching service contact, and verifying that field, treatment, and risk summary context is accurate and complete in contact actions.

**Acceptance Scenarios**:

1. **Given** a saved spray plan with associated field and risk information, **When** the farmer opens the crop duster contact flow from that plan, **Then** the contact context includes the correct field identity, location context, and treatment summary.
2. **Given** the farmer returns to the same plan later, **When** they initiate contact again, **Then** the displayed contact context matches the current saved plan state.

---

### Edge Cases

- Save action is triggered repeatedly (double tap or rapid retries): only one final persisted result is represented to the user, and duplicate plan records are not created.
- A field is made private or otherwise becomes unavailable between plan draft and save: user receives a clear message and cannot save against invalid field context.
- Alert list loads while connectivity is unstable: previously loaded alerts remain visible with clear sync state rather than a blank or misleading screen.
- Service directory entries are inactive or missing contact channels: contact actions clearly indicate unavailable paths and offer fallback options.
- A saved plan references chemicals or labels that were updated: the app shows consistent terminology and does not mix outdated and current labels in the same view.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow farmers to select and manage their own fields reliably, with clear field identity and current status shown during planning actions.
- **FR-002**: The system MUST allow farmers to create, edit, and save spray plans with explicit and user-visible save outcomes (success, failure, retry needed).
- **FR-003**: The system MUST provide a visible saved-plans view where farmers can retrieve recently saved plans and distinguish draft-like states from saved states.
- **FR-004**: The system MUST ensure saved plan details shown in the mobile app match persisted backend state for field, treatment, and risk-summary data.
- **FR-005**: The system MUST prevent false-positive save confirmations; when persistence fails, users must receive clear corrective guidance.
- **FR-006**: The system MUST generate and present risk alerts consistently when neighbor-risk conditions are met and make those alerts accessible in a coherent inbox.
- **FR-007**: The system MUST allow farmers to review alert details and track alert state transitions (for example, unread to reviewed) with no ambiguity.
- **FR-008**: The system MUST provide a coherent handoff from saved spray plans to crop duster contact actions, carrying accurate plan context.
- **FR-009**: The system MUST preserve farmer data ownership boundaries and only expose data the farmer is authorized to view or share through existing workflows.
- **FR-010**: The system MUST apply consistent terminology and interaction patterns across field, planning, alert, and contact flows to reduce user confusion.
- **FR-011**: The system MUST maintain usable behavior during degraded network conditions by preserving last-known user-visible state and showing sync uncertainty explicitly.
- **FR-012**: The system MUST define this feature scope as mobile-core stabilization only and exclude farmer web dashboard, service portal, full service-request/job domains, marketplace, billing, and admin expansion.

### Non-Goals

- Build or launch the farmer web dashboard.
- Build or launch the ag spraying service portal.
- Introduce full service-request lifecycle or job-dispatch lifecycle.
- Expand role and permission models beyond current farmer-focused boundaries.
- Deliver billing, subscriptions, marketplace matching, or admin tooling.

### Dependencies And Sequencing Notes

- This feature depends on existing field, spray-plan, alert, and service-directory capabilities already available in the current product baseline.
- Stage alignment:
  - Stage 1 focus: workflow reliability and coherence for fields, plan creation/saving, alerts, and contact actions.
  - Stage 2 focus: mobile UX and persistence hardening, especially visible saved state and reduced invisible-save behavior.
- Future platform work (service request domain and schema expansion) is intentionally deferred and not required for this feature’s completion.

### Assumptions

- Farmers remain the only active product role for this feature.
- Existing backend persistence and notification pathways remain available and stable enough to support reliability hardening.
- Saved plan visibility can be improved within mobile scope without introducing new cross-role entities.
- “Reliable” means users can complete core actions repeatedly without contradictory UI state or silent failures.

### Key Entities *(include if feature involves data)*

- **Field**: Farmer-owned land unit used for spray planning; includes identity, visibility status, and location context needed for planning and risk evaluation.
- **Spray Plan**: Farmer-authored treatment plan linked to a field; includes treatment details, saved-state indicator, and timing context.
- **Risk Alert**: Safety notification generated from risk conditions; includes recipient farmer, field context, risk summary, and review status.
- **Crop Duster Service Listing**: Public service contact record selectable by farmers for outreach.
- **Contact Context Payload**: Structured summary derived from a saved spray plan and field context and used to prefill service contact actions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of farmers in validation testing can complete field selection, spray plan creation, and spray plan save without assistance on first attempt.
- **SC-002**: At least 99% of successful save operations display correct saved confirmation and are retrievable in the saved-plans view within 10 seconds.
- **SC-003**: In staged reliability testing, 100% of simulated save failures produce explicit failure messaging and zero false success confirmations.
- **SC-004**: At least 95% of triggered risk-alert events appear in recipient inbox views with accurate field/risk context within 30 seconds.
- **SC-005**: At least 90% of farmers in usability testing rate terminology and flow coherence across field, planning, alerts, and contact actions as clear (4/5 or better).
- **SC-006**: Support requests related to “missing saved plans” or “unclear save result” decrease by at least 40% within the first release cycle after launch.
