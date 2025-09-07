#!/usr/bin/env bash
set -euo pipefail

PENDING="docs/pending_chat_append.txt"
SESS_DIR="docs/sessions"
TS=$(date +"%Y%m%d-%H%M%S")
OUT="$SESS_DIR/$TS-session.md"
CHATLOG="docs/chatlog.md"
MAX_OVERLAP_LINES=${MAX_OVERLAP_LINES:-200}
MIN_OVERLAP_LINES=${MIN_OVERLAP_LINES:-10}

if [[ ! -s "$PENDING" ]]; then
  echo "No pending content at $PENDING (or file is empty)." >&2
  exit 0
fi

mkdir -p "$SESS_DIR"

# Normalize CRLF to LF into a temp file
TMP_PENDING=$(mktemp)
tr -d '\r' < "$PENDING" > "$TMP_PENDING"

# Overlap trim: if chatlog exists, remove any overlapping prefix lines
TRIMMED_PENDING=$(mktemp)
if [[ -f "$CHATLOG" ]]; then
  TMP_TAIL=$(mktemp)
  tr -d '\r' < "$CHATLOG" | tail -n "$MAX_OVERLAP_LINES" > "$TMP_TAIL" || true
  TRIM_LINES=0
  # Try longest to shortest for a stable match
  for ((k=MAX_OVERLAP_LINES; k>=MIN_OVERLAP_LINES; k--)); do
    # Extract last k lines of chatlog tail and first k lines of pending
    tail -n "$k" "$TMP_TAIL" > "$TMP_TAIL.k" 2>/dev/null || true
    head -n "$k" "$TMP_PENDING" > "$TMP_PENDING.k" 2>/dev/null || true
    if [[ -s "$TMP_TAIL.k" && -s "$TMP_PENDING.k" ]] && cmp -s "$TMP_TAIL.k" "$TMP_PENDING.k"; then
      TRIM_LINES=$k
      break
    fi
  done
  if [[ "$TRIM_LINES" -gt 0 ]]; then
    # Drop the overlapping prefix from pending
    tail -n +$((TRIM_LINES+1)) "$TMP_PENDING" > "$TRIMMED_PENDING"
  else
    cp "$TMP_PENDING" "$TRIMMED_PENDING"
  fi
  rm -f "$TMP_TAIL" "$TMP_TAIL.k" "$TMP_PENDING.k" 2>/dev/null || true
else
  cp "$TMP_PENDING" "$TRIMMED_PENDING"
fi

# Preserve as-is; prepend a small header with timestamp.
{
  echo "---"
  echo "Session: $TS"
  echo "---"
  echo
  cat "$TRIMMED_PENDING"
  echo
} > "$OUT"

rm -f "$PENDING"
# Cleanup temp
rm -f "$TMP_PENDING" "$TRIMMED_PENDING" 2>/dev/null || true
echo "New session saved: $OUT"

# Create a blank marker file without extension for easy discovery
touch "docs/pending_chat_append"
