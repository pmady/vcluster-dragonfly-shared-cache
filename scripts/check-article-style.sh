#!/usr/bin/env bash
set -euo pipefail

# check-article-style.sh
#
# Checks article/draft.md for style rules used in this repository:
#   - no Unicode em dash
#   - no Unicode en dash
#   - no banned marketing words
#   - no phrase "best solution"
#   - no phrase "only solution"
#
# Exit status:
#   0  no violations found
#   1  at least one violation found
#
# Usage:
#   scripts/check-article-style.sh [article_file]

article_file="${1:-article/draft.md}"

if [ ! -f "$article_file" ]; then
  echo "error: article file not found: $article_file" >&2
  exit 2
fi

violations=0

# Unicode em dash (U+2014).
if grep -n $'\xe2\x80\x94' -- "$article_file" >/dev/null 2>&1; then
  echo "style: em dash found in $article_file (use commas, colons, parentheses, or hyphens)"
  grep -n $'\xe2\x80\x94' -- "$article_file" | cut -d: -f1 | tr '\n' ' '
  echo
  violations=1
fi

# Unicode en dash (U+2013).
if grep -n $'\xe2\x80\x93' -- "$article_file" >/dev/null 2>&1; then
  echo "style: en dash found in $article_file (use commas, colons, parentheses, or hyphens)"
  grep -n $'\xe2\x80\x93' -- "$article_file" | cut -d: -f1 | tr '\n' ' '
  echo
  violations=1
fi

# Banned marketing words, matched case-insensitively.
banned_words=(
  'seamless'
  'robust'
  'powerful'
  'game-changing'
  'leverage'
  'best-in-class'
  'unlock'
  'effortless'
)

for word in "${banned_words[@]}"; do
  if grep -n -i -F -e "$word" -- "$article_file" >/dev/null 2>&1; then
    echo "style: banned marketing word found in $article_file: $word"
    violations=1
  fi
done

# Banned phrases.
banned_phrases=(
  'best solution'
  'only solution'
)

for phrase in "${banned_phrases[@]}"; do
  if grep -n -i -F -e "$phrase" -- "$article_file" >/dev/null 2>&1; then
    echo "style: banned phrase found in $article_file: $phrase"
    violations=1
  fi
done

if [ "$violations" -ne 0 ]; then
  echo "check-article-style: style violations were found, review the items above" >&2
  exit 1
fi

echo "check-article-style: no style violations found"
