# Chat Log — Session‑Based Workflow (Default)

This repo uses a session‑based workflow to capture conversations and keep a clean, merge‑friendly history. Verbatim text is filed as timestamped session files, and the consolidated chatlog is generated from these sessions on demand. An alternate “immediate append” path is still available.

Note: `docs/` and `tools/append-chatlog.sh` are ignored by Git in this workspace; they remain local and are not pushed to GitHub. The VS Code config under `.vscode/` is versioned so these tasks/keybindings travel with the repo.

## Quick Start (Default)
1) Save verbatim text to `docs/pending_chat_append.txt`.
2) Run task “New Session (from pending)” → moves content to `docs/sessions/YYYYMMDD-HHMMSS-session.md` and creates a blank `docs/pending_chat_append` marker for next time. Any overlapping prefix that already exists at the end of `docs/chatlog.md` is automatically trimmed to avoid duplicates.
3) Run task “Build Chatlog (sessions → chatlog.md)” → rebuilds `docs/chatlog.md` by concatenating all session files in chronological order.
4) Review `docs/chatlog.md` and commit.

Benefits: avoids merge conflicts; per‑session diffs are small and easy to review; consolidated log is reproducible.

## Alternate Flow — Immediate Append
Use when you want to append a single block directly to `docs/chatlog.md` without creating a session file.

- Task: “Append Chatlog (From File — Prompt Path & Label)”
  - Path: `docs/pending_chat_append.txt` (or any file)
  - Label: e.g., “ChatGPT Web” or “Codex CLI”
  - Subject: short summary of the append
  - The script appends a block with timestamp, `[CID:<sha256>]` for dedupe, `[LABEL:…]`, and `Subject:`. It opens the file on completion.

Dedupe: The appender computes a content hash (CID) and skips exact duplicates. Labels/subjects/timestamps do not affect dedupe.

Script: `tools/append-chatlog.sh`

Each append block adds (example):

```
---

Appended on 2025-09-06 16:55:00 UTC
[CID:<sha256>] [LABEL:<optional>]
Subject: <optional subject>

<pasted content>
```

- `CID` is the SHA‑256 of the normalized content (CRs stripped). It is used to prevent exact duplicate appends.
- `LABEL` is optional; use it to record the source (e.g., “Codex CLI”, “ChatGPT Web”, “Manual”).

## How Duplicate Prevention Works

- Before appending, the script computes the hash (CID) of the incoming content and checks if a line `"[CID:<hash>]"` already exists anywhere in the chatlog.
- If found, the append is skipped. Timestamps do not affect this check; duplicates are detected even if run at a different time.
- If the content changes (even a small typo), the CID changes, and it will be appended as a new block.
- Use `--force` to append regardless of duplicates.

## When Does It Run?

- It runs only when you invoke it (via a VS Code task, keybinding, or manual shell command). There is no background or scheduled run.
- You can create your own automation (e.g., a local cron or Shortcut) to call the script periodically if desired.

## Git Hook (Pre‑Push) — Session Flow by Default
Install once per clone:

```
bash tools/install-hooks.sh
```

Behavior:
- If `docs/pending_chat_append.txt` has content, the hook converts it into a timestamped session file, rebuilds `docs/chatlog.md` from sessions, and stages both `docs/chatlog.md` and `docs/sessions/`.
- A blank `docs/pending_chat_append` marker is created for easy discovery.
- If `AUTO_APPEND_CLIPBOARD=1` is set in `.chatlogrc`, the clipboard is written to `pending_chat_append.txt`, then the same session → build flow runs (with CID and preview containment guards).

Notes:
- Hooks are local; they don’t travel with pushes. The installer sets `core.hooksPath=.githooks` in your local repo config.
- The hook is non-interactive and safe to ignore if you don’t use the pending/clipboard features.
- Recommended defaults: Use queued file appends or the VS Code tasks; keep clipboard auto‑append disabled unless you need it.

## Files & Conventions
- Consolidated log: `docs/chatlog.md` (rebuilt; do not edit by hand)
- Session files: `docs/sessions/YYYYMMDD‑HHMMSS-session.md` (immutable once created)
- Pending buffer: `docs/pending_chat_append.txt` (consumed) and `docs/pending_chat_append` (blank marker)
- Working context (decisions, highlights): `docs/export.md` (rolling, curated; not a transcript)

## VS Code Config

- Tasks: `.vscode/tasks.json`
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
