#!/usr/bin/env bash
set -euo pipefail

# Reset the learned context (Phase B) by clearing persisted bigrams
# stored under the NSUserDefaults key: ContextRankingBigrams
#
# Domain (bundle id): com.omicronlab.inputmethod.AvroKeyboard

DOMAIN=${DOMAIN:-com.omicronlab.inputmethod.AvroKeyboard}
KEY=${KEY:-ContextRankingBigrams}

if [[ "${OSTYPE:-}" != darwin* ]]; then
  echo "This reset script is intended for macOS (uses 'defaults')." >&2
  exit 1
fi

echo "Clearing $KEY from $DOMAIN ..."
if defaults read "$DOMAIN" "$KEY" >/dev/null 2>&1; then
  defaults delete "$DOMAIN" "$KEY" >/dev/null 2>&1 || true
  echo "Done. $KEY removed from $DOMAIN."
else
  echo "Key $KEY not present in $DOMAIN (nothing to do)."
fi

echo "Tip: You can disable context ranking temporarily with:\n  defaults write $DOMAIN ContextRankingEnabled -bool NO"

