# Tasks: Farmer Web Dashboard MVP

**Input**: Design documents from `/specs/001-farmer-web-dashboard/`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`, `contracts/web-dashboard-workflow-contracts.md`, `quickstart.md`

**Tests**: No mandatory TDD scope was explicitly requested in the feature spec; this task list prioritizes implementation and validation workflows, with regression checks in final polish.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes an explicit file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish web dashboard module scaffolding and route entry points.

- [x] T001 Create farmer web feature module scaffold in `lib/features/farmer_web/`
- [x] T002 Add farmer web dashboard route constants in `lib/core/router/app_router.dart`
- [x] T003 [P] Create farmer web dashboard screen shell in `lib/features/farmer_web/presentation/screens/farmer_dashboard_screen.dart`
- [x] T004 [P] Create shared dashboard layout widgets (desktop rail/header/panel shell) in `lib/features/farmer_web/presentation/widgets/dashboard_layout.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core web auth/data boundary infrastructure that all user stories depend on.

**⚠️ CRITICAL**: No user story tasks should begin until this phase is complete.

- [ ] T005 Implement web route auth guard behavior for farmer-only dashboard access in `lib/core/router/app_router.dart`
- [ ] T006 [P] Add farmer web dashboard state model and loading/error/empty states in `lib/features/farmer_web/providers/dashboard_state_provider.dart`
- [ ] T007 [P] Create farmer web dashboard repository for aggregated field/plan/alert/request reads in `lib/features/farmer_web/data/farmer_dashboard_repository.dart`
- [ ] T008 Define farmer web domain view models for FieldSummary/ApplicationPlan/Alert/ServiceRequest in `lib/features/farmer_web/data/models/farmer_dashboard_models.dart`
- [ ] T009 Implement farmer-owned data scoping checks for dashboard queries in `lib/features/farmer_web/data/farmer_dashboard_repository.dart`
- [ ] T010 Add dashboard-wide status/empty/error copy constants aligned with mobile terminology in `lib/core/constants/app_constants.dart`

**Checkpoint**: Foundation complete; all user stories can proceed independently.

---

## Phase 3: User Story 1 - Review Farm Operations On Web (Priority: P1) 🎯 MVP

**Goal**: Farmer can sign in and reliably review field overview + saved application plans on a desktop-oriented dashboard.

**Independent Test**: Sign in as farmer, open dashboard, select field, open saved plans, apply filters, and confirm read-only detail reflects persisted records.

### Implementation for User Story 1

- [ ] T011 [P] [US1] Implement dashboard top-level composition (summary, field workspace, plan workspace) in `lib/features/farmer_web/presentation/screens/farmer_dashboard_screen.dart`
- [ ] T012 [P] [US1] Implement field map/list overview panel with selected-field state binding in `lib/features/farmer_web/presentation/widgets/field_overview_panel.dart`
- [ ] T013 [US1] Implement selected-field detail panel rendering in `lib/features/farmer_web/presentation/widgets/selected_field_panel.dart`
- [ ] T014 [P] [US1] Implement saved application plan list with newest-first ordering in `lib/features/farmer_web/presentation/widgets/application_plan_list_panel.dart`
- [ ] T015 [US1] Implement plan filter controls and in-session filter persistence in `lib/features/farmer_web/providers/application_plan_filter_provider.dart`
- [ ] T016 [US1] Implement read-only application plan detail panel in `lib/features/farmer_web/presentation/widgets/application_plan_detail_panel.dart`
- [ ] T017 [US1] Wire field and plan data retrieval into dashboard state provider in `lib/features/farmer_web/providers/dashboard_state_provider.dart`
- [ ] T018 [US1] Handle unauthenticated and session-expired transitions in dashboard screen flow in `lib/features/farmer_web/presentation/screens/farmer_dashboard_screen.dart`

**Checkpoint**: US1 delivers independently usable farmer web MVP value.

---

## Phase 4: User Story 2 - Triage Alerts Reliably On Desktop (Priority: P2)

**Goal**: Farmer can review and mark alerts as reviewed from web with persistent state coherence.

**Independent Test**: Open alert inbox, verify unread/reviewed labeling and ordering, mark reviewed, refresh, confirm persisted state.

### Implementation for User Story 2

