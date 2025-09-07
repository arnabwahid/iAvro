#!/usr/bin/env bash
# Rebuilds docs/chatlog.md from all docs/sessions/*.md in chronological order.
# Note: This overwrites docs/chatlog.md; do not edit that file by hand.
set -euo pipefail

SESS_DIR="docs/sessions"
OUT="docs/chatlog.md"

mkdir -p "$SESS_DIR"

{
  printf "# Chat Log\n\n"
  if compgen -G "$SESS_DIR/*.md" > /dev/null; then
    for f in $(ls -1 "$SESS_DIR"/*.md | sort); do
      printf "\n---\n\n[SESSION_FILE: %s]\n\n" "$(basename "$f")"
      cat "$f"
      printf "\n"
    done
  else
    printf "No session files found under %s yet.\n" "$SESS_DIR"
  fi
} > "$OUT"

echo "Built $OUT"
