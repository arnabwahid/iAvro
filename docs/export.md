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
- Canonical log: `docs/chatlog.md`
- Manual append (preferred): use VS Code tasks that call `tools/append-chatlog.sh` with `--label` and `--subject`; dedupe by content hash (CID); optional `--open`.
- Queued append: write verbatim transcript to `docs/pending_chat_append.txt`; on next `git push` the pre‑push hook appends & removes it.
- Clipboard auto‑append: OFF by default; if enabled via `.chatlogrc`, includes guards (CID check + tail containment preview) to avoid duplicates.

### Helper Scripts & Tasks
- `tools/check-last-build.sh` — one‑click: fetch latest run artifacts, decompress, open summary
- `tools/fetch-latest-ci-logs.sh` — downloads `ci-logs` artifacts into `./ci_logs/`
- VS Code tasks:
  - “Check Last Build” (key: cmd+alt+shift+b)
  - “Fetch Latest CI Logs (dev)” (key: cmd+alt+shift+f)
  - “Open Latest CI Summary” (key: cmd+alt+shift+o)
  - Multiple “Append Chatlog …” tasks for clipboard/file/stdin
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
- If we observe duplicate lines when importing large verbatim transcripts, consider tuning overlap trimming:
  - Session flow: adjust `MAX_OVERLAP_LINES`/`MIN_OVERLAP_LINES` in `tools/new-session-from-pending.sh` (defaults 200/10).
  - Immediate-append flow: optionally add `--trim-existing` to `tools/append-chatlog.sh` to remove overlap before appending (not implemented yet).
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
