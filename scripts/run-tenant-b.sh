#!/usr/bin/env bash
set -euo pipefail

# run-tenant-b.sh
#
# Placeholder for the tenant-b second-pull run. Fill in the exact commands used
# in the real lab, then capture their output into evidence/raw. Do not invent
# commands or values. Do not read or print credentials.
#
# Usage:
#   scripts/run-tenant-b.sh [output_directory]

out_dir="${1:-evidence/raw/tenant-b}"
mkdir -p "$out_dir"

echo "tenant-b run is not yet defined."
echo "Fill in the exact commands and capture output to: $out_dir"
echo "[NEED: exact kubectl apply command against the tenant-b context]"
echo "[NEED: exact commands to capture reuse evidence and checksum]"

# Intentionally exit nonzero so this placeholder is not mistaken for a real run.
exit 1
