#!/usr/bin/env bash
set -euo pipefail

# Fetch the latest ci-logs artifact for a branch (default: dev) using GitHub CLI
# Requirements: gh CLI authenticated (GH_TOKEN or gh auth login)
# Usage:
#   tools/fetch-latest-ci-logs.sh [branch] [output_dir]
#   tools/fetch-latest-ci-logs.sh --run <run-id> [output_dir]
#   tools/fetch-latest-ci-logs.sh --help

usage() {
  cat <<EOF
Fetch latest ci-logs artifact from GitHub Actions.

Usage:
  $(basename "$0") [branch] [output_dir]
  $(basename "$0") --run <run-id> [output_dir]

Examples:
  $(basename "$0")                 # fetch from branch 'dev' into ./ci_logs
  $(basename "$0") main ./out      # fetch from branch 'main' into ./out
  $(basename "$0") --run 123456789  # fetch by run id into ./ci_logs

Notes:
  - Requires 'gh' CLI with repo read access. Run: gh auth login
  - Artifact name expected: ci-logs (from CI workflow)
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage; exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' CLI not found. Install from https://cli.github.com/" >&2
  exit 1
fi

ARTIFACT_NAME="ci-logs"
BRANCH="dev"
RUN_ID=""
OUTDIR="ci_logs"

if [[ "${1:-}" == "--run" ]]; then
  RUN_ID="${2:-}"
  if [[ -z "$RUN_ID" ]]; then echo "Error: --run requires a run id" >&2; exit 2; fi
  OUTDIR="${3:-$OUTDIR}"
else
  BRANCH="${1:-$BRANCH}"
  OUTDIR="${2:-$OUTDIR}"
fi

mkdir -p "$OUTDIR"

if [[ -n "$RUN_ID" ]]; then
  echo "Downloading artifact '$ARTIFACT_NAME' from run $RUN_ID into $OUTDIR ..."
  gh run download "$RUN_ID" --name "$ARTIFACT_NAME" --dir "$OUTDIR"
else
  echo "Resolving latest run on branch '$BRANCH' ..."
  RUN_ID=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId')
  if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
    echo "Error: No runs found on branch '$BRANCH'" >&2
    exit 3
  fi
  echo "Downloading artifact '$ARTIFACT_NAME' from run $RUN_ID into $OUTDIR ..."
  gh run download "$RUN_ID" --name "$ARTIFACT_NAME" --dir "$OUTDIR"
fi

echo "Downloaded files:"
find "$OUTDIR" -maxdepth 2 -type f -print

SUMMARY_FILE="$OUTDIR/ci-logs/ci_summary.txt"
if [[ -f "$SUMMARY_FILE" ]]; then
  echo
  echo "--- CI Summary (tail) ---"
  tail -n 200 "$SUMMARY_FILE" || true
fi

echo "Done."

