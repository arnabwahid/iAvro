#!/usr/bin/env bash
set -euo pipefail

SESS_DIR="docs/sessions"
OUT="docs/chatlog.md"

mkdir -p "$SESS_DIR"

{
  echo "# Chat Log"
  echo
  if compgen -G "$SESS_DIR/*.md" > /dev/null; then
    for f in $(ls -1 "$SESS_DIR"/*.md | sort); do
      echo "\n---"
      echo "\n[SESSION_FILE: $(basename "$f")]\n"
      cat "$f"
      echo
    done
  else
    echo "No session files found under $SESS_DIR yet."
  fi
} > "$OUT"

echo "Built $OUT"
