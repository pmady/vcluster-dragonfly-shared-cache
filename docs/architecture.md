# Architecture

This describes the layers in the lab and the boundaries between them, as run on
2026-09-26. See [../evidence/processed/results.md](../evidence/processed/results.md)
for the classified result. See the README for an architecture diagram.

## Host layer

One disposable kind cluster, Kubernetes v1.37.0, with one control-plane and two
worker nodes. The host nodes are owned by the platform.

## Dragonfly platform layer

Dragonfly runs only on the host cluster (chart 1.8.5, app 2.5.2) in manager-less
mode: schedulers, seed peers, and a client (dfdaemon) DaemonSet. The client runs
on hostNetwork and exposes an HTTP proxy on port 4001 on each node. The cache
lives on the seed peers and clients on the host nodes. Tenants do not own or
configure Dragonfly.

## vCluster control-plane layer

Two open source vClusters, tenant-a and tenant-b, run on the host cluster
(vcluster CLI 0.37.2). Each has its own API server (v1.36.0) and its own kube
context. A tenant sees its own control plane, not the host control plane.

## Tenant workload layer

Each tenant runs the same Kubernetes Job requesting distilbert-base-uncased,
revision 12040accade4e8a0f71eabdb258fecc2e7e948be, file model.safetensors. The
Job reaches the node-local Dragonfly proxy through the downward-API host IP. It
has no hostPath, hostNetwork, hostPID, hostIPC, or privileged container, runs as
a non-root user, and drops all capabilities.

## Origin model hub

The origin is the public Hugging Face hub. The file is served from the Hugging
Face Xet CDN (us.aws.cdn.hf.co). The artifact is public and needs no token.

## Ownership matrix

| Component | Owner | Notes |
| --- | --- | --- |
| Host nodes | Platform | Disposable kind cluster |
| Dragonfly scheduler, seed peers, client | Platform | Host only, manager-less |
| Dragonfly cache | Platform | On host nodes |
| vCluster control planes | Platform provisions, tenant uses | Open source vCluster |
| Tenant Job | Tenant | Ordinary Kubernetes Job |
| Model artifact | Origin (Hugging Face) | Public, pinned by revision |

## Data-flow sequence

1. tenant-a submits a Job that requests the artifact through the node-local proxy.
2. On a cold cache, the scheduler assigns the seed peer, which fetches from the
   origin and serves tenant-a. The task is registered under a stable task_id.
3. tenant-b (on a different worker) submits the same request.
4. The scheduler returns peer parents (the node that ran tenant-a, plus the seed
   peer). tenant-b collects all pieces from those peers, with no origin fetch.

## Isolation boundaries

- Each tenant is confined to its own vCluster API server.
- Tenant Jobs run without node-level privileges.
- Dragonfly configuration and cache are outside tenant control.

## Claims not made

- No security boundary against a hostile tenant was tested.
- No performance benchmark is claimed; laptop timing is observational.

## Alternatives

A per-node registry mirror or pull-through cache, or a shared PVC cache mounted
into tenant workloads. This design was chosen to test cross-tenant reuse while
keeping cache ownership at the platform layer.