- [ ] T019 [P] [US2] Implement alert inbox panel with unread/reviewed labels in `lib/features/farmer_web/presentation/widgets/alert_inbox_panel.dart`
- [ ] T020 [US2] Add alert sorting/filter state support in `lib/features/farmer_web/providers/alert_inbox_provider.dart`
- [ ] T021 [US2] Implement mark-reviewed action and persistence flow in `lib/features/farmer_web/providers/alert_review_provider.dart`
- [ ] T022 [US2] Add alert detail view panel with field/risk context in `lib/features/farmer_web/presentation/widgets/alert_detail_panel.dart`
- [ ] T023 [US2] Integrate alert inbox + review state into dashboard screen tabs/sections in `lib/features/farmer_web/presentation/screens/farmer_dashboard_screen.dart`

**Checkpoint**: US2 works independently for alert triage.

---

## Phase 5: User Story 3 - Track Service Request Status On Web (Priority: P3)

**Goal**: Farmer can view service request statuses and shared request context on web without cross-role leakage.

**Independent Test**: Open request status area, filter by status/date, open detail, verify records are farmer-owned and consistent.

### Implementation for User Story 3

- [ ] T024 [P] [US3] Implement service request status list panel with farmer-facing status chips in `lib/features/farmer_web/presentation/widgets/service_request_status_panel.dart`
- [ ] T025 [US3] Implement request status/date filter provider in `lib/features/farmer_web/providers/service_request_filter_provider.dart`
- [ ] T026 [US3] Implement request detail panel with shared snapshot fields in `lib/features/farmer_web/presentation/widgets/service_request_detail_panel.dart`
- [ ] T027 [US3] Add request status retrieval and farmer ownership checks in `lib/features/farmer_web/data/farmer_dashboard_repository.dart`
- [ ] T028 [US3] Integrate request-status workflow into dashboard section navigation in `lib/features/farmer_web/presentation/screens/farmer_dashboard_screen.dart`

**Checkpoint**: US3 independently provides farmer request-status tracking workflow.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Consistency hardening, validation, and release readiness across all stories.

- [ ] T029 [P] Align all farmer web labels with mobile terminology and "Application Plan" naming in `lib/features/farmer_web/presentation/`
- [ ] T030 Add explicit loading/empty/error handling pass for all dashboard sections in `lib/features/farmer_web/providers/dashboard_state_provider.dart`
- [ ] T031 [P] Add root web dashboard smoke test coverage in `test/features/farmer_web/farmer_dashboard_smoke_test.dart`
- [ ] T032 Execute quickstart validation scenarios and record outcomes in `specs/001-farmer-web-dashboard/quickstart.md`
- [ ] T033 Update implementation evidence and decisions in `specs/001-farmer-web-dashboard/research.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1; blocks all user stories.
- **Phase 3 (US1)**: Depends on Phase 2.
- **Phase 4 (US2)**: Depends on Phase 2; can proceed after US1 baseline dashboard shell is in place.
- **Phase 5 (US3)**: Depends on Phase 2; recommended after US1 repository/dashboard patterns are stable.
- **Phase 6 (Polish)**: Depends on completion of chosen user stories.

### User Story Dependencies

- **US1 (P1)**: Independent after foundational tasks; defines MVP.
- **US2 (P2)**: Independent after foundational tasks; reuses dashboard shell from US1.
- **US3 (P3)**: Independent after foundational tasks; reuses repository and section navigation patterns.

### Dependency Graph (Story Order)

- Foundation -> US1 -> US2
- Foundation -> US1 -> US3

---

## Parallel Execution Examples

### US1 Parallel Block

- Run T011 and T012 together (screen composition vs panel component files).
- Run T014 and T015 together (list rendering vs filter provider).

### US2 Parallel Block

- Run T019 and T022 together (inbox panel vs detail panel).

### US3 Parallel Block

- Run T024 and T026 together (status list panel vs detail panel).

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete all US1 tasks in Phase 3.
3. Validate US1 independent test criteria.
4. Demo/release MVP web dashboard baseline.

### Incremental Delivery

1. Add US2 for alert triage and validate reload/review persistence.
2. Add US3 for request-status tracking and validate filtering/context consistency.
3. Execute Phase 6 polish + scenario validation before broader rollout.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. After foundation:
   - Engineer A: US1
   - Engineer B: US2
   - Engineer C: US3
3. Converge in Phase 6 for terminology and validation hardening.

---

## Notes

- Every task follows the strict checklist format with explicit file paths.
- `[P]` tasks are parallel-safe because they target distinct files/components.
- User story phases are structured for independent delivery and validation.
