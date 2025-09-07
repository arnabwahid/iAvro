# Phase B — Context-Aware Ranking (Tracking)

Scope (initial slice)
- Context ranking: add a lightweight scorer that re-ranks Bengali candidates using recent selections/context.
- Decoder tuning: conservative rule extensions (near-keys/insert/delete caps), keep candidate cap small and deterministic.
- Regression harness: broaden TSV and/or add a Bengali top‑1 mapping set.
- Performance: DEBUG timings and coarse benchmarks; establish per‑keystroke budget.

Acceptance
- Flag OFF unchanged vs baseline.
- Flag ON improves top‑1 for selected contexts; all tests green; no noticeable latency.

Tasks
- [x] Scaffold `ContextRanking.h/m` (no‑op pass‑through initially) + unit tests
- [x] Add simple history store (recent selections)
- [x] Rank blend: prefer previously chosen forms (minimal bigram boost); tie policies stay deterministic
- [x] Integration tests: context cases where top‑1 changes as intended (`Tests/ContextRegressionTests.m`, TSV rows)
- [ ] Expand TSV (~25–40 rows) and add a small Bengali top‑1 mapping set (top‑1 set exists; expansion deferred to QA)
- [ ] Perf: add DEBUG timings and a coarse benchmark target/guard (DEBUG logs present; benchmark guard deferred)

Notes
- Keep decoder caps small; avoid regressions; grow tests alongside rule changes
- Consider adding PR comment with top failing tests/statistics (optional)
