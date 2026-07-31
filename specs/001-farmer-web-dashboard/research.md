# Research: Farmer Web Dashboard MVP

## Objective

Resolve planning uncertainties for farmer web dashboard MVP implementation while preserving mobile-consistent behavior and farmer-only data boundaries.

## Research Tasks

1. Research desktop information architecture patterns suitable for farmer operations workflows.
2. Research best practices for Flutter web dashboard state consistency with shared mobile domains.
3. Research request-status visibility approach when service-request domain is in staged rollout.
4. Research URL/filter access safety patterns for farmer-owned data under role-based authorization.

## Findings

### Decision 1: Use dashboard-first desktop IA with map + panel + list composition
- Decision: Use a desktop dashboard pattern with persistent navigation, high-signal summaries, selected-field panel, and table/list-centric detail areas.
- Rationale: Matches roadmap guidance for office workflows and avoids stretching mobile interaction patterns onto desktop.
- Alternatives considered:
  - Mobile-layout parity on large screens: rejected due to poor desktop scan efficiency.
  - Separate one-page modules per workflow: rejected because it increases navigation friction for daily operations.

### Decision 2: Reuse mobile terminology and domain states as canonical language
- Decision: Keep statuses and naming aligned with existing mobile vocabulary (including "Application Plan") and avoid web-specific synonyms.
- Rationale: Reduces cognitive overhead for farmers switching between phone and desktop surfaces.
- Alternatives considered:
  - New web-specific labels: rejected due to likely support burden and user confusion.
  - Partial renaming only in specific modules: rejected because state coherence would drift.

### Decision 3: Make web plan views read-focused for MVP and defer full plan editing
- Decision: Provide filtering and read-only detail for saved plans in this MVP, with edits remaining mobile-first.
- Rationale: Satisfies immediate desktop visibility value while minimizing inconsistent multi-surface edit conflicts early.
- Alternatives considered:
  - Full plan CRUD on web in MVP: rejected due to expanded validation and conflict-resolution scope.
  - No plan detail view: rejected because it fails primary desktop review use case.

### Decision 4: Show service-request status using request-scoped snapshots only
- Decision: Display farmer-facing request status and shared context fields from request records; do not expose broad farmer data to service role or vice versa.
- Rationale: Aligns with service-request domain principles and preserves explicit cross-role boundaries.
- Alternatives considered:
  - Derive status directly from future job objects: rejected for MVP because request lifecycle must stand alone.
  - Expose spray-plan internals directly across roles: rejected due to privacy and boundary violations.

### Decision 5: Use server-authoritative authorization with client-side guardrails
- Decision: Rely on backend authorization as source of truth while adding client guards for expired sessions, invalid URLs, and unauthorized filter combinations.
- Rationale: Prevents data leakage from manipulated URLs and keeps behavior predictable for users.
- Alternatives considered:
  - Client-only filtering restrictions: rejected because they are not security controls.
  - Strictly opaque routing with no deep links: rejected because it harms desktop usability and recoverability.

## Resulting Guidance For Design

- Prioritize dense but readable desktop review workflows over mobile-style step flows.
- Keep entity/state names synchronized with mobile and existing domain docs.
- Treat request status as a first-class farmer view using explicit request records.
- Preserve role-scoped visibility in every workflow contract and state model.

## Clarification Status

All technical-context unknowns and sequencing dependencies are resolved for planning.
