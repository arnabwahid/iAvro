#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

SESS_DIR="docs/sessions"
PENDING="docs/continue_chat.txt"
CHATLOG="docs/chatlog.md"
CREATED_SESSION=""

# Controls (env)
RUN_FLOW=${RUN_FLOW:-0}      # 1: run session + build; 0: skip
SUMMARY=${SUMMARY:-1}        # 1: print summary; 0: quiet

run_new_session() {
  OUT=$(bash tools/new-session-from-continue-chat.sh || true)
  echo "$OUT"
  if echo "$OUT" | grep -q "New session saved:"; then
    CREATED_SESSION=$(echo "$OUT" | sed -n 's/^New session saved: \(.*\)$/\1/p' | tail -n1)
  else
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
    echo "Latest session: $CREATED_SESSION"
    echo
    echo "-- Session header --"
    sed -n '1,10p' "$CREATED_SESSION" || true
    echo
    echo "-- Session tail (last 12 lines) --"
    tail -n 12 "$CREATED_SESSION" || true
  else
    echo "No session files found under $SESS_DIR."
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

if [[ "$RUN_FLOW" -eq 1 ]]; then
  run_new_session
  build_chatlog
else
  # Ensure we still identify the latest session for the context print
  CREATED_SESSION=$(ls -1t "$SESS_DIR"/*-session.md 2>/dev/null | head -n1 || true)
fi

if [[ "$SUMMARY" -eq 1 ]]; then
  print_context
fi

exit 0
