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
- [ ] Scaffold `ContextRanking.h/m` (no‑op pass‑through initially) + unit tests
- [ ] Add simple history store (recent selections)
- [ ] Rank blend: prefer previously chosen forms; tie policies stay deterministic
- [ ] Integration tests: 2–3 context cases where top‑1 changes as intended
- [ ] Expand TSV (~25–40 rows) and add a small Bengali top‑1 mapping set
- [ ] Perf: add DEBUG timings and a coarse benchmark target/guard

Notes
- Keep decoder caps small; avoid regressions; grow tests alongside rule changes
- Consider adding PR comment with top failing tests/statistics (optional)

