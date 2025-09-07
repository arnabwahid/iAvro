# Chat Log — Session‑Based Workflow (Default)

This repo uses a session‑based workflow to capture conversations and keep a clean, merge‑friendly history. Verbatim text is filed as timestamped session files, and the consolidated chatlog is generated from these sessions on demand. An alternate “immediate append” path is still available.

Note: The consolidated chatlog (`docs/chatlog.md`) is regenerated from session files; do not edit it by hand. The VS Code config under `.vscode/` is versioned so these tasks/keybindings travel with the repo.

## Quick Start (Default)
1) Save verbatim text to `docs/continue_chat.txt`.
2) Run task “New Session CC” (umbrella) — it creates a new session file, rebuilds `docs/chatlog.md`, and prints a short context summary (last session tail and the “Next (on resume)” section from export.md).
3) Review `docs/chatlog.md` and commit.

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

- Tasks: `.vscode/tasks.json` (notable: “New Session CC”, “New Session (from continue chat)”, “Build Chatlog (sessions → chatlog.md)”) 
- Keybindings: `.vscode/keybindings.json`

These live in the repo for consistency across machines. Adjust locally if they conflict with your setup.

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
