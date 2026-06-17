# Web Dashboard Workflow Contracts

## Purpose

Define user-visible contracts for farmer web dashboard workflows so implementation remains consistent with spec requirements and mobile terminology.

## Contract 1: Authentication And Access

Actor:
- Farmer

Preconditions:
- Farmer opens web dashboard route.

Input/Trigger:
- Session evaluation on page load or protected-route navigation.

Contract:
- If farmer session is active, protected dashboard content is accessible.
- If session is missing/expired, user is redirected to sign-in before protected data is shown.
- Unauthorized route/filter attempts never expose non-owned records.

Output:
- One of: `authorized_dashboard_view`, `redirect_to_sign_in`, `access_denied_feedback`.

## Contract 2: Field Overview Workspace

Actor:
- Farmer

Preconditions:
- Authenticated farmer session.

Input/Trigger:
- Open dashboard and optionally select a field from map/list.

Contract:
- Dashboard presents farmer-owned field overview list/map context.
- Selecting a field updates selected-field panel details.
- If no fields exist, an empty-state guidance panel is shown.

Output:
- One of: `field_overview_with_selection`, `field_overview_without_selection`, `field_empty_state`.

## Contract 3: Saved Application Plans View

Actor:
- Farmer

Preconditions:
- Authenticated farmer session.

Input/Trigger:
- Open saved plans area; apply filter/search; open detail.

Contract:
- Saved plans are ordered newest-first by default.
- Filtering affects visible records while preserving farmer-only scope.
- Opening a plan shows read-only detail for that persisted record.

Output:
- One of: `plan_list`, `filtered_plan_list`, `plan_detail_view`, `plan_empty_state`.

## Contract 4: Alert Inbox Review

Actor:
- Farmer

Preconditions:
- Authenticated farmer session.

Input/Trigger:
- Open alert inbox; mark an alert as reviewed.

Contract:
- Alerts render with explicit unread/reviewed status.
- Mark-review action updates state and persists across refresh.
- Failure to update review state returns explicit feedback and leaves record consistent.

Output:
- One of: `alert_list_with_status`, `review_state_updated`, `review_state_update_failed`, `alert_empty_state`.

## Contract 5: Service Request Status Tracking

Actor:
- Farmer

Preconditions:
- Authenticated farmer session.

Input/Trigger:
- Open request-status area; apply status/date filters; open request details.

Contract:
- View shows farmer-owned request records only.
- Each row includes current status and shared request context.
- Filters return consistent result counts and detail records.
- Missing linked references are shown with fallback labels instead of broken screens.

Output:
- One of: `request_status_list`, `filtered_request_status_list`, `request_detail_view`, `request_empty_state`.

## Shared Contract Rules

- Terminology must remain coherent with mobile product language.
- Loading, empty, and error states are explicit in each workflow area.
- Authorization scope is enforced server-side and reflected client-side.
