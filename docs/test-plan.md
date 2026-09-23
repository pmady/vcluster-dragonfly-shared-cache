# Test Plan

This plan describes how the lab is run and how each observation becomes
evidence. It contains no result claims. Where a command, version, or value must
come from the actual lab, it is written as `[NEED: precise description]`.

## Experiment question

When two tenants use separate vCluster API servers on one Kubernetes platform
and request the same pinned Hugging Face model artifact, can a platform-owned
Dragonfly deployment serve the second tenant from an existing local cache or
peer instead of downloading the artifact from the origin again, without giving
the tenant workload node-level privileges?

## Assumptions

- The host cluster is a disposable local kind cluster used only for this lab.
- Dragonfly runs only on the host cluster and is owned by the platform.
- Both tenants request the same pinned public model artifact by revision.
- The model is public and does not require an access token.
- Wall-clock timing on a laptop is supporting information, not a production
  benchmark.

## Non-goals

- No production performance benchmark.
- No security claim about hostile or adversarial tenants.
- No claim about gated or private models.
- No claim about GPU scheduling behavior.
- No claim that this design is better than the alternatives listed below.

## Trust model

- The platform team owns and operates Dragonfly and the host nodes.
- Tenants operate inside vCluster control planes and run ordinary Kubernetes
  Jobs.
- Tenant Jobs must not receive hostPath, hostNetwork, privileged mode, hostPID,
  or hostIPC.
- This lab does not establish a security boundary against a tenant that is
  trying to break isolation. That would require separate testing supplied as
  evidence.

## Alternatives considered

- A per-node registry mirror or pull-through cache.
- A shared PVC cache mounted into tenant workloads.

These are noted so the reader can compare. This lab tests cross-tenant reuse
with cache ownership kept at the platform layer.

## Procedure

### 1. Host cluster preflight

- Create the disposable host cluster.
  - Command: `[NEED: exact kind create command used, including config path]`
  - kind version: `[NEED: kind version]`
  - Kubernetes version: `[NEED: kubernetes server version]`
- Record node topology.
  - Command: `[NEED: kubectl get nodes -o wide output captured to evidence]`
- Capture the environment with `scripts/capture-environment.sh`.

### 2. Dragonfly installation evidence

- Install Dragonfly on the host cluster only.
  - Helm chart and version: `[NEED: dragonfly helm chart name and version]`
  - Application version: `[NEED: dragonfly application version]`
  - Install command: `[NEED: exact helm install command and values reference]`
- Confirm manager, scheduler, and client DaemonSet are healthy.
  - Command: `[NEED: kubectl get pods output for the dragonfly namespace]`
- Record the client cache directory and capacity.
  - Values: `[NEED: cache directory]`, `[NEED: cache capacity]`

### 3. vCluster installation evidence

- Create tenant-a and tenant-b as open source vCluster control planes.
  - vCluster CLI version: `[NEED: vcluster cli version]`
  - tenant-a create command: `[NEED: exact command]`
  - tenant-b create command: `[NEED: exact command]`
- Record each tenant server version.
  - Values: `[NEED: tenant-a server version]`, `[NEED: tenant-b server version]`

### 4. Tenant connectivity validation

- Confirm tenant-a and tenant-b use separate API contexts.
  - tenant-a context: `[NEED: context name]`
  - tenant-b context: `[NEED: context name]`
- Confirm each context reaches its own API server.
  - Command: `[NEED: per-context kubectl command and captured output]`

### 5. Public model selection

- Choose one pinned public model artifact by revision.
  - Provider: `[NEED: provider, expected Hugging Face]`
  - Repository: `[NEED: model repository]`
  - Revision: `[NEED: immutable revision or commit]`
  - File: `[NEED: requested file name]`
  - Approximate size: `[NEED: artifact size]`
- Confirm the artifact is public and needs no access token.

### 6. Cache-empty validation

- Confirm the Dragonfly cache does not already hold the artifact before the
  first run.
  - Command or metric: `[NEED: exact command, task query, or metric read]`
  - Captured state: `[NEED: evidence file showing an empty or absent entry]`

### 7. tenant-a cold-pull procedure

- Run the model-pull Job in tenant-a.
  - Command: `[NEED: exact kubectl apply command against the tenant-a context]`
  - Start timestamp: `[NEED: UTC start]`
  - End timestamp: `[NEED: UTC end]`
- Capture origin evidence.
  - Evidence: `[NEED: Dragonfly log, metric, or task record showing an origin
    download for tenant-a]`
- Record the artifact checksum received in tenant-a.
  - Checksum: `[NEED: checksum value and algorithm]`

### 8. Inter-run state validation

- Confirm the cache now holds the artifact and record which host node holds it.
  - Command or metric: `[NEED: exact command or metric read]`
  - Host node placement of tenant-a Job: `[NEED: host node]`
- Do not delete the cache between runs.

### 9. tenant-b second-pull procedure

- Run the same model-pull Job in tenant-b.
  - Command: `[NEED: exact kubectl apply command against the tenant-b context]`
  - Start timestamp: `[NEED: UTC start]`
  - End timestamp: `[NEED: UTC end]`
- Record the host node placement of the tenant-b Job.
  - Host node: `[NEED: host node]`
- Capture reuse evidence that distinguishes three cases:
  - origin download,
  - local node cache hit,
  - remote peer transfer.
  - Evidence: `[NEED: Dragonfly log, metric, task record, or trace that names
    the source of the bytes served to tenant-b]`

### 10. Checksum validation

- Compare the checksum received in tenant-b with the checksum received in
  tenant-a.
  - tenant-a checksum: `[NEED: value]`
  - tenant-b checksum: `[NEED: value]`
  - Result: `[NEED: match or mismatch, with evidence file]`

### 11. Log and metric interpretation

Interpret evidence against these definitions:

- Origin download: bytes were fetched from the Hugging Face origin during the
  run being evaluated.
- Local node cache: bytes were served from the Dragonfly cache on the same host
  node where the requesting Job ran.
- Remote peer transfer: bytes were served from a Dragonfly peer on a different
  host node.

To test remote-peer transfer, placing the tenant-a and tenant-b Jobs on
different host workers is preferred. This plan does not claim that placement has
already occurred. Record the actual placement in the evidence.

### 12. Cleanup

- Remove tenants and the host cluster.
  - Commands: `[NEED: exact teardown commands]`
- Keep the retained evidence files.

## Failure conditions

- Dragonfly components are not healthy on the host cluster.
- A tenant context is not isolated from the other tenant context.
- A tenant Job is admitted with hostPath, hostNetwork, privileged mode, hostPID,
  or hostIPC.
- tenant-a shows no origin evidence, so the cold pull is unproven.
- tenant-b evidence cannot distinguish origin, local cache, and remote peer.
- Checksums do not match between tenants.

Any failure condition blocks the related claim until it is resolved and
re-evidenced.

## Publication readiness checklist

- [ ] Host gate met: Dragonfly components healthy on the host cluster.
- [ ] Tenant gate met: tenant-a and tenant-b use separate vCluster contexts.
- [ ] Access gate met: no hostPath, hostNetwork, privileged mode, hostPID, or
      hostIPC on tenant Jobs.
- [ ] Origin gate met: tenant-a cold origin request evidenced.
- [ ] Reuse gate met: tenant-b traffic source distinguished with evidence.
- [ ] Integrity gate met: matching checksums evidenced.
- [ ] Every article claim links to an evidence file.
- [ ] `make check` passes.
- [ ] No `[NEED: ...]` placeholder remains in a published claim.
