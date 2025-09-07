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
# Single query for all fields
TSV=$(gh run list --branch "$BRANCH" --limit 1 \
  --json databaseId,status,conclusion,headSha,displayTitle,name \
  --jq '.[0] | [ .databaseId, .status, (.conclusion // "n/a"), .headSha, (.displayTitle // "n/a"), (.name // "n/a") ] | @tsv' 2>/dev/null || true)
if [[ -z "${TSV:-}" ]]; then
  echo "No runs found on branch '$BRANCH'." >&2
  exit 3
fi
IFS=$'\t' read -r RUN_ID STATUS CONCLUSION SHA TITLE NAME <<<"$TSV"

echo "Run: $RUN_ID | $NAME — $TITLE"
echo "Status: $STATUS | Conclusion: ${CONCLUSION:-n/a} | SHA: $SHA"

ROOT="ci_logs"
OUTDIR="$ROOT/run-$RUN_ID"
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

if [[ -f "$SUMMARY" ]]; then
  cp -f "$SUMMARY" "$ROOT/ci_summary.txt" || true
fi
for gz in build.log.gz pod_install.log.gz; do
  if [[ -f "$OUTDIR/ci-logs/$gz" ]]; then
    cp -f "$OUTDIR/ci-logs/$gz" "$ROOT/$gz" || true
  fi
done

echo "Done. Logs under: $OUTDIR/ci-logs (latest pointers in $ROOT/)"

# Determine build result and report
if [[ "${CONCLUSION:-}" == "success" ]]; then
  echo "Result: Build is GREEN (run $RUN_ID, sha $SHA)."
  exit 0
else
  echo "Result: Build FAILED or not successful (status=$STATUS, conclusion=${CONCLUSION:-n/a})."
  echo "Next: Investigate ci_summary.txt and logs (pod_install.log, build.log) to find the cause, propose a fix, apply changes, and push."
fi
