# Contributing

This repository is evidence first. Contributions add reproducible lab evidence
or improve the tutorial. They do not add unproven result claims.

## Evidence-first rules

- Do not add a factual value unless an evidence file supports it. Until then,
  use `[NEED: precise description]`.
- Do not claim reuse from a peer or a cache without an exact Dragonfly log,
  metric, task record, or trace.
- Keep origin download, local node cache, and remote peer transfer separate in
  every claim.

## How to add lab evidence

1. Run the lab step and capture the output.
2. Save unedited output under `evidence/raw`.
3. Save sanitized summaries and tables under `evidence/processed`.
4. Keep anything unreviewed under `evidence/private`, which is never committed.
5. Update the matching row in `docs/evidence-matrix.md` and point it at the
   evidence file.

## How to name evidence files

Use sortable, descriptive names that identify the run and the observation:

```
evidence/raw/<run-id>-<step>.txt
evidence/processed/<run-id>-<summary>.md
```

The run identifier comes from a filled copy of
`evidence/run-manifest.example.yaml`.

## How to document commands

- Record the exact command and the tool version.
- Do not paraphrase a command you did not run.
- Do not capture or print credentials. Use `scripts/capture-environment.sh`,
  which avoids commands that display tokens or certificate data.

## How to propose result wording

- Put proposed wording in the `Publication wording` column of the evidence
  matrix.
- Wording may be published only when its row reaches status ready.
- Follow the article style rules below.

## Article style rules

- Do not use em dash or en dash characters in article files. Use commas, colons,
  parentheses, or normal hyphens.
- Do not use these marketing words: seamless, robust, powerful, game-changing,
  leverage, best-in-class, unlock, effortless.
- Do not describe vCluster or Dragonfly as the best or only option. Mention a
  per-node registry mirror and a shared PVC cache as alternatives.
- Do not call Pavan Madduri a maintainer. Use contributor only.
- Use first person in the article body. Use third person only in the author bio.
- Run `scripts/check-article-style.sh` before staging article changes.

## Secret handling

- Never commit access tokens, credentials, kubeconfig certificate data,
  enterprise instance identifiers, or any other private material.
- Run `scripts/check-no-secrets.sh` before staging.
- Review every screenshot for redaction before it leaves `evidence/private`.

## Pull request expectations

- Fill out `.github/pull_request_template.md`.
- Confirm `make check` passes.
- Confirm no fabricated results and no secrets.
- Keep `[NEED: ...]` placeholders for facts that are still unknown.
- Do not add a software license. That is an owner decision.
