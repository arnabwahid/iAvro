# iAvro — Working Context (Export)

This file is maintained by Codex for fast, uninterrupted continuation of work. It captures the important decisions, wiring, and current status so a new session can pick up immediately. It is not a verbatim transcript.

## Repository Snapshot
- Platform: macOS InputMethodKit IME (Objective‑C)
- Key targets: `Avro Keyboard` (app), `iAvroTests` (XCTest)
- Minimum macOS target: 10.13 (project, tests, and Pods)
- Core source files: `AvroParser.m`, `RegexParser.m`, `AutoCorrect.m`, `Candidates.m`, `Database.m`, `Suggestion.m`, etc.
- Assets/DB: `database.db3`, `regex.json`, `autodict.*`

## Phase A (Forgiving Typing) — Agreed Scope
- Modules (Obj‑C, in‑place): RomanNormalizer, TolerantDecoder (beam), Ranking scorer
- Prefs/flags: Forgiving+Learn ON by default for dev, auto‑commit ≈ 0.75, case aliases ON
- Tests: add regression TSV + minimal XCTest smoke tests; CI runs build/tests
- Branching: feature branch `feature/forgiving-typing` off `dev`, atomic commits

## CI Pipeline (GitHub Actions) — Summary
- Runner: `macos-13` (Xcode 15.2)
- CocoaPods: pinned `1.11.3`; Subversion installed for RegexKitLite (trunk uses SVN)
- Build/test: `xcodebuild` using autodetected workspace/project, shared scheme `Avro Keyboard`, `CODE_SIGNING_ALLOWED=NO`
- Scheme resolution: robust trim/auto‑select; works with shared scheme
- Logs & artifacts: full logs (build/test/pod_install) always uploaded and gzipped
- Failure summary: job Summary (curated tail) + local helper to fetch artifacts
- Problem matchers: clang/xcode + linker to annotate PRs (line/column when available)
- Caches: CocoaPods + DerivedData with `CACHE_VERSION` for rotation

## CI Stabilization — Key Fixes
1) Project file malformed (stray PBXGroup after root). Fixed by moving `Tests` PBXGroup inside objects map.
2) libarclite/linker error on Xcode 15: raised macOS deployment target to 10.13 (project + tests + Podfile).
3) Header includes failed on CI: switched to CocoaPods public headers
   - `#import <FMDB/FMDatabase.h>`
   - `#import <RegexKitLite/RegexKitLite.h>`
4) Pod install intermittently failing with CocoaPods “map for nil”: pinned CocoaPods; capture verbose `pod_install.log`; ensured SVN exists (for RegexKitLite trunk).

## Current CI Status
- After the above fixes, the build progressed into app compile/link; outstanding failures (if any) should be visible in `ci_logs/` via helper scripts.
- Use the “Check Last Build” workflow below to re‑fetch and inspect the latest run quickly.

## Chatlog & Session Capture — Local Workflow
- Canonical log: `docs/chatlog.md` (rebuilt from sessions)
- Session capture: write verbatim transcript to `docs/continue_chat.txt`; run “New Session CC” to convert it into a session and rebuild the chatlog (or push with the pre‑push hook installed).

### Helper Scripts & Tasks
- `tools/check-last-build.sh` — one‑click: fetch latest run artifacts, decompress, open summary
- `tools/fetch-latest-ci-logs.sh` — downloads `ci-logs` artifacts into `./ci_logs/`
- VS Code tasks:
  - “New Session CC” (key: cmd+alt+shift+n)
  - “New Session (from continue chat)” and “Build Chatlog (sessions → chatlog.md)”
  - “Check Last Build”, “Fetch Latest CI Logs (dev)”, “Open Latest CI Summary”
- Local directories ignored by Git: `ci_logs/` (downloaded artifacts)

## Branches & Policy
- Default working branch: `dev`
- Feature work: `feature/forgiving-typing` from `dev`, PR back to `dev`
- CI badge: README shows `dev` branch status

## Open Items / Next Fixes (before Phase A)
- Ensure latest `dev` run is green
  - If red, run “Check Last Build” and review `ci_logs/ci_summary.txt` + `build.log.gz`/`pod_install.log.gz`
  - Typical quick‑fixes now: lingering low deployment targets under `Pods/` (RegexKitLite shows 10.6 in warnings but should still compile); if needed, set `config.build_settings['MACOSX_DEPLOYMENT_TARGET']` via a post‑install hook.
- Confirm CI scheme detection uses `Avro Keyboard` (shared scheme committed)

## TODO / Reminders
- If we observe duplicate lines when importing large verbatim transcripts, tune overlap trimming in `tools/new-session-from-continue-chat.sh` via `MAX_OVERLAP_LINES`/`MIN_OVERLAP_LINES` (defaults 200/10).
- Revisit Subversion install in CI: once RegexKitLite is reliably sourced via a Git podspec or vendored, remove the Homebrew Subversion install step.

## Post‑Install Hook (optional quick tweak)
If pods still emit low target warnings, add to Podfile:

```
post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.13'
    end
  end
end
```

## “Check Last Build” — How to Use
1) Ensure `gh` CLI is installed and authenticated (`gh auth login`).
2) Run VS Code task “Check Last Build” or: `bash tools/check-last-build.sh dev`
3) Inspect `./ci_logs/ci_summary.txt`; for details, open `build.log.gz` and `pod_install.log.gz`.

## Ready Path to Phase A
- Once `dev` is green, create `feature/forgiving-typing` and begin with RomanNormalizer scaffolding and a small smoke test. Integrate behind prefs; keep changes atomic.

## Session Log — Saved Context
Appended: ${USER:-local} session summary

- CI: dev is GREEN (latest run downloaded under `ci_logs/`; pointers in `ci_logs/ci_summary.txt`).
- Chatlog: session-based workflow in place; legacy transcript migrated to `docs/sessions/legacy-*.md`; consolidated `docs/chatlog.md` rebuilt from sessions.
- Tooling:
  - `tools/check-last-build.sh` improved (single GH query, per-run folder, latest pointers).
- New session helpers: `tools/new-session-from-continue-chat.sh`, `tools/build-chatlog.sh`.
  - Pre-push hook: converts pending → session, rebuilds chatlog, stages changes; creates blank `docs/continue_chat` marker.
- CI config:
  - CocoaPods pinned; post_install enforces macOS 10.13 across pods.
  - Xcode project set to `ALWAYS_SEARCH_USER_PATHS=NO`; deployment targets at 10.13; imports use pod public headers.
- Docs updated: session-based default, best practices (Subjects/Labels/Tags), index.md pointer.

Next (on resume)
- Say: “Load context from docs/export.md and docs/chatlog.md. Check last build.”
- If you have new transcript text: put it in `docs/continue_chat.txt`, run “New Session (from continue chat)”, then “Build Chatlog (sessions → chatlog.md)”.
- Before first Phase A commit: decide on dev failure flagging (commit comments and/or rolling issue).
