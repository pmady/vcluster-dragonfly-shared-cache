# Architecture

This document describes the layers in the lab and the boundaries between them.
It states what the lab is designed to test and what it does not attempt to
prove.

[FIGURE 1: host cluster, Dragonfly components, two vCluster API boundaries,
tenant Jobs, peer path, and Hugging Face origin]

## Host layer

A single disposable Kubernetes cluster runs on a laptop using kind. The host
nodes are owned by the platform. Node count and topology are recorded in the
evidence as `[NEED: node topology]`.

## Dragonfly platform layer

Dragonfly runs only on the host cluster. The manager, scheduler, and client
DaemonSet are platform-owned. The client cache lives on the host nodes at
`[NEED: cache directory]` with capacity `[NEED: cache capacity]`. Tenants do not
own or configure Dragonfly.

## vCluster control-plane layer

Two open source vCluster control planes, tenant-a and tenant-b, run on the host
cluster. Each has its own API server and its own kube context. A tenant sees its
own control plane, not the host control plane.

## Tenant workload layer

Each tenant runs an ordinary Kubernetes Job that requests the same pinned public
model artifact. The Job must not receive hostPath, hostNetwork, privileged mode,
hostPID, or hostIPC. The exact security context is recorded as
`[NEED: Job security context]`.

## Origin model hub

The origin is the public Hugging Face model hub. The repository, revision, and
file are recorded as `[NEED: model repository]`, `[NEED: model revision]`, and
`[NEED: requested file]`. The chosen artifact is public and needs no access
token.

## Ownership matrix

| Component | Owner | Notes |
| --- | --- | --- |
| Host nodes | Platform | Disposable kind cluster |
| Dragonfly manager, scheduler, client | Platform | Runs on host only |
| Dragonfly cache | Platform | Lives on host nodes |
| vCluster control planes | Platform provisions, tenant uses | Open source vCluster |
| Tenant Job | Tenant | Ordinary Kubernetes Job |
| Model artifact | Origin (Hugging Face) | Public, pinned by revision |

## Data-flow sequence

[FIGURE 2: ownership boundary between the platform team and tenants]

1. tenant-a submits a Job that requests the artifact.
2. The request reaches the platform-owned Dragonfly path.
3. On a cold cache, Dragonfly fetches the artifact from the origin.
4. The artifact is cached on the host.
5. tenant-b later submits a Job that requests the same artifact.
6. Dragonfly serves the second request from a local cache or a peer, or from the
   origin. The actual source is determined only by evidence, not assumed here.

## Isolation boundaries

- Each tenant is confined to its own vCluster API server.
- Tenant Jobs run without node-level privileges.
- Dragonfly configuration and cache are outside tenant control.

## Claims that are not being made

- The lab does not claim that tenant-b was served by a peer until an exact
  Dragonfly log, metric, task record, or trace proves it.
- The lab does not establish a security boundary against a hostile tenant unless
  such testing is later supplied as evidence.
- The lab does not claim a production benchmark. Laptop timing is supporting
  information only.

## Alternatives

- A per-node registry mirror or pull-through cache.
- A shared PVC cache mounted into tenant workloads.

This design was selected to test cross-tenant reuse while keeping cache
ownership at the platform layer.
