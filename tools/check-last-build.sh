#!/usr/bin/env bash
set -euo pipefail

# One-click helper to inspect the latest CI run on a branch (default: dev),
# download its logs, and open the summary for fast triage.
#
# Usage:
#   tools/check-last-build.sh [branch]

BRANCH="${1:-dev}"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' CLI not found. Install: https://cli.github.com/" >&2
  exit 1
fi

echo "Resolving latest run on branch '$BRANCH' ..."
# Query fields without requiring the gh-jq extension
RUN_ID=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)
if [[ -z "${RUN_ID:-}" || "$RUN_ID" == "null" ]]; then
  echo "No runs found on branch '$BRANCH'." >&2
  exit 3
fi
STATUS=$(gh run list --branch "$BRANCH" --limit 1 --json status --jq '.[0].status' 2>/dev/null || echo n/a)
CONCLUSION=$(gh run list --branch "$BRANCH" --limit 1 --json conclusion --jq '.[0].conclusion' 2>/dev/null || echo n/a)
SHA=$(gh run list --branch "$BRANCH" --limit 1 --json headSha --jq '.[0].headSha' 2>/dev/null || echo n/a)
TITLE=$(gh run list --branch "$BRANCH" --limit 1 --json displayTitle --jq '.[0].displayTitle' 2>/dev/null || echo n/a)
NAME=$(gh run list --branch "$BRANCH" --limit 1 --json name --jq '.[0].name' 2>/dev/null || echo n/a)

echo "Run: $RUN_ID | $NAME — $TITLE"
echo "Status: $STATUS | Conclusion: ${CONCLUSION:-n/a} | SHA: $SHA"

OUTDIR="ci_logs"
mkdir -p "$OUTDIR"
echo "Downloading artifact 'ci-logs' from run $RUN_ID into $OUTDIR ..."
gh run download "$RUN_ID" --name ci-logs --dir "$OUTDIR"

# Decompress pod install log for convenience (if present)
if [[ -f "$OUTDIR/ci-logs/pod_install.log.gz" ]]; then
  gzip -df "$OUTDIR/ci-logs/pod_install.log.gz" || true
fi

SUMMARY="$OUTDIR/ci-logs/ci_summary.txt"
if [[ -f "$SUMMARY" ]]; then
  echo
  echo "===== CI Summary (tail) ====="
  tail -n 120 "$SUMMARY" || true
  echo "============================="
  # Try to open summary in editor or default viewer
  if command -v code >/dev/null 2>&1; then
    code -r "$SUMMARY" || true
  elif [[ "$OSTYPE" == darwin* ]]; then
    open "$SUMMARY" || true
  fi
else
  echo "No ci_summary.txt found under $OUTDIR; artifact may be missing a summary."
fi

echo "Done. Logs under: $OUTDIR/ci-logs"
