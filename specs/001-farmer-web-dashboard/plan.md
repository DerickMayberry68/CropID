# Implementation Plan: Farmer Web Dashboard MVP

**Branch**: `001-farmer-web-dashboard` | **Date**: 2026-03-08 | **Spec**: [spec.md](/c:/Users/deric/source/repos/StudioXConsulting/Projects/CropID/specs/001-farmer-web-dashboard/spec.md)
**Input**: Feature specification from `/specs/001-farmer-web-dashboard/spec.md`

## Summary

Deliver a desktop-first farmer web dashboard MVP that provides reliable visibility into fields, saved application plans, alerts, and service-request statuses with terminology consistent with mobile and strict farmer data boundaries.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: Flutter SDK, Riverpod, go_router, Supabase Flutter client, flutter_map  
**Storage**: Supabase Postgres (including existing farmer-owned entities and request-status records), optional local browser cache for session/runtime state  
**Testing**: flutter_test (widget/provider tests), manual scenario validation from quickstart  
**Target Platform**: Web browsers for desktop workflows (Chrome/Edge/Safari/Firefox recent versions)  
**Project Type**: Single Flutter application with role-scoped farmer web surface  
**Performance Goals**: Dashboard sections load with usable data within 5 seconds in normal network conditions; alert review and status updates reflect within one refresh cycle  
**Constraints**: Preserve existing RLS boundaries; no cross-role leakage; maintain terminology coherence with mobile; keep MVP read-focused for plans  
**Scale/Scope**: Farmer web MVP only (fields overview, plan visibility, alerts, request status); excludes service portal and dispatch-depth features

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Status: Conditional pass.
- Constitution file `.specify/memory/constitution.md` is still a placeholder template with no enforceable project-specific rules.
- Provisional gates applied from project docs and active specs:
  - Farmer-owned data privacy and least-privilege boundaries preserved: PASS
  - No cross-role data leakage introduced: PASS
  - Scope remains farmer web MVP only: PASS
  - Mobile terminology/workflow consistency preserved: PASS
  - No premature service-portal or admin expansion in this spec: PASS

## Project Structure

### Documentation (this feature)

```text
specs/001-farmer-web-dashboard/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── web-dashboard-workflow-contracts.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── app.dart
├── core/
│   ├── router/
│   ├── shell/
│   ├── constants/
│   └── theme/
├── features/
│   ├── auth/
│   ├── farm_map/
│   ├── spray_planning/
│   ├── notifications/
│   └── crop_duster/
└── shared/
    ├── services/
    └── widgets/

test/
├── features/
└── widget_test.dart

specs/
└── 001-farmer-web-dashboard/
```

**Structure Decision**: Keep a single Flutter codebase and implement farmer web dashboard capabilities within existing feature modules, adding role-scoped web-oriented screens/providers while reusing shared domain models and auth boundaries.

## Phase 0: Research Plan

- Validate best-practice approach for desktop-oriented Flutter web IA without diverging product terminology from mobile.
- Define how request-status visibility should be introduced in farmer web MVP while service-request domain is still evolving.
- Confirm safeguards for URL-driven access control and filter-driven data retrieval under existing farmer RLS model.

## Phase 1: Design Plan

- Produce a data model for web dashboard entities and state transitions aligned with spec requirements.
- Define workflow contracts for:
  - field overview and selected-field panel behavior
  - saved application plan list/detail behavior
  - alert inbox review transitions
  - farmer-facing service-request status views
- Provide validation quickstart scenarios covering normal, empty, and failure states.
- Run agent context update script for Codex.

## Post-Design Constitution Check

- Re-evaluated after design artifacts:
  - Privacy and role boundaries remain explicit in data model/contracts: PASS
  - Scope remains bounded to farmer web MVP workflows: PASS
  - No constitution-defined hard violations present (template constitution still non-operative): PASS

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
