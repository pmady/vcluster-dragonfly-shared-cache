#!/usr/bin/env bash
set -euo pipefail

# collect-evidence.sh
#
# Gathers the v0.1 evidence checklist into evidence/raw. It reads contexts and
# the Dragonfly namespace from versions.env. It captures component listings,
# per-context checks, tenant Job YAML and logs, Dragonfly logs, and host-node
# placement.
#
# It does not print or store credentials, kubeconfig contents, environment
# variables, tokens, account identifiers, or private hostnames. It does not run
# kubectl config view or any command that reveals certificate data.
#
# Interpreting whether the second pull came from the origin, a local cache, or a
# remote peer is left to a human reading the Dragonfly logs. This script only
# collects them.
#
# Usage:
#   scripts/collect-evidence.sh [output_directory]

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out_dir="${1:-$repo_root/evidence/raw/collect}"
env_file="$repo_root/versions.env"

if [ ! -f "$env_file" ]; then
  echo "error: $env_file not found. Copy versions.env.example to versions.env and fill it in." >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$env_file"

require_var() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "error: required variable $name is empty in versions.env" >&2
    exit 1
  fi
}

for v in HOST_CONTEXT TENANT_A_CONTEXT TENANT_B_CONTEXT DRAGONFLY_NAMESPACE TENANT_JOB_NAMESPACE; do
  require_var "$v"
done

mkdir -p "$out_dir"

capture() {
  local label="$1"
  shift
  local target="$out_dir/${label}.txt"
  echo "capturing: $label"
  if "$@" >"$target" 2>&1; then
    :
  else
    echo "(command failed: $* )" >>"$target"
  fi
}

host_ctx="$HOST_CONTEXT"
a_ctx="$TENANT_A_CONTEXT"
b_ctx="$TENANT_B_CONTEXT"
df_ns="$DRAGONFLY_NAMESPACE"
job_ns="$TENANT_JOB_NAMESPACE"

# 1. Host Dragonfly component listing.
capture "host-dragonfly-pods"       kubectl --context "$host_ctx" -n "$df_ns" get pods -o wide
capture "host-dragonfly-daemonset"  kubectl --context "$host_ctx" -n "$df_ns" get daemonset -o wide

# 2. Two vCluster context outputs (server version proves separate API servers).
capture "tenant-a-server-version"   kubectl --context "$a_ctx" version -o yaml
capture "tenant-b-server-version"   kubectl --context "$b_ctx" version -o yaml

# 3. Final tenant Job YAML.
capture "tenant-a-job"              kubectl --context "$a_ctx" -n "$job_ns" get job model-pull -o yaml
capture "tenant-b-job"             kubectl --context "$b_ctx" -n "$job_ns" get job model-pull -o yaml

# 4 and 5. Tenant logs.
capture "tenant-a-logs"            kubectl --context "$a_ctx" -n "$job_ns" logs job/model-pull
capture "tenant-b-logs"            kubectl --context "$b_ctx" -n "$job_ns" logs job/model-pull

# 6 and 7. Dragonfly origin and cache or peer evidence.
# Collect dfdaemon (client) logs from the host. A human reads these to tell
# origin, local cache, and remote peer apart.
capture "dragonfly-client-logs"    kubectl --context "$host_ctx" -n "$df_ns" logs -l app=dragonfly,component=client --all-containers --tail=-1

# 8. Host-node placement of the synced tenant pods.
capture "host-pods-model-pull"     kubectl --context "$host_ctx" get pods -A -o wide

# 9. Matching SHA-256 checksums, pulled from the tenant logs.
{
  echo "tenant-a:"
  grep -E '[0-9a-f]{64}' "$out_dir/tenant-a-logs.txt" || echo "WARNING: checksum not found for tenant-a"
  echo "tenant-b:"
  grep -E '[0-9a-f]{64}' "$out_dir/tenant-b-logs.txt" || echo "WARNING: checksum not found for tenant-b"
} >"$out_dir/checksums.txt"

echo
echo "collect-evidence: capture complete. Files are in $out_dir"
echo "WARNING: review every file for anything that must not be published, then"
echo "run scripts/check-no-secrets.sh before you stage these files."
