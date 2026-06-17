# Quickstart: Farmer Web Dashboard MVP Validation

## Goal

Validate that farmer web dashboard MVP workflows are reliable, coherent with mobile terminology, and restricted to authorized farmer data.

## Preconditions

- Test farmer account with valid credentials.
- At least one test dataset each for:
  - fields
  - saved application plans
  - alerts
  - service requests
- One empty-state farmer account with no records.
- Environment with controllable session expiration and network interruption.

## Scenario A: Authentication And Protected Access

1. Open farmer web dashboard route while signed out.
2. Confirm redirect to sign-in.
3. Sign in with valid farmer credentials.
4. Confirm dashboard loads protected farmer data.

Expected:
- No protected data visible before authentication.
- Valid sign-in grants access to farmer-owned dashboard views.

## Scenario B: Field Overview And Plan Visibility

1. Open dashboard with mapped fields.
2. Select a field from map/list.
3. Open saved application plans section.
4. Confirm newest plans appear first.
5. Filter plans and open one plan detail.

Expected:
- Selected-field panel updates coherently.
- Plan list filter behavior is consistent.
- Plan detail matches persisted record and remains read-only.

## Scenario C: Alert Review Coherence

1. Open alerts inbox with unread items.
2. Open an alert and mark it reviewed.
3. Refresh dashboard.
4. Reopen inbox and verify reviewed state persists.

Expected:
- Unread/reviewed states are explicit.
- Review-state transition persists across reload.

## Scenario D: Service Request Status Tracking

1. Open request-status area.
2. Filter requests by status and by date range.
3. Open one request detail row.
4. Validate status and shared context fields.

Expected:
- Only farmer-owned requests are visible.
- Status, counts, and detail views remain consistent with persisted records.

## Scenario E: Empty And Failure States

1. Sign in with empty-state farmer account.
2. Verify fields/plans/alerts/requests sections show clear empty-state guidance.
3. Simulate degraded network for one workflow section.

Expected:
- Empty-state messaging is explicit and non-misleading.
- Failure states do not present stale success indicators.

## Completion Check

- All scenarios pass with consistent terminology and status language.
- No unauthorized data appears under URL or filter manipulation attempts.
- Field/plan/alert/request views remain coherent after refresh.
