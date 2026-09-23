# One Model, Many Tenants: Running Dragonfly as a Shared P2P Model Cache Under vCluster

## Status

This is an experimental scaffold. It contains no result claims yet. Every
missing command, version, or measurement is written as `[NEED: ...]` and will be
filled only after real evidence is added to `evidence/`. Do not treat any value
here as measured until the evidence matrix marks it ready.

## Research question

When two tenants use separate vCluster API servers on one Kubernetes platform
and request the same pinned Hugging Face model artifact, can a platform-owned
Dragonfly deployment serve the second tenant from an existing local cache or
peer instead of downloading the artifact from the origin again, without giving
the tenant workload node-level privileges?

## Hypothesis

Stated neutrally: a platform-owned Dragonfly deployment may be able to serve the
second tenant's request from a local cache or a peer rather than the origin. The
lab is designed to confirm or reject this with evidence. It may show reuse, or
it may show that the second tenant still reached the origin.

## Architecture summary

- One disposable host Kubernetes cluster (kind) owned by the platform.
- Dragonfly manager, scheduler, and client DaemonSet running only on the host.
- Two open source vCluster control planes, tenant-a and tenant-b, each with its
  own API server and kube context.
- One ordinary Kubernetes Job per tenant, each requesting the same pinned public
  model artifact.

See `docs/architecture.md` for the full description.

## Validation scope

- The lab runs on a disposable local cluster.
- It tests cross-tenant reuse of a cached model artifact.
- It checks that tenant Jobs run without node-level privileges.
- It does not test hostile tenants, gated or private models, GPU scheduling, or
  cache eviction under pressure.

## Success criteria

- Host gate: Dragonfly components are healthy on the host cluster.
- Tenant gate: tenant-a and tenant-b use separate vCluster API contexts.
- Access gate: tenant Jobs have no hostPath, hostNetwork, privileged mode,
  hostPID, or hostIPC.
- Origin gate: tenant-a produces evidence of a cold origin request.
- Reuse gate: tenant-b produces evidence distinguishing origin, local-cache, and
  remote-peer traffic.
- Integrity gate: both tenants receive artifacts with the same checksum.

Wall-clock time on a laptop is supporting information, not a production
benchmark.

## Evidence requirements

- No claim is published without a file in `evidence/` that supports it.
- The claim that tenant-b was served by a peer requires an exact Dragonfly log,
  metric, task record, or trace. It is not assumed from timing.
- Every row in `docs/evidence-matrix.md` must reach status ready before its
  claim appears in the article.

## Alternatives

Two other approaches a platform team could use instead:

- A per-node registry mirror or pull-through cache.
- A shared PVC cache mounted into tenant workloads.

This design was selected to test cross-tenant reuse while keeping cache
ownership at the platform layer. It is not presented as better than these
alternatives.

## Repository layout

```
article/            Article draft and figures references
docs/               Test plan, evidence matrix, architecture
dragonfly/          Dragonfly values placeholder
kind/               Host cluster config placeholder
vclusters/          tenant-a and tenant-b config placeholders
workloads/          Model-pull Job manifest placeholder
scripts/            Safe capture and check scripts
evidence/           raw, processed, and private (private is never committed)
figures/            Figure assets
```

## Safe quick-start sequence

The commands below use placeholders. Replace each placeholder with the exact
command and version recorded during a real run, then capture the output as
evidence.

```bash
# 1. Create the disposable host cluster.
[NEED: exact kind create command using kind/kind-config.yaml]

# 2. Install Dragonfly on the host cluster only.
[NEED: exact helm install command using dragonfly/values.yaml]

# 3. Create the two tenants.
[NEED: exact vcluster create command for tenant-a]
[NEED: exact vcluster create command for tenant-b]

# 4. Capture the environment.
scripts/capture-environment.sh evidence/raw/environment

# 5. Run the cold pull in tenant-a, then the second pull in tenant-b.
[NEED: exact kubectl apply command against the tenant-a context]
[NEED: exact kubectl apply command against the tenant-b context]

# 6. Check the working tree before committing evidence.
make check
```

## Confidentiality and secret handling

Do not commit secrets or private material. This includes access tokens,
credentials, kubeconfig certificate data, enterprise instance identifiers,
license details, private messages, private email, roadmap material, internal
hostnames, private addresses that are not part of the disposable kind lab, and
cloud account identifiers. Keep unreviewed material in `evidence/private`, which
is never committed. Run `scripts/check-no-secrets.sh` before staging changes.

## Publication plan

1. Complete the lab and capture evidence into `evidence/`.
2. Fill every `[NEED: ...]` placeholder from the evidence.
3. Move each evidence matrix row to status ready.
4. Finish the article conclusion and figures.
5. Run `make check` and confirm no placeholder remains in a published claim.

## References

- https://www.cncf.io/blog/2026/04/06/peer-to-peer-acceleration-for-ai-model-distribution-with-dragonfly/
- https://d7y.io/blog/2026/03/11/p2p-accelerated-ai-model-downloads-native-hugging-face-and-modelscope-protocols-in-dragonfly/
- [NEED: Dragonfly documentation URL used during the lab]
- [NEED: Dragonfly Helm chart URL used during the lab]
- [NEED: hf:// backend PR or documentation URL]
- [NEED: vCluster documentation URL used during the lab]
