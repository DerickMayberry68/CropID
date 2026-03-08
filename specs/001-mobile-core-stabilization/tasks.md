# Tasks: Mobile Core Stabilization

**Input**: Design documents from `/specs/001-mobile-core-stabilization/`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`, `contracts/workflow-state-contracts.md`, `quickstart.md`

**Tests**: Include targeted widget/provider tests because this feature explicitly requires independent testability for each user story and reliability validation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- All tasks include exact file paths

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create test and validation scaffolding used by all stories.

- [x] T001 Create feature test directory scaffold for story-level tests in `test/features/`
- [x] T002 Create shared widget test harness for Riverpod/Supabase mocking in `test/helpers/widget_test_harness.dart`
- [x] T003 [P] Create reusable farmer/field/spray-plan fixtures in `test/helpers/farmer_test_fixtures.dart`
- [x] T004 [P] Add feature-level validation checklist for quickstart scenario tracking in `specs/001-mobile-core-stabilization/checklists/validation.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core workflow-state and consistency foundations required by all user stories.

**⚠️ CRITICAL**: No user story work begins until this phase is complete.

- [x] T005 Define canonical spray-plan save lifecycle states in `lib/features/spray_planning/providers/spray_plan_save_state.dart`
- [x] T006 [P] Add shared backend error-to-user-message mapper used by feature providers in `lib/shared/services/supabase_service.dart`
- [x] T007 [P] Add deterministic ordering helpers for saved plans and notifications in `lib/core/utils/extensions.dart`
- [x] T008 Implement Save Result Contract wiring for terminal save outcomes in `lib/features/spray_planning/providers/spray_plan_provider.dart`
- [x] T009 [P] Implement Alert Inbox Contract normalization hooks in `lib/features/notifications/providers/notification_provider.dart`
- [x] T010 Add shared terminology constants for save/review/contact states in `lib/core/constants/app_constants.dart`

**Checkpoint**: Foundation ready; user stories can proceed independently.

---

## Phase 3: User Story 1 - Reliable Field And Spray Planning Flow (Priority: P1) 🎯 MVP

**Goal**: Farmer can reliably select fields, save spray plans, and see trustworthy saved-state results.

**Independent Test**: Create/save plans across multiple fields; verify accurate save confirmation, retrieval, and failure/retry behavior.

### Tests for User Story 1

- [x] T011 [P] [US1] Add widget test for successful spray-plan save confirmation in `test/features/spray_planning/spray_plan_save_success_test.dart`
- [x] T012 [P] [US1] Add widget test for failed save and retry behavior in `test/features/spray_planning/spray_plan_save_failure_retry_test.dart`
- [x] T013 [P] [US1] Add provider test for deterministic saved-plan retrieval state in `test/features/spray_planning/saved_plan_retrieval_test.dart`

### Implementation for User Story 1

- [x] T014 [P] [US1] Extend spray-plan model for save-state metadata support in `lib/features/spray_planning/data/models/spray_plan.dart`
- [x] T015 [P] [US1] Harden spray-plan persistence and retrieval mapping in `lib/features/spray_planning/data/chemical_repository.dart`
- [x] T016 [US1] Implement explicit save lifecycle transitions and retry behavior in `lib/features/spray_planning/providers/spray_plan_provider.dart`
- [x] T017 [US1] Harden field selection preconditions before plan initialization in `lib/features/farm_map/providers/farm_map_provider.dart`
- [x] T018 [US1] Surface explicit save status and saved-plan access in `lib/features/spray_planning/presentation/screens/spray_plan_screen.dart`
- [x] T019 [US1] Align danger banner behavior with save-state transitions in `lib/features/spray_planning/presentation/widgets/danger_alert_banner.dart`
- [x] T020 [US1] Align plan-save terminology and status messaging in `lib/features/spray_planning/presentation/screens/chemical_selector_screen.dart`

**Checkpoint**: US1 is independently functional and testable (MVP).

---

## Phase 4: User Story 2 - Trustworthy Risk Alerts (Priority: P2)

**Goal**: Farmer receives reliable, coherent risk alerts with clear unread/reviewed behavior.

**Independent Test**: Trigger risk alerts, verify inbox ordering/context, and confirm reviewed-state persistence.

### Tests for User Story 2

- [ ] T021 [P] [US2] Add widget test for notification inbox ordering and context rendering in `test/features/notifications/notifications_inbox_ordering_test.dart`
- [ ] T022 [P] [US2] Add provider test for mark-as-read persistence behavior in `test/features/notifications/notification_mark_read_test.dart`
- [ ] T023 [P] [US2] Add widget test for notification card reviewed/unreviewed visual state in `test/features/notifications/notification_card_state_test.dart`

### Implementation for User Story 2

