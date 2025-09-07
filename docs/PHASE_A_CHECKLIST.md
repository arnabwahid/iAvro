# Phase A — Forgiving Typing (Tracking)

Scope (agreed)
- RomanNormalizer, TolerantDecoder (beam), Ranking scorer
- Prefs/flags: Forgiving+Learn ON for dev, auto‑commit ≈ 0.75, case aliases ON
- Tests: regression TSV + minimal XCTest smoke; CI runs build/tests

Status
- Core modules and flags are implemented and covered by tests; CI is green.
- The items below track remaining nice‑to‑haves and hardening tasks.

Backlog — Nice‑to‑Haves / Hardening
- [ ] Integration top‑1: for a few stable words, assert expected is top‑1 (not just present).
- [ ] ON/OFF parity (Suggestion): paired tests where decoder would alter roman; flag OFF must keep Bengali output identical to baseline.
- [ ] TSV growth: expand to ~25–40 rows (multi‑error within limits, near‑keys, no‑ops).
- [ ] Determinism: explicit ordering stability tests when caps/inputs equal.
- [ ] Ranking with priors: when a reliable prior source is confirmed, blend with edit distance + tests.
- [ ] Perf threshold (optional): convert DEBUG timing into an upper bound once variance is understood.

References
- Tests: `Tests/ModeSmokeTests.m`, `Tests/TolerantDecoderTests.m`, `Tests/RegressionTests.m`, `Tests/Top1RegressionTests.m`
- Export context: `docs/export.md` (Phase A scope and backlog)

