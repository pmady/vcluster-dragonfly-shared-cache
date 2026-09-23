# One Model, Many Tenants: Running Dragonfly as a Shared P2P Model Cache Under vCluster

Status: experimental scaffold. This draft contains no result claims yet. Every
missing command, version, or measurement is written as `[NEED: ...]` and will be
filled only after real evidence is added.

## Opening

When several teams share one Kubernetes platform, they often pull the same large
model artifacts again and again. Each pull crosses the same network path to the
same origin, and each team pays for it in time and bandwidth. I wanted to see
whether a platform-owned cache could serve the second team from bytes that are
already on the cluster, without handing tenant workloads any node-level
privileges.

In this article I run a small, reproducible lab. Two tenants sit behind separate
vCluster API servers on one host cluster. A platform-owned Dragonfly deployment
runs only on the host. Both tenants ask for the same pinned public Hugging Face
model artifact. I record what happens on the first pull and on the second pull,
and I let the evidence decide whether the second tenant was served from the
origin, a local cache, or a remote peer.

## Validation scope

> This is a lab on a disposable kind cluster. It is not a production benchmark.
> Wall-clock time on a laptop is supporting information only. I make no claim
> about hostile tenants, gated or private models, GPU scheduling, or cache
> eviction under pressure. Result claims appear only where an evidence file
> supports them.

## Architecture

[FIGURE 1: architecture diagram]

Dragonfly runs only on the host cluster. Its manager, scheduler, and client
DaemonSet are owned by the platform. Two open source vCluster control planes,
tenant-a and tenant-b, each expose their own API server. Each tenant runs an
ordinary Kubernetes Job that requests the same artifact from the origin.

I selected this design to test cross-tenant reuse while keeping cache ownership
at the platform layer. A per-node registry mirror and a shared PVC cache are two
alternatives a platform team could use instead. See `docs/architecture.md` for
the full layer and ownership description.

## Host cluster setup

I use a disposable kind cluster.

- kind version: `[NEED: kind version]`
- Kubernetes version: `[NEED: kubernetes server version]`
- Node topology: `[NEED: node count and roles]`
- Create command: `[NEED: exact kind create command]`

## Dragonfly Helm installation

[FIGURE 3: Dragonfly components running only on the host cluster]

I install Dragonfly on the host cluster only.

- Helm chart version: `[NEED: dragonfly helm chart version]`
- Application version: `[NEED: dragonfly application version]`
- Install command: `[NEED: exact helm install command]`
- Health check: `[NEED: kubectl output showing manager, scheduler, and client
  DaemonSet healthy]`

## Creation of tenant-a and tenant-b

[FIGURE 2: separate tenant-a and tenant-b Kubernetes contexts]

I create two open source vCluster control planes.

- vCluster CLI version: `[NEED: vcluster cli version]`
- tenant-a create command: `[NEED: exact command]`
- tenant-b create command: `[NEED: exact command]`
- tenant-a context: `[NEED: context name]`
- tenant-b context: `[NEED: context name]`

## Tenant Job manifest

Each tenant runs the same Job. The Job requests the pinned artifact and must not
receive hostPath, hostNetwork, privileged mode, hostPID, or hostIPC.

- Manifest path: `workloads/model-pull-job.yaml`
- Security context summary: `[NEED: securityContext used, showing no node-level
  privileges]`
- Requested model repository: `[NEED: model repository]`
- Requested revision: `[NEED: immutable revision]`
- Requested file: `[NEED: requested file name]`

## tenant-a cold pull

[FIGURE 4: tenant-a cold pull and origin evidence]

I apply the Job in the tenant-a context against an empty cache.

- Cache-empty evidence: `[NEED: command, task query, or metric showing the cache
  did not hold the artifact]`
- Start timestamp: `[NEED: UTC start]`
- End timestamp: `[NEED: UTC end]`
- Host node placement: `[NEED: host node]`
- Origin evidence: `[NEED: Dragonfly log, metric, or task record showing an
  origin download for tenant-a]`
- Checksum received: `[NEED: checksum value and algorithm]`

## tenant-b second pull

[FIGURE 5: tenant-b pull and peer or cache evidence]

[FIGURE 6: host-node placement for both tenant workloads]

I apply the same Job in the tenant-b context. I do not clear the cache between
runs. To test remote-peer transfer, placing the two Jobs on different host
workers is preferred. I record the actual placement rather than assume it.

- Start timestamp: `[NEED: UTC start]`
- End timestamp: `[NEED: UTC end]`
- Host node placement: `[NEED: host node]`
- Reuse evidence: `[NEED: Dragonfly log, metric, task record, or trace that
  names the source of the bytes served to tenant-b]`
- Checksum received: `[NEED: checksum value and algorithm]`

## Dragonfly metric or log interpretation

I read the evidence against three definitions:

- Origin download: bytes fetched from the Hugging Face origin during the run
  being evaluated.
- Local node cache: bytes served from the Dragonfly cache on the same host node
  as the Job.
- Remote peer transfer: bytes served from a Dragonfly peer on a different host
  node.

- tenant-a interpretation: `[NEED: which case the tenant-a evidence supports]`
- tenant-b interpretation: `[NEED: which case the tenant-b evidence supports]`

## What the numbers mean

[FIGURE 7: matching artifact checksums]

- Checksum comparison: `[NEED: statement that tenant-a and tenant-b received the
  same checksum, with evidence]`
- Reuse statement: `[NEED: evidence-backed statement of how tenant-b was served]`

I will state that tenant-b was served by a peer only if an exact Dragonfly log,
metric, task record, or trace proves it.

## What the numbers do not mean

- Laptop timing is not a production benchmark.
- A single run does not characterize cache behavior under load.
- The lab does not measure gated models, private models, or GPU workloads.
- The lab does not test a hostile tenant.

## Operational notes

- Dragonfly is platform-owned and runs only on the host.
- Tenants use ordinary Jobs with no node-level privileges.
- A per-node registry mirror and a shared PVC cache are alternatives a platform
  team could choose instead, with different ownership and failure modes.

## Limitations

- Tested: `[NEED: list of what was actually tested]`
- Untested: `[NEED: list of what was not tested, including GPU, network policy,
  eviction, cache pressure, private models, and hostile tenants]`

## Conclusion

`[NEED: three-sentence conclusion, written only after evidence is complete.]`

## References

[FIGURE 8: final evidence matrix]

- https://www.cncf.io/blog/2026/04/06/peer-to-peer-acceleration-for-ai-model-distribution-with-dragonfly/
- https://d7y.io/blog/2026/03/11/p2p-accelerated-ai-model-downloads-native-hugging-face-and-modelscope-protocols-in-dragonfly/
- [NEED: Dragonfly documentation URL used during the lab]
- [NEED: Dragonfly Helm chart URL used during the lab]
- [NEED: hf:// backend PR or documentation URL]
- [NEED: vCluster documentation URL used during the lab]

## Author bio

Pavan Madduri is a Senior Cloud Platform Engineer at W.W. Grainger and the
elected Tech Lead of CNCF's TAG Workloads Foundation (2026 to 2028). He
contributes to Dragonfly, a graduated CNCF project, and is a vCluster Ambassador
and CNCF Golden Kubestronaut.

Disclosure: the author is a member of the vCluster Ambassador Program. This
article uses only open source vCluster features and was not reviewed or
sponsored by vCluster Labs.
