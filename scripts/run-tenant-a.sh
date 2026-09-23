#!/usr/bin/env bash
set -euo pipefail

# run-tenant-a.sh
#
# Placeholder for the tenant-a cold-pull run. Fill in the exact commands used in
# the real lab, then capture their output into evidence/raw. Do not invent
# commands or values. Do not read or print credentials.
#
# Usage:
#   scripts/run-tenant-a.sh [output_directory]

out_dir="${1:-evidence/raw/tenant-a}"
mkdir -p "$out_dir"

echo "tenant-a run is not yet defined."
echo "Fill in the exact commands and capture output to: $out_dir"
echo "[NEED: exact kubectl apply command against the tenant-a context]"
echo "[NEED: exact commands to capture origin evidence and checksum]"

# Intentionally exit nonzero so this placeholder is not mistaken for a real run.
exit 1
