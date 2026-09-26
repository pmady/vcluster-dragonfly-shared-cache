# Evidence Matrix

Every claim below is backed by a file under `evidence/`. Result classification:
remote-peer delivery. Run date: 2026-09-26 (UTC).

## The five claims

| Claim | Evidence | File | Status |
| --- | --- | --- | --- |
| Dragonfly is platform-owned | Scheduler, seed peers, and client DaemonSet run on the host; client on hostNetwork; manager-less mode | evidence/raw/host-components.txt | ready |
| Tenants use separate vClusters | Two contexts, each with its own namespaces; tenant API server v1.36.0 vs host v1.37.0 | evidence/raw/tenant-contexts.txt | ready |
| Tenant Jobs lack node-level privileges | Job runs runAsNonRoot, drops all capabilities, no hostPath/hostNetwork/hostPID/hostIPC/privileged | workloads/model-pull-job.yaml, evidence/raw/tenant-a-run.txt | ready |
| Tenant B did not repeat the origin path | Same task_id; tenant-b collected pieces from peer parents; control-plane client sent cached pieces to tenant-b's node; no origin back-to-source | evidence/raw/tenant-b-dfdaemon.log, evidence/raw/tenant-a-dfdaemon.log | ready |
| Both tenants received the same artifact | Identical SHA-256 5e3f1108...f0063 and size 267954768 | evidence/raw/tenant-a-run.txt, evidence/raw/tenant-b-run.txt | ready |

## Key facts

| Field | Value |
| --- | --- |
| Host cluster | disposable kind, Kubernetes v1.37.0, 3 nodes |
| Dragonfly | chart 1.8.5, app 2.5.2, client v1.5.5, manager-less |
| vCluster | CLI 0.37.2, tenant server v1.36.0 |
| Model | distilbert-base-uncased @ 12040accade4e8a0f71eabdb258fecc2e7e948be, model.safetensors, 267954768 bytes |
| Dragonfly task_id | c8dca2997b92a8a1c371703fb29ab83a2148a18213ed830f1c4fb944d53eb5d7 |
| tenant-a node / source | dragonfly-host-control-plane / origin via seed peer |
| tenant-b node / source | dragonfly-host-worker2 / remote peer (control-plane client + seed) |

## Not tested

GPU, NetworkPolicy, cache eviction, cache pressure, private or gated models,
failure injection, hostile-tenant isolation. Wall-clock timing is observational,
not a benchmark.
