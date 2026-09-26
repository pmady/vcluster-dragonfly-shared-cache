# Results

Run date: 2026-09-26 (UTC). One complete two-tenant run on a disposable local
kind cluster. Result classification: **remote-peer delivery**.

## Result table

| Observation | tenant-a | tenant-b | Evidence file |
| --- | --- | --- | --- |
| vCluster context | vcluster_tenant-a_tenant-a_kind-dragonfly-host | vcluster_tenant-b_tenant-b_kind-dragonfly-host | evidence/raw/tenant-contexts.txt |
| Tenant API server version | v1.36.0 | v1.36.0 | evidence/raw/tenant-contexts.txt |
| Host worker (node) | dragonfly-host-control-plane | dragonfly-host-worker2 | evidence/raw/tenant-a-run.txt, tenant-b-run.txt |
| Model repository | distilbert-base-uncased | distilbert-base-uncased | versions.env |
| Model revision | 12040accade4e8a0f71eabdb258fecc2e7e948be | 12040accade4e8a0f71eabdb258fecc2e7e948be | versions.env |
| Model file | model.safetensors | model.safetensors | versions.env |
| Artifact size (bytes) | 267954768 | 267954768 | evidence/raw/tenant-a-run.txt, tenant-b-run.txt |
| Dragonfly task_id | c8dca2997b92a8a1c371703fb29ab83a2148a18213ed830f1c4fb944d53eb5d7 | c8dca2997b92a8a1c371703fb29ab83a2148a18213ed830f1c4fb944d53eb5d7 | evidence/raw/tenant-a-dfdaemon.log, tenant-b-dfdaemon.log |
| Start (UTC) | 2026-09-26T06:56:49Z | 2026-09-26T07:00:15Z | evidence/raw/tenant-a-run.txt, tenant-b-run.txt |
| End (UTC) | 2026-09-26T06:57:00Z | 2026-09-26T07:00:18Z | evidence/raw/tenant-a-run.txt, tenant-b-run.txt |
| Transfer source | origin (cold; served via the seed peer) | remote peer (control-plane peer + seed peer) | evidence/raw/tenant-a-dfdaemon.log, tenant-b-dfdaemon.log |
| SHA-256 | 5e3f1108e3cb34ee048634875d8482665b65ac713291a7e32396fb18f6ff0063 | 5e3f1108e3cb34ee048634875d8482665b65ac713291a7e32396fb18f6ff0063 | evidence/raw/tenant-a-run.txt, tenant-b-run.txt |

## How the transfer source was classified

Both tenants requested the same artifact through the platform-owned Dragonfly
HTTP proxy on their local node (reached via the downward-API host IP on port
4001). Dragonfly assigned both requests the same task_id
`c8dca2997b92a8a1c371703fb29ab83a2148a18213ed830f1c4fb944d53eb5d7`, because the
proxy filters the signed Xet query parameters, leaving a stable content path as
the cache key.

- tenant-a (cold): the scheduler's `normal task response` listed only the seed
  peer (`dragonfly-seed-client-0`) as the source, and tenant-a assembled the 64
  pieces from it. On a cold cache the seed peer is the component that fetches from
  the origin, so this is the origin path for the first request. The seed peer's
  own back-to-source log line to `us.aws.cdn.hf.co` was not captured in this
  excerpt, and total origin bytes were not measured; the origin classification for
  tenant-a is an inference from the cold cache plus the scheduler assigning the
  seed as source.
- tenant-b (second, on a different worker): the scheduler's `normal task
  response` listed two parents, the control-plane client (where tenant-a ran)
  and the seed peer. tenant-b collected all 64 pieces from those parents. There
  is no origin back-to-source for tenant-b. On the control-plane client, the
  log line `all existing pieces have been sent ... remote_host_id=<worker2>`
  records that node serving its cached pieces to tenant-b's node.

That combination (same task_id, parents are peers on other nodes, no origin
back-to-source, and an explicit peer upload) is remote-peer delivery.

## What the result does not show

- Wall-clock times (tenant-a about 11s, tenant-b about 3s) are observations on a
  laptop-class lab, not a benchmark.
- No security boundary against a hostile tenant was tested.
- No GPU, NetworkPolicy, eviction, cache-pressure, private-model, or
  failure-injection testing was done.
- The control-plane was cordoned only to force tenant-b onto a different worker
  so the reuse would cross nodes; it was uncordoned immediately after.
