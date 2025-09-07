#!/usr/bin/env bash
set -euo pipefail

# Inspect a specific GitHub Actions run by run ID (or URL containing it),
# download its ci-logs artifact, and show the summary/log tails.
#
# Usage:
#   tools/check-build.sh <run-id|run-url>

RUN_ARG=${1:-}
if [[ -z "$RUN_ARG" ]]; then
  echo "Usage: $0 <run-id|run-url>" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' CLI not found. Install: https://cli.github.com/" >&2
  exit 1
fi

# Extract numeric run id from input
if [[ "$RUN_ARG" =~ ^[0-9]+$ ]]; then
  RUN_ID="$RUN_ARG"
else
  RUN_ID=$(echo "$RUN_ARG" | sed -n 's#.*/runs/\([0-9][0-9]*\).*#\1#p')
fi

if [[ -z "${RUN_ID:-}" ]]; then
  echo "Could not parse run id from: $RUN_ARG" >&2
  exit 2
fi

ROOT="ci_logs"
OUTDIR="$ROOT/run-$RUN_ID"
mkdir -p "$OUTDIR"

echo "Downloading artifact 'ci-logs' from run $RUN_ID into $OUTDIR ..."
set +e
gh run download "$RUN_ID" --name ci-logs --dir "$OUTDIR"
RC=$?
set -e
if [[ $RC -ne 0 ]]; then
  echo "No 'ci-logs' artifact found by that name; listing artifacts for this run:" >&2
  gh run view "$RUN_ID" --json artifacts --jq '.artifacts[].name' || true
  echo "Trying to download any artifact that looks like ci logs..." >&2
  for name in $(gh run view "$RUN_ID" --json artifacts --jq '.artifacts[].name' 2>/dev/null || true); do
    if [[ "$name" == *"ci-logs"* || "$name" == "ci-logs" ]]; then
      gh run download "$RUN_ID" --name "$name" --dir "$OUTDIR" && break || true
    fi
  done
fi

SUMMARY="$OUTDIR/ci-logs/ci_summary.txt"
[[ -f "$SUMMARY" ]] || SUMMARY="$OUTDIR/ci_summary.txt"

# Decompress logs if gzipped
for f in build.log pod_install.log test.log; do
  if [[ -f "$OUTDIR/ci-logs/$f.gz" ]]; then gzip -df "$OUTDIR/ci-logs/$f.gz" || true; fi
done

echo
if [[ -f "$SUMMARY" ]]; then
  echo "===== CI Summary (run $RUN_ID) ====="
  tail -n 200 "$SUMMARY" || true
else
  echo "No ci_summary.txt found under $OUTDIR; open logs below."
fi

echo
echo "--- pod install tail ---"
[[ -f "$OUTDIR/ci-logs/pod_install.log" ]] && tail -n 120 "$OUTDIR/ci-logs/pod_install.log" || echo "(no pod_install.log)"
echo
echo "--- build log tail ---"
[[ -f "$OUTDIR/ci-logs/build.log" ]] && tail -n 200 "$OUTDIR/ci-logs/build.log" || echo "(no build.log)"
echo
echo "--- test log tail ---"
[[ -f "$OUTDIR/ci-logs/test.log" ]] && tail -n 200 "$OUTDIR/ci-logs/test.log" || echo "(no test.log)"

echo
echo "Done. Logs under: $OUTDIR/ci-logs"

