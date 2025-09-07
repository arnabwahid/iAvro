#!/usr/bin/env bash
set -euo pipefail

# Simple local build+test helper using xcodebuild.
# Usage: SCHEME="Avro Keyboard" CONFIG=Debug bash tools/xcode-build.sh

SCHEME=${SCHEME:-"Avro Keyboard"}
CONFIG=${CONFIG:-Debug}
DEST=${DESTINATION:-"platform=macOS"}
CODE_SIGNING_ALLOWED=${CODE_SIGNING_ALLOWED:-NO}

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

if [[ -d "AvroKeyboard.xcworkspace" ]]; then
  TARGET_FLAG=(-workspace "AvroKeyboard.xcworkspace")
elif [[ -f "AvroKeyboard.xcodeproj/project.pbxproj" ]]; then
  TARGET_FLAG=(-project "AvroKeyboard.xcodeproj")
else
  echo "No Xcode workspace or project found." >&2
  exit 1
fi

set -x
xcodebuild "${TARGET_FLAG[@]}" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination "$DEST" \
  CODE_SIGNING_ALLOWED=$CODE_SIGNING_ALLOWED \
  clean build test
set +x

echo "xcodebuild completed for scheme=$SCHEME config=$CONFIG" >&2

