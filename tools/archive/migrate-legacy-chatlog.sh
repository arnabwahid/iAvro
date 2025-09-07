#!/usr/bin/env bash
set -euo pipefail

# Migrates the most recent legacy monolithic chatlog into a session file.
# Searches in order:
#   1) docs/iavro_codex_chatlog.md
#   2) docs/iavro_forgiving_typing_chatlog.md
#   3) docs/chatlog.md  (from before the session-based switch)
# Then rebuilds docs/chatlog.md from sessions.

SESS_DIR="docs/sessions"
mkdir -p "$SESS_DIR"

pick_last_commit_with() {
  local path="$1"
  git log --format=%H -n 1 -- "$path" 2>/dev/null || true
}

extract_at_commit() {
  local sha="$1"; shift
  local path="$1"; shift
  local out="$1"; shift
  if [[ -z "$sha" ]]; then return 1; fi
  echo "Exporting $path@${sha:0:7} → $out"
  if git show "$sha:$path" > "$out" 2>/dev/null; then
    return 0
  fi
  # If the file was removed/renamed in that commit, try its parent
  if git show "$sha^:$path" > "$out" 2>/dev/null; then
    echo "(exported from parent of ${sha:0:7})"
    return 0
  fi
  echo "Failed to extract $path at or before ${sha:0:7}" >&2
  return 1
}

LEGACY_SHA=""
LEGACY_PATH=""

for candidate in \
  docs/iavro_codex_chatlog.md \
  docs/iavro_forgiving_typing_chatlog.md \
  docs/chatlog.md \
; do
  sha=$(pick_last_commit_with "$candidate")
  if [[ -n "$sha" ]]; then
    LEGACY_SHA="$sha"
    LEGACY_PATH="$candidate"
    break
  fi
done

if [[ -z "$LEGACY_SHA" ]]; then
  echo "No legacy chatlog path found in Git history." >&2
  exit 1
fi

OUT="${SESS_DIR}/legacy-${LEGACY_SHA:0:7}-chatlog.md"
extract_at_commit "$LEGACY_SHA" "$LEGACY_PATH" "$OUT"

echo "Legacy chatlog saved as: $OUT"

# Rebuild consolidated chatlog
bash tools/build-chatlog.sh
echo "Rebuilt docs/chatlog.md from sessions."
