#!/usr/bin/env bash
set -euo pipefail

# check-no-secrets.sh
#
# Basic safety check, not a complete secret scanner. It looks for a small set
# of common credential markers and reports the file paths that contain them.
# It never prints the matching line or the suspected value.
#
# The pattern strings below are assembled by concatenation so that the literal
# markers do not appear contiguously in this file. That keeps the scanner from
# matching itself and lets documentation describe the markers without tripping
# the check.
#
# Usage:
#   scripts/check-no-secrets.sh [root_directory]
#
# Exit status:
#   0  no suspected markers found
#   1  at least one suspected marker found

root_dir="${1:-.}"

if [ ! -d "$root_dir" ]; then
  echo "error: directory not found: $root_dir" >&2
  exit 2
fi

# Each entry is a fixed string built from two or more quoted pieces.
patterns=(
  'ghp''_'
  'github''_pat_'
  'hf''_'
  'AK''IA'
  'BEGIN PRIVATE ''KEY'
  'client-certificate-''data:'
  'client-key-''data:'
  'token'':'
  'password'':'
  'Instance ''ID'
  'AMB''-'
)

found=0

while IFS= read -r file; do
  for pat in "${patterns[@]}"; do
    if grep -I -l -F -e "$pat" -- "$file" >/dev/null 2>&1; then
      echo "suspected secret marker in: $file"
      found=1
      break
    fi
  done
done < <(find "$root_dir" -type f \
  -not -path '*/.git/*' \
  -not -path '*/evidence/private/*')

if [ "$found" -ne 0 ]; then
  echo "check-no-secrets: suspected secret markers were found, review the files above" >&2
  exit 1
fi

echo "check-no-secrets: no suspected secret markers found"
