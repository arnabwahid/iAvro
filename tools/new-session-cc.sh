#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

SESS_DIR="docs/sessions"
PENDING="docs/continue_chat.txt"
CHATLOG="docs/chatlog.md"
CREATED_SESSION=""

run_new_session() {
  # Capture output to detect the created session file path
  OUT=$(bash tools/new-session-from-continue-chat.sh || true)
  echo "$OUT"
  if echo "$OUT" | grep -q "New session saved:"; then
    CREATED_SESSION=$(echo "$OUT" | sed -n 's/^New session saved: \(.*\)$/\1/p' | tail -n1)
  else
    # Fallback: latest session file if exists
    CREATED_SESSION=$(ls -1t "$SESS_DIR"/*-session.md 2>/dev/null | head -n1 || true)
  fi
}

build_chatlog() {
  bash tools/build-chatlog.sh
}

print_context() {
  echo
  echo "=== New Session CC: Context Summary ==="
  if [[ -n "$CREATED_SESSION" && -f "$CREATED_SESSION" ]]; then
    echo "Created session: $CREATED_SESSION"
    echo
    echo "-- Session header --"
    sed -n '1,10p' "$CREATED_SESSION" || true
    echo
    echo "-- Session tail (last 12 lines) --"
    tail -n 12 "$CREATED_SESSION" || true
  else
    echo "No new session file detected. If you intended to create one, add content to $PENDING first."
  fi

  if [[ -f "$CHATLOG" ]]; then
    echo
    echo "-- Chatlog tail (last 12 lines) --"
    tail -n 12 "$CHATLOG" || true
  fi

  if [[ -f docs/export.md ]]; then
    echo
    echo "-- Next (on resume) from export.md --"
    awk '
      BEGIN{found=0}
      /^##[[:space:]]+Next \(on resume\)/{found=1; next}
      /^##[[:space:]]+/{if(found){exit} }
      {if(found){print}}
    ' docs/export.md | sed '/^[[:space:]]*$/d' | sed -n '1,20p'
  fi
  echo "=== End Summary ==="
}

run_new_session
build_chatlog
print_context

exit 0

