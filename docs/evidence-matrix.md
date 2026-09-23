# Evidence Matrix

Every factual claim in the article maps to a row here. A claim may be published
only when its evidence files exist and its status is marked ready. Unknown
factual fields start as `[NEED: ...]`.

Status values:

- `open`: no evidence yet.
- `partial`: some evidence, not enough to publish the claim.
- `ready`: evidence is complete and the publication wording is settled.

| Claim or observation | tenant-a evidence | tenant-b evidence | Dragonfly evidence | Source file | Status | Publication wording |
| --- | --- | --- | --- | --- | --- | --- |
| Run date | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: run date, UTC]` |
| Host cluster type | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: cluster type, expected disposable kind]` |
| Kubernetes version | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: kubernetes version]` |
| Node topology | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: node count and roles]` |
| Dragonfly version | not applicable | not applicable | `[NEED: version evidence]` | `[NEED: source file]` | open | `[NEED: dragonfly application version]` |
| Dragonfly chart version | not applicable | not applicable | `[NEED: chart evidence]` | `[NEED: source file]` | open | `[NEED: dragonfly helm chart version]` |
| vCluster version | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: vcluster cli and server version]` |
| Tenant contexts | `[NEED: tenant-a context evidence]` | `[NEED: tenant-b context evidence]` | not applicable | `[NEED: source file]` | open | `[NEED: two distinct context names]` |
| Host-node placement | `[NEED: tenant-a host node]` | `[NEED: tenant-b host node]` | not applicable | `[NEED: source file]` | open | `[NEED: node placement for both Jobs]` |
| Model repository | `[NEED: request evidence]` | `[NEED: request evidence]` | `[NEED: task evidence]` | `[NEED: source file]` | open | `[NEED: model repository]` |
| Model revision | `[NEED: request evidence]` | `[NEED: request evidence]` | `[NEED: task evidence]` | `[NEED: source file]` | open | `[NEED: immutable revision]` |
| Requested file | `[NEED: request evidence]` | `[NEED: request evidence]` | `[NEED: task evidence]` | `[NEED: source file]` | open | `[NEED: requested file name]` |
| Artifact size | `[NEED: size evidence]` | `[NEED: size evidence]` | `[NEED: task evidence]` | `[NEED: source file]` | open | `[NEED: artifact size]` |
| Cache state before tenant-a | not applicable | not applicable | `[NEED: empty-cache evidence]` | `[NEED: source file]` | open | `[NEED: cache empty before first run]` |
| Cache state before tenant-b | not applicable | not applicable | `[NEED: cache-populated evidence]` | `[NEED: source file]` | open | `[NEED: cache holds artifact before second run]` |
| Origin traffic | `[NEED: tenant-a origin evidence]` | `[NEED: tenant-b origin evidence]` | `[NEED: origin task record]` | `[NEED: source file]` | open | `[NEED: which run fetched from origin]` |
| Local-cache traffic | `[NEED: tenant-a cache evidence]` | `[NEED: tenant-b cache evidence]` | `[NEED: cache task record]` | `[NEED: source file]` | open | `[NEED: which run used local cache]` |
| Remote-peer traffic | `[NEED: tenant-a peer evidence]` | `[NEED: tenant-b peer evidence]` | `[NEED: peer task record]` | `[NEED: source file]` | open | `[NEED: which run used a remote peer]` |
| Start timestamp | `[NEED: tenant-a start]` | `[NEED: tenant-b start]` | not applicable | `[NEED: source file]` | open | `[NEED: UTC start per run]` |
| End timestamp | `[NEED: tenant-a end]` | `[NEED: tenant-b end]` | not applicable | `[NEED: source file]` | open | `[NEED: UTC end per run]` |
| Checksum | `[NEED: tenant-a checksum]` | `[NEED: tenant-b checksum]` | not applicable | `[NEED: source file]` | open | `[NEED: matching checksum statement]` |
| Job security context | `[NEED: tenant-a securityContext]` | `[NEED: tenant-b securityContext]` | not applicable | `[NEED: source file]` | open | `[NEED: security context summary]` |
| hostPath absence | `[NEED: tenant-a manifest evidence]` | `[NEED: tenant-b manifest evidence]` | not applicable | `[NEED: source file]` | open | `[NEED: hostPath not present]` |
| hostNetwork absence | `[NEED: tenant-a manifest evidence]` | `[NEED: tenant-b manifest evidence]` | not applicable | `[NEED: source file]` | open | `[NEED: hostNetwork not present]` |
| Privileged-mode absence | `[NEED: tenant-a manifest evidence]` | `[NEED: tenant-b manifest evidence]` | not applicable | `[NEED: source file]` | open | `[NEED: privileged mode not present]` |
| Tested limitations | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: what was actually tested]` |
| Untested limitations | not applicable | not applicable | not applicable | `[NEED: source file]` | open | `[NEED: what was not tested]` |
