# Quickstart: Mobile Core Stabilization Validation

## Goal

Validate that the stabilized mobile core workflows satisfy spec acceptance scenarios and measurable outcomes.

## Preconditions

- Farmer account with at least two owned fields
- Chemical and crop data available
- At least one active crop duster listing
- Test environment with controllable network conditions

## Scenario A: Field + Spray Plan Save Trust

1. Select field A.
2. Create spray plan with clear treatment inputs.
3. Save plan and confirm explicit success state.
4. Re-open saved plans and verify plan appears with correct details.
5. Restart app and verify retrieval remains consistent.

Expected:
- No false success state
- Saved plan remains retrievable and accurate

## Scenario B: Save Failure Handling

1. Begin plan save under unstable/no network.
2. Observe save result messaging.
3. Retry save after restoring network.

Expected:
- Clear failure guidance on failed attempt
- Success only shown after persistence succeeds

## Scenario C: Risk Alert Reliability

1. Save plan that triggers neighbor-risk condition.
2. Open recipient inbox and locate alert.
3. Open alert details and mark as reviewed.

Expected:
- Alert appears with accurate context
- Review-state transition is clear and persistent

## Scenario D: Plan-To-Contact Handoff

1. Open a saved plan.
2. Launch crop duster contact flow.
3. Validate prefilled context fields.

Expected:
- Field, treatment, and risk context match saved plan state

## Completion Check

- All scenarios pass without contradictory UI state
- Edge cases from spec are verified at least once