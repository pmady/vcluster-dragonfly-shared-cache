# Evidence

This directory holds the raw and processed evidence that supports every factual
claim in the article. The project is evidence first: no result is stated in the
article until a file here supports it.

## Layout

- `evidence/raw` holds unedited command output, logs, and exports exactly as
  they were produced by the lab. Retain raw logs when it is safe to do so.
- `evidence/processed` holds sanitized tables, summaries, and derived values
  that are safe to publish. Each processed file should point back to the raw
  file it was built from.
- `evidence/private` must never be committed. Use it for material that has not
  yet been reviewed for redaction, or that cannot be published at all. This
  directory is listed in `.gitignore`.

## Rules

- Every publication claim must point to a specific evidence file. A claim with
  no evidence file stays marked as `[NEED: ...]` in the article and in
  `docs/evidence-matrix.md`.
- Screenshots must show enough context to be meaningful, including the command
  that produced the result when that applies.
- Every screenshot requires a redaction check before it moves out of
  `evidence/private`. Confirm that node names, addresses, tokens, and any other
  sensitive detail have been removed or masked.
- Run `scripts/check-no-secrets.sh` before staging any evidence file.

## Naming

Use descriptive, sortable names that identify the run and the observation, for
example:

```
evidence/raw/<run-id>-tenant-a-cold-pull.txt
evidence/raw/<run-id>-dragonfly-manager-logs.txt
evidence/processed/<run-id>-evidence-summary.md
```

The exact run identifier comes from `evidence/run-manifest.example.yaml` once a
real run exists.

## v0.1 evidence checklist

A v0.1 run is complete when these files exist and have been reviewed. Nothing
else is required for the first contribution.

- [ ] Host Dragonfly component listing (manager, scheduler, client pods).
- [ ] tenant-a context output showing its own API server.
- [ ] tenant-b context output showing its own API server.
- [ ] Final tenant Job YAML as applied.
- [ ] tenant-a logs.
- [ ] tenant-b logs.
- [ ] Dragonfly evidence of the origin download.
- [ ] Dragonfly evidence of a local-cache hit or a remote-peer transfer.
- [ ] Host-node placement of both tenant Jobs.
- [ ] Matching SHA-256 checksums from both tenants.

`scripts/collect-evidence.sh` gathers most of these into `evidence/raw`. Reading
the Dragonfly logs to tell origin, local cache, and remote peer apart is a manual
step. Do not mark the cache or peer item done without a log line or metric that
names the source of the bytes.
