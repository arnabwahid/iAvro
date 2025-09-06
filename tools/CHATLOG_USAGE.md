# Chat Log Append — Usage & Tips

This workspace includes a helper script and VS Code tasks to append new conversation text to `docs/iavro_codex_chatlog.md` while preserving continuity and avoiding exact duplicates.

Note: `docs/` and `tools/append-chatlog.sh` are ignored by Git in this workspace; they remain local and are not pushed to GitHub. The VS Code config under `.vscode/` is versioned so these tasks/keybindings travel with the repo.

## Quick Start

- Command Palette → “Tasks: Run Task” → pick one:
  - Append Chatlog (Clipboard — Codex CLI)
  - Append Chatlog (Clipboard — ChatGPT Web)
  - Append Chatlog (Clipboard — Prompt Label)
  - Append Chatlog (From File — Prompt Path & Label)
  - Append Chatlog (Clipboard)
  - Append Chatlog (Stdin)

- Keybindings (macOS defaults here; adjust as desired):
  - Codex CLI clipboard → `cmd+alt+shift+l`
  - ChatGPT Web clipboard → `cmd+alt+shift+w`

To append and immediately open the chatlog in VS Code:
- Task: “Append & Open Chatlog (Clipboard — Prompt Label)”

## Script Usage

Script: `tools/append-chatlog.sh`

- Clipboard: `bash tools/append-chatlog.sh --from-clipboard --label "Codex CLI"`
- From file: `bash tools/append-chatlog.sh --from-file /path/to.txt --label "CGE export"`
- From stdin: `echo "text" | bash tools/append-chatlog.sh --label "Manual"`
- Force append (skip duplicate check): add `--force`
- Optional commit: add `--commit` (docs/ is ignored; commit will effectively be a no‑op unless other files changed)

Each append block adds:

```
---

Appended on 2025-09-06 16:55:00 UTC
[CID:<sha256>] [LABEL:<optional>]

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

### Optional: Pre-Push Git Hook (local)

This repo includes a local pre‑push hook template at `.githooks/pre-push`. Install it once per clone:

```
bash tools/install-hooks.sh
```

Behavior:
- If `docs/pending_chat_append.txt` exists and has content, it is appended (label “Pre-push”) and then removed.
- If `AUTO_APPEND_CLIPBOARD=1` is set in `.chatlogrc` (repo root) or env, the clipboard is appended (label “Pre-push (Clipboard)”).
- After appending, the hook stages `docs/iavro_codex_chatlog.md` so it’s included in your push if committed.

Notes:
- Hooks are local; they don’t travel with pushes. The installer sets `core.hooksPath=.githooks` in your local repo config.
- The hook is non-interactive and safe to ignore if you don’t use the pending/clipboard features.

## Notes & Recommendations

- Keep the original exported chats unchanged when possible; append new sections using the script to maintain a clean history.
- If you manually edit old sections and later append the same content again, duplicate detection may still work (as long as the original `[CID:…]` marker remains). If you remove or edit that marker, the same content could append again.
- Labels do not participate in duplicate checking. They’re metadata for humans.
- The script normalizes line endings (CR → LF) before hashing to avoid platform differences causing false mismatches.

## VS Code Config

- Tasks: `.vscode/tasks.json`
- Keybindings: `.vscode/keybindings.json`

These live in the repo for consistency across machines. Adjust locally if they conflict with your setup.
