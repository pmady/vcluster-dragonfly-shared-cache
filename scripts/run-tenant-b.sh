#!/usr/bin/env bash
set -euo pipefail

# run-tenant-b.sh
#
# Runs the model-pull Job in tenant-b (the second run) and captures the Job YAML,
# host placement, and logs into evidence/raw/tenant-b. Run this after
# run-tenant-a.sh and do not clear the Dragonfly cache in between. To test
# remote-peer delivery, place tenant-b on a different host worker than tenant-a
# (for example by cordoning the node tenant-a used before running this, then
# uncordoning after). Reads configuration from versions.env. Does not print
# credentials or kubeconfig contents.
#
# Usage:
#   scripts/run-tenant-b.sh [output_directory]

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out_dir="${1:-$repo_root/evidence/raw/tenant-b}"
job_manifest="$repo_root/workloads/model-pull-job.yaml"
env_file="$repo_root/versions.env"
job_timeout="${JOB_TIMEOUT:-600s}"

if [ ! -f "$env_file" ]; then
  echo "error: $env_file not found. Copy versions.env.example to versions.env and fill it in." >&2
  exit 1
fi
# shellcheck disable=SC1090
. "$env_file"

require_var() {
  if [ -z "${!1:-}" ]; then
    echo "error: required variable $1 is empty in versions.env" >&2
    exit 1
  fi
}
for v in TENANT_B_CONTEXT TENANT_JOB_NAMESPACE DRAGONFLY_PROXY_PORT DOWNLOAD_IMAGE \
         MODEL_REPOSITORY MODEL_REVISION MODEL_FILE; do
  require_var "$v"
done

ctx="$TENANT_B_CONTEXT"
ns="$TENANT_JOB_NAMESPACE"
mkdir -p "$out_dir"

echo "tenant-b: context $ctx, namespace $ns"
kubectl --context "$ctx" get namespace "$ns" >/dev/null 2>&1 \
  || kubectl --context "$ctx" create namespace "$ns"

kubectl --context "$ctx" -n "$ns" create configmap model-pull-config \
  --from-literal=MODEL_REPOSITORY="$MODEL_REPOSITORY" \
  --from-literal=MODEL_REVISION="$MODEL_REVISION" \
  --from-literal=MODEL_FILE="$MODEL_FILE" \
  --from-literal=DRAGONFLY_PROXY_PORT="$DRAGONFLY_PROXY_PORT" \
  --dry-run=client -o yaml | kubectl --context "$ctx" -n "$ns" apply -f -

kubectl --context "$ctx" -n "$ns" delete job model-pull --ignore-not-found
sed "s|\${DOWNLOAD_IMAGE}|$DOWNLOAD_IMAGE|g" "$job_manifest" \
  | kubectl --context "$ctx" -n "$ns" apply -f -

job_failed=0
if ! kubectl --context "$ctx" -n "$ns" wait --for=condition=complete \
     job/model-pull --timeout="$job_timeout"; then
  job_failed=1
fi

kubectl --context "$ctx" -n "$ns" get job model-pull -o yaml > "$out_dir/job.yaml"
kubectl --context "$ctx" -n "$ns" get pod -l job-name=model-pull -o wide > "$out_dir/pod.txt" 2>&1 || true
kubectl --context "$ctx" -n "$ns" logs job/model-pull > "$out_dir/logs.txt" 2>&1 || true

echo "===== tenant-b ====="; cat "$out_dir/logs.txt"
echo "--- host placement ---"; cat "$out_dir/pod.txt"
grep -E '[0-9a-f]{64}' "$out_dir/logs.txt" || echo "WARNING: checksum not found, inspect $out_dir/logs.txt"

if [ "$job_failed" -ne 0 ]; then
  echo "error: model-pull Job did not complete in tenant-b" >&2
  exit 1
fi
echo "tenant-b: done. Review files in $out_dir before committing."
