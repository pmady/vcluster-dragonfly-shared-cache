#!/usr/bin/env bash
set -euo pipefail

# capture-environment.sh
#
# Captures non-sensitive environment information for a lab run and writes each
# result to its own file in an output directory. The output directory is the
# first argument and defaults to evidence/raw/environment.
#
# This script intentionally does not read or print credentials. It never runs
# commands that display kubeconfig certificate data, tokens, or shell
# environment variables.
#
# Usage:
#   scripts/capture-environment.sh [output_directory]

out_dir="${1:-evidence/raw/environment}"

mkdir -p "$out_dir"

# run_capture LABEL COMMAND [ARGS...]
# Runs a command and stores stdout and stderr in "$out_dir/LABEL.txt".
# A failure is recorded in the file but does not stop the script, so a partial
# environment can still be captured on a machine missing an optional tool.
run_capture() {
  local label="$1"
  shift
  local target="$out_dir/${label}.txt"
  echo "capturing: $label"
  if "$@" >"$target" 2>&1; then
    :
  else
    echo "(command failed or tool not present: $* )" >>"$target"
  fi
}

# UTC timestamp for the capture itself.
date -u '+%Y-%m-%dT%H:%M:%SZ' >"$out_dir/timestamp-utc.txt"

run_capture "uname"                 uname -a
run_capture "docker-version"        docker version
run_capture "kind-version"          kind version
run_capture "kubectl-version"       kubectl version
run_capture "helm-version"          helm version
run_capture "vcluster-version"      vcluster version
run_capture "kube-current-context"  kubectl config current-context
run_capture "kube-nodes"            kubectl get nodes -o wide
run_capture "kube-pods-all"         kubectl get pods -A -o wide
run_capture "helm-list-all"         helm list -A

cat <<'WARNING'

capture-environment: capture complete.

WARNING: review every file in the output directory before committing it.
Command output can contain node names, image references, or other details that
should be checked against the repository confidentiality rules. Remove or
redact anything that must not be published, and run scripts/check-no-secrets.sh
before you stage these files.
WARNING
