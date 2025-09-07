#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

if [[ ! -x .githooks/pre-push ]]; then
  echo "Making pre-push hook executable"
  chmod +x .githooks/pre-push || true
fi

echo "Configuring git to use .githooks as hooksPath (repo-local)"
git config core.hooksPath .githooks

echo "Done. Pre-push hook installed. Optional config: create .chatlogrc with AUTO_APPEND_CLIPBOARD=1 to enable clipboard appends on push. To queue content before pushing, write it to docs/continue_chat.txt."
