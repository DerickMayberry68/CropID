# Implementation Plan: Mobile Core Stabilization

**Branch**: `001-mobile-core-stabilization` | **Date**: 2026-03-07 | **Spec**: [spec.md](/c:/Users/deric/source/repos/StudioXConsulting/Projects/CropID/specs/001-mobile-core-stabilization/spec.md)
**Input**: Feature specification from `/specs/001-mobile-core-stabilization/spec.md`

## Summary

Stabilize the farmer mobile core workflows so field selection/management, spray-plan save visibility, risk alerts, and crop-duster contact handoff are reliable and coherent. The implementation approach is incremental hardening within existing app architecture, focusing on user-visible state clarity, save/alert reliability, and terminology consistency without introducing new cross-role domains.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_riverpod`, `go_router`, `supabase_flutter`, `flutter_map`, `hive_flutter`, `url_launcher`  
**Storage**: Supabase Postgres (with PostGIS), Supabase Realtime, local cache via Hive  
**Testing**: `flutter_test` (widget/integration additions required for this feature)  
**Target Platform**: Farmer mobile app (Android and iOS)  
**Project Type**: Mobile app with Supabase backend services  
**Performance Goals**: Save confirmation shown quickly and accurately; alerts and saved-state surfaces update fast enough for in-field workflows  
**Constraints**: Mobile-first scope only; no cross-role data leakage; no new web/service portal work; incremental changes over redesign  
**Scale/Scope**: Existing mobile modules only (`farm_map`, `spray_planning`, `notifications`, `crop_duster`), with shared service/provider hardening

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Status: Conditional pass with provisional gates.
- Note: `.specify/memory/constitution.md` is currently a placeholder template, so explicit constitutional rules are not yet codified.
- Provisional gates applied from project planning docs:
  - Mobile-first product truth preserved: PASS
  - Least-privilege and farmer-owned data boundaries preserved: PASS
  - Supabase-first backend discipline preserved: PASS
  - Rugged field-usable UX improvements prioritized: PASS
  - No broad cross-role data leakage introduced: PASS
  - No major platform/domain expansion without separate spec: PASS

## Project Structure

### Documentation (this feature)

```text
specs/001-mobile-core-stabilization/
├── plan.md
├── spec.md
├── checklists/
│   └── requirements.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── workflow-state-contracts.md
└── tasks.md             # Produced by /speckit.tasks
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/
│   ├── router/
│   ├── shell/
│   ├── theme/
│   └── utils/
├── features/
│   ├── farm_map/
│   ├── spray_planning/
│   ├── notifications/
│   └── crop_duster/
└── shared/
    ├── services/
    └── widgets/

supabase/
├── schema.sql
├── seed_chemicals.sql
└── functions/
    ├── send_notification/
    └── contact_crop_duster/

test/
└── widget_test.dart
```

**Structure Decision**: Use the existing Flutter mobile + Supabase structure; implement this feature by hardening current feature modules and shared services rather than adding new app surfaces or new top-level projects.

## Phase Plan

### Phase 0: Research And Baseline

- Document current user-visible state transitions for:
  - field selection and plan save
  - alert inbox and alert read flow
  - plan-to-contact handoff
- Identify failure modes causing invisible save, stale UI state, or ambiguous alert state.
- Define baseline metrics for save trust and alert reliability for before/after comparison.

### Phase 1: Design And Data-State Mapping

- Specify canonical user-visible states for plan save lifecycle (idle, saving, saved, failed, retry-needed).
- Define consistency rules between persisted plan state and displayed plan state.
- Define alert inbox state model (unread/reviewed/history) and transition expectations.
- Define required contact-context payload fields from saved plans.
- Produce:
  - `research.md`
  - `data-model.md`
  - `quickstart.md`
  - `contracts/` artifacts for any interface-level expectations between app layers

### Phase 2: Implementation And Verification

- Implement field and spray-plan workflow hardening.
- Implement visible saved-plan retrieval and state clarity improvements.
- Implement alert flow reliability and state-transition clarity.
- Implement contact handoff context consistency from saved plans.
- Add/expand automated tests and manual validation scripts for acceptance scenarios.
- Verify measurable outcomes in the feature spec success criteria.

## Implementation Alignment Updates (2026-03-08)

- Completed map interaction simplification to reduce dual-surface confusion:
  - field selection no longer auto-opens a bottom flyout
  - field detail flyout is now explicit from top operations surface
- Completed terminology alignment in implemented mobile surfaces to use "Application Plan".
- Completed spray-plan persistence hardening:
  - existing plans now reliably follow update path
  - chemical associations are de-duplicated before persistence
  - saved plans are editable and can transition to completed state
- Completed mobile viewport hardening on planning screen:
  - bottom-safe scroll spacing ensures primary save action remains reachable above shell navigation
- Edge-function auth behavior hardened for secure invocation retry and clearer failure messages.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
