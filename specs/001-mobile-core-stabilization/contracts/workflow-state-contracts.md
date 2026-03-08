# Workflow State Contracts

## Purpose

Define app-layer behavior contracts required to keep mobile core workflows coherent and reliable.

## Contract 1: Save Result Contract

Producer: Spray plan save workflow
Consumer: Spray plan UI surfaces

Rules:
- Emit one terminal state per save attempt: saved or failed.
- Do not emit saved unless persistence succeeded.
- Expose retry-ready state after failures.

## Contract 2: Saved Plan Retrieval Contract

Producer: Plan persistence/retrieval layer
Consumer: Saved plans UI and contact handoff flow

Rules:
- Returned plan reflects persisted values for field, treatment, and risk summary.
- Retrieval order and status must be deterministic for user review.

## Contract 3: Alert Inbox Contract

Producer: Alert generation/delivery path
Consumer: Notifications inbox UI

Rules:
- Alert entries include sufficient field and risk context for review.
- Read/review transitions are explicit and durable.

## Contract 4: Contact Context Contract

Producer: Saved plan detail surface
Consumer: Crop duster contact flow

Rules:
- Contact context derives from current saved plan snapshot.
- Missing or inactive service channels are surfaced as explicit unavailability states.