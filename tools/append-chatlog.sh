#!/usr/bin/env bash
set -euo pipefail

# Append text to docs/iavro_codex_chatlog.md with a timestamped divider.
# Sources: stdin (default), --from-file <path>, or --from-clipboard (macOS pbpaste / xclip/xsel).
# Optional: --commit to auto git-commit the change.

FILE="docs/iavro_codex_chatlog.md"
SOURCE="stdin"
INPUT_PATH=""
DO_COMMIT=0
TITLE="iAvro Forgiving Typing Project — Chat Log"
FORCE_APPEND=0
LABEL=""

usage() {
  cat <<EOF
Usage: $0 [--from-file <path> | --from-clipboard] [--label <text>] [--commit] [--force]

Examples:
  # Append from clipboard (copy chat text first)
  $0 --from-clipboard --label "Codex CLI" --commit

  # Append from a file
  $0 --from-file tmp/chat_append.txt --label "CGE export"

  # Append from stdin
  echo "My note" | $0 --label "Manual note"
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-file)
      SOURCE="file"; INPUT_PATH="${2:-}"; shift 2;;
    --from-clipboard|-c)
      SOURCE="clipboard"; shift;;
    --commit)
      DO_COMMIT=1; shift;;
    --force)
      FORCE_APPEND=1; shift;;
    --label)
      LABEL="${2:-}"; shift 2;;
    --help|-h)
      usage; exit 0;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 2;;
  esac
done

# Resolve input
CONTENT=""
if [[ "$SOURCE" == "file" ]]; then
  if [[ -z "$INPUT_PATH" || ! -f "$INPUT_PATH" ]]; then
    echo "Error: --from-file requires a valid file path" >&2
    exit 2
  fi
  CONTENT=$(cat "$INPUT_PATH")
elif [[ "$SOURCE" == "clipboard" ]]; then
  if command -v pbpaste >/dev/null 2>&1; then
    CONTENT=$(pbpaste)
  elif command -v xclip >/dev/null 2>&1; then
    CONTENT=$(xclip -o -selection clipboard)
  elif command -v xsel >/dev/null 2>&1; then
    CONTENT=$(xsel --clipboard --output)
  else
    echo "Error: no clipboard tool found (pbpaste/xclip/xsel)" >&2
    exit 2
  fi
else
  # stdin
  if [ -t 0 ]; then
    echo "Reading from stdin... (press Ctrl-D to finish)" >&2
  fi
  CONTENT=$(cat || true)
fi

if [[ -z "$CONTENT" ]]; then
  echo "Nothing to append (empty content)." >&2
  exit 0
fi

mkdir -p "docs"
if [[ ! -f "$FILE" ]]; then
  cat > "$FILE" <<EOF
# $TITLE

This file contains the entire discussion history between the user and the assistant,
covering project planning, design, regression test phrases, and clarifications.

---

## Conversation

EOF
fi

STAMP="$(date +"%Y-%m-%d %H:%M:%S %Z")"

# Normalize line endings and compute content hash for idempotency
CONTENT_NORM=$(printf '%s' "$CONTENT" | tr -d '\r')
# Normalize label
LABEL_NORM=$(printf '%s' "$LABEL" | tr -d '\r')
if command -v shasum >/dev/null 2>&1; then
  CID=$(printf '%s' "$CONTENT_NORM" | shasum -a 256 | awk '{print $1}')
elif command -v openssl >/dev/null 2>&1; then
  CID=$(printf '%s' "$CONTENT_NORM" | openssl dgst -sha256 -r | awk '{print $1}')
else
  CID=$(printf '%s' "$CONTENT_NORM" | wc -c | tr -d '[:space:]') # fallback: length
fi

# Skip if this exact content was already appended (idempotent)
if [[ $FORCE_APPEND -eq 0 ]] && grep -q "^\[CID:$CID\]$" "$FILE" 2>/dev/null; then
  echo "This content (CID:$CID) is already present in $FILE; skipping."
  exit 0
fi
{
  echo "\n---\n\nAppended on $STAMP\n[CID:$CID]${LABEL_NORM:+ [LABEL:$LABEL_NORM]}\n\n$CONTENT_NORM\n"
} >> "$FILE"

echo "Appended chat content to $FILE"

if [[ $DO_COMMIT -eq 1 ]]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git add "$FILE"
    git commit -m "docs(chatlog): append conversation at $STAMP"
    echo "Committed chatlog append."
  else
    echo "Not a git repo; skipping commit." >&2
  fi
fi