- [ ] T024 [P] [US2] Harden notification data mapping and reviewed-state updates in `lib/features/notifications/data/notification_repository.dart`
- [ ] T025 [US2] Implement deterministic dedupe and ordering for realtime/new alerts in `lib/features/notifications/providers/notification_provider.dart`
- [ ] T026 [US2] Improve inbox loading, empty, and degraded-network states in `lib/features/notifications/presentation/screens/notifications_screen.dart`
- [ ] T027 [US2] Align alert context labels and reviewed status affordances in `lib/features/notifications/presentation/widgets/notification_card.dart`
- [ ] T028 [US2] Ensure plan-save alert handoff updates notification state coherently in `lib/features/spray_planning/providers/spray_plan_provider.dart`

**Checkpoint**: US2 works independently with reliable alert behavior.

---

## Phase 5: User Story 3 - Coherent Service Contact Handoff (Priority: P3)

**Goal**: Farmer can launch crop-duster contact from saved plan context with accurate prefilled data and clear fallbacks.

**Independent Test**: Start contact from saved plan; verify field/treatment/risk payload and unavailable-channel handling.

### Tests for User Story 3

- [ ] T029 [P] [US3] Add widget test for saved-plan-to-contact payload prefill in `test/features/crop_duster/contact_payload_prefill_test.dart`
- [ ] T030 [P] [US3] Add widget test for unavailable contact channel fallback states in `test/features/crop_duster/contact_channel_fallback_test.dart`

### Implementation for User Story 3

- [ ] T031 [P] [US3] Add contact payload mapper from saved-plan snapshot in `lib/features/crop_duster/providers/crop_duster_provider.dart`
- [ ] T032 [US3] Use saved-plan-derived payload consistently in message preview and send actions in `lib/features/crop_duster/presentation/screens/contact_screen.dart`
- [ ] T033 [US3] Add service availability and fallback messaging before contact initiation in `lib/features/crop_duster/presentation/screens/crop_duster_screen.dart`
- [ ] T034 [US3] Align service-card summary fields with contact payload expectations in `lib/features/crop_duster/presentation/widgets/service_card.dart`
- [ ] T035 [US3] Validate required contact payload fields before service invocation in `lib/features/crop_duster/data/crop_duster_repository.dart`

**Checkpoint**: US3 is independently functional with coherent contact handoff.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency, regression confidence, and validation evidence.

- [ ] T036 [P] Update quickstart validation flow to match implemented behavior in `specs/001-mobile-core-stabilization/quickstart.md`
- [ ] T037 Record executed validation evidence and outcomes in `specs/001-mobile-core-stabilization/research.md`
- [ ] T038 [P] Add regression smoke coverage for root app rendering path in `test/widget_test.dart`
- [ ] T039 Update feature validation checklist with pass/fail results in `specs/001-mobile-core-stabilization/checklists/validation.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1; blocks all user stories.
- **Phase 3 (US1)**: Depends on Phase 2 completion.
- **Phase 4 (US2)**: Depends on Phase 2 completion; can run in parallel with US1 after foundation, but recommended after US1 for lower risk.
- **Phase 5 (US3)**: Depends on Phase 2 completion and saved-plan state behavior from US1.
- **Phase 6 (Polish)**: Depends on completion of selected user stories.

### User Story Dependencies

- **US1 (P1)**: Independent after foundational work; defines MVP.
- **US2 (P2)**: Independent after foundational work; integrates save-trigger behavior but remains testable alone.
- **US3 (P3)**: Depends on stable saved-plan state contract from US1 for payload accuracy.

### Dependency Graph (Story Order)

- Foundation -> US1 -> US3
- Foundation -> US2

---

## Parallel Execution Examples

### US1 Parallel Block

- Run T011, T012, and T013 together (different test files).
- Run T014 and T015 together (different data files).

### US2 Parallel Block

- Run T021, T022, and T023 together (different test files).
- Run T024 and T026 together (data vs presentation files).

### US3 Parallel Block

- Run T029 and T030 together (different test files).
- Run T031 and T033 together (provider vs screen files).

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete all US1 tasks (Phase 3).
3. Validate US1 independently using quickstart Scenario A and B.
4. Demo or release MVP increment.

### Incremental Delivery

1. Add US2 and validate quickstart Scenario C.
2. Add US3 and validate quickstart Scenario D.
3. Complete Phase 6 polish tasks and final validation checklist.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. After foundation:
   - Engineer A: US1
   - Engineer B: US2
   - Engineer C: US3 (after US1 state contract is stable)

---

## Notes

- All tasks use strict checklist format and explicit file paths.
- `[P]` marks tasks safe for parallel execution (separate files, no unmet dependency).
- Keep each user story independently testable at its phase checkpoint before moving on.
