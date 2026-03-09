# Research: Mobile Core Stabilization

## Objective

Identify current reliability and clarity gaps in the farmer mobile core workflows and define validated decisions for implementation.

## Inputs Reviewed

- docs/ARCHITECTURE.md
- docs/FEATURE_MATRIX.md
- docs/PLATFORM_ROADMAP.md
- docs/IMPLEMENTATION_SEQUENCE.md
- specs/001-mobile-core-stabilization/spec.md

## Current-State Findings

1. Save trust gap
- Persistence exists, but user-visible save confirmation and retrieval clarity are inconsistent.

2. Alert flow gap
- Alert creation and inbox handling exist, but inbox coherence and read/review state clarity need hardening.

3. Contact handoff gap
- Plan-to-contact flow exists, but contact payload consistency from saved plan context must be explicit.

4. Terminology coherence gap
- Labels and states across map, planning, alerts, and contact can drift from actual behavior.

## Decisions

1. Treat save-state visibility as a first-class product requirement.
2. Use explicit user-visible state transitions for save and alert flows.
3. Keep data boundaries farmer-owned; no role expansion in this feature.
4. Keep scope constrained to mobile modules and current backend pathways.

## Risks And Mitigations

- Risk: Regressions in existing workflows while tightening state handling.
  - Mitigation: Add flow-level acceptance tests and staged manual validation.

- Risk: Ambiguous offline/unstable-network behaviors.
  - Mitigation: Explicit degraded-state UX and retry semantics.

- Risk: Hidden dependencies across providers and shared services.
  - Mitigation: Document provider interactions and verify per-flow state contracts.

## Exit Criteria For Research

- Canonical state models agreed for save and alert flows.
- Failure-mode behaviors defined for unstable network/save errors.
- Contact payload minimum required fields finalized.

## Validation Evidence (2026-03-08)

1. Save reliability hardening evidence
- `SprayPlan.isPersisted` updated to treat non-empty ID as persisted, preventing accidental insert path on existing plans.
- Chemical join writes now de-duplicate chemical IDs before insert/update writes.
- User-visible result: existing plans can be updated without duplicate-record failures.

2. Field/map workflow coherence evidence
- Field selection no longer auto-opens details modal.
- Field details moved to explicit on-demand action from active-field card.
- User-visible result: single primary surface by default on map screen.

3. Application Plan usability evidence
- Planning list now reserves bottom-safe scroll space to keep save CTA reachable above shell navigation.
- Saved plan list ordering now explicitly newest-first at render time.
- User-visible result: primary action remains reachable and recent work appears first.

4. Contact handoff evidence (US3)
- Added explicit saved-plan-to-contact payload mapper and provider.
- Contact send flow now validates required context and channel availability before function invocation.
- Service list now blocks unavailable-channel contact attempts with clear fallback notice.

5. Test execution evidence
- `flutter test test/features/crop_duster/contact_payload_prefill_test.dart test/features/crop_duster/contact_channel_fallback_test.dart` => PASS.
- `dart analyze` on changed US3 files => PASS (non-blocking lint info only).
