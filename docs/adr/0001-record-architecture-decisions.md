# 1. Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-11-24

## Context

Over the next months many decisions get made: which services, which trade-offs, what to leave out. Months later it's hard to remember why something is the way it is, and "why did you choose X?" is a common interview question.

## Decision

Record each significant decision as a short Markdown file in `docs/adr/`, numbered in order, using this layout:

- **Status:** Proposed, Accepted, or Superseded by ADR N
- **Context:** the situation and the forces at play
- **Decision:** what was chosen
- **Consequences:** what gets easier, what gets harder, and what it costs

ADRs aren't edited after they're accepted. If a decision changes, write a new ADR that supersedes the old one.

## Consequences

- Reasoning is kept next to the code and reviewed in pull requests like code.
- Writing one takes 10 to 15 minutes per decision.
