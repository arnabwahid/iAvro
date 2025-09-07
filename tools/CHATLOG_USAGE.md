# Chat Log — Session‑Based Workflow (Default)

This repo uses a session‑based workflow to capture conversations and keep a clean, merge‑friendly history. Verbatim text is filed as timestamped session files, and the consolidated chatlog is generated from these sessions on demand.

Note: The consolidated chatlog (`docs/chatlog.md`) is regenerated from session files; do not edit it by hand. In this repo, `docs/chatlog.md` is no longer tracked by Git; rebuild it locally from sessions when needed. The VS Code config under `.vscode/` is versioned so these tasks/keybindings travel with the repo.

## Quick Start (Default)
1) Save verbatim text to `docs/continue_chat.txt`.
2) Run task “New Session CC” (composite) — it creates a new session file and rebuilds `docs/chatlog.md`.
3) Optional: run “Show Session Context” to print a short summary (last session tail and the “Next (on resume)” section from export.md).
4) Review `docs/chatlog.md` locally (it is not tracked by Git).

Benefits: avoids merge conflicts; per‑session diffs are small and easy to review; consolidated log is reproducible.

## Notes

- Regeneration: Running “Build Chatlog (sessions → chatlog.md)” overwrites `docs/chatlog.md` from session files. Keep edits in sessions.

## When Does It Run?

- It runs only when you invoke it (via a VS Code task, keybinding, or manual shell command). There is no background or scheduled run.
- You can create your own automation (e.g., a local cron or Shortcut) to call the script periodically if desired.

## Git Hook (Pre‑Push) — Session Flow by Default
Install once per clone:

```
bash tools/install-hooks.sh
```

Behavior:
- If `docs/continue_chat.txt` has content, the hook converts it into a timestamped session file, rebuilds `docs/chatlog.md` from sessions, and stages both `docs/chatlog.md` and `docs/sessions/`.
- A blank marker file `docs/continue_chat` is created for easy discovery.
- If `AUTO_APPEND_CLIPBOARD=1` is set in `.chatlogrc`, the clipboard is written to `docs/continue_chat.txt`, then the same session → build flow runs (with CID and preview containment guards).

Notes:
- Hooks are local; they don’t travel with pushes. The installer sets `core.hooksPath=.githooks` in your local repo config.
- The hook is non-interactive and safe to ignore if you don’t use the pending/clipboard features.
- Recommended defaults: Use queued file appends or the VS Code tasks; keep clipboard auto‑append disabled unless you need it.

## Files & Conventions
- Consolidated log: `docs/chatlog.md` (rebuilt; do not edit by hand)
- Session files: `docs/sessions/YYYYMMDD‑HHMMSS-session.md` (immutable once created)
- Pending buffer: `docs/continue_chat.txt` (consumed); blank marker: `docs/continue_chat`.
- Working context (decisions, highlights): `docs/export.md` (rolling, curated; not a transcript)

## VS Code Config

- Tasks: `.vscode/tasks.json` (notable: “New Session CC” composite, “Show Session Context”, “Open Latest Session”, “Open Export (Next on resume)”, “New Session (from continue chat)”, “Build Chatlog”) 

## Quick Reference
- Add text: write to `docs/continue_chat.txt`
- Create + rebuild: run “New Session CC” (or `make session-cc`)
- Show summary: run “Show Session Context” (or `make context`)
- Open latest session: run “Open Latest Session”
- Edit plan: run “Open Export (Next on resume)” and update the section
- Keybindings: `.vscode/keybindings.json`

These live in the repo for consistency across machines. Adjust locally if they conflict with your setup.

## Tasks & Keybindings

Available VS Code tasks (labels as seen in the Command Palette):

- New Session CC: composite; runs “New Session (from continue chat)” then “Build Chatlog …”. Keybinding: cmd+alt+shift+n.
- New Session (from continue chat): consumes `docs/continue_chat.txt`, creates `docs/sessions/<timestamp>-session.md` and marker `docs/continue_chat`.
- Build Chatlog (sessions → chatlog.md): rebuilds `docs/chatlog.md` from sessions (overwrites file).
- Show Session Context: prints latest session header/tail, chatlog tail, and “Next (on resume)” from `docs/export.md`.
- Open Latest Session: opens newest `docs/sessions/*-session.md` (falls back to printing the first 40 lines).
- Open Export (Next on resume): opens `docs/export.md` at the “Next (on resume)” section when possible.
- Install Git Hooks (pre-push chatlog): installs `.githooks` as the repo’s hook path.
- Check Last Build: fetches and summarizes latest CI run (requires `gh` configured).
- Fetch Latest CI Logs (dev): downloads CI artifacts into `./ci_logs/`.
- Open Latest CI Summary: opens the most recent `ci_logs/**/ci_summary.txt` if present.

Keybindings are defined in `.vscode/keybindings.json`. By default only “New Session CC” is bound to cmd+alt+shift+n.

## Makefile

Common targets for CLI usage:

- make session: run the session conversion (`tools/new-session-from-continue-chat.sh`).
- make chatlog: rebuild `docs/chatlog.md` from sessions.
- make session-cc: run both of the above (same effect as the composite task).
- make context: print the session/chatlog/export summary (no writes).
- make check-build: fetch and summarize the latest CI run for `dev`.
- make hooks: install the pre-push hook.

Examples:

```
# Add text then create session + rebuild
echo "…" > docs/continue_chat.txt
make session-cc

# Just inspect where to resume
make context
```

## Subjects, Labels, and Tags (Best Practices)
- Subject: add a one‑line summary under the header (≤ 80 chars). Examples:
  - `Subject: CI: fix CocoaPods install and raise macOS target`
  - `Subject: Phase A kickoff: Normalizer scaffold`
- Label: indicate the source or channel. Examples: `Codex CLI`, `ChatGPT Web`, `Manual`, `PR Review`.
- Tags (inline in the first lines of content) help later search:
  - `[TOPIC:CI]`, `[TOPIC:Phase A]`, `[TOPIC:IME]`
  - `[PHASE:A]`, `[PHASE:Docs]`, `[PHASE:Infra]`
  - `[DECISION]` for choices made; `[TODO]` for follow‑ups

We will update this documentation after each phase and whenever new automation or tools land, to keep conventions accurate and discoverable.
