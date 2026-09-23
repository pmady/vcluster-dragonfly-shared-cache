# Makefile for the vcluster-dragonfly-shared-cache scaffold.
#
# Targets use only standard Unix tools. shellcheck, yq, jq, and Python packages
# are not required.

SHELL := /bin/bash

.PHONY: help check capture-environment list-needs

help:
	@echo "Available targets:"
	@echo "  help                 Show this help message."
	@echo "  check                Run syntax, secret, style, and whitespace checks."
	@echo "  capture-environment  Capture non-sensitive environment info to evidence/raw."
	@echo "  list-needs           List every [NEED: ...] placeholder in the repository."

check:
	@echo "==> bash -n on shell scripts"
	@for f in scripts/*.sh; do echo "checking $$f"; bash -n "$$f"; done
	@echo "==> check-no-secrets"
	@bash scripts/check-no-secrets.sh .
	@echo "==> check-article-style"
	@bash scripts/check-article-style.sh article/draft.md
	@echo "==> git diff --check"
	@git diff --check
	@echo "all checks passed"

capture-environment:
	@bash scripts/capture-environment.sh evidence/raw/environment

list-needs:
	@echo "Outstanding [NEED: ...] placeholders:"
	@find . -type f \
		-not -path '*/.git/*' \
		-not -path '*/evidence/private/*' \
		-not -name Makefile \
		-exec grep -In -e '\[NEED:' {} /dev/null \; \
		|| true
	@echo "(scan complete)"
