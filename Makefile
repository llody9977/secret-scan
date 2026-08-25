.PHONY: check compare demo install-hooks scan scan-working-tree

check: scan-working-tree demo

compare:
	./scripts/compare-secret-scanners.sh

demo:
	./scripts/test-secret-scan.sh

scan:
	gitleaks git --config .gitleaks.toml --max-decode-depth=1 --no-banner --redact=100 --verbose .

scan-working-tree:
	gitleaks dir --config .gitleaks.toml --max-decode-depth=1 --no-banner --redact=100 --verbose .

install-hooks:
	pre-commit install --install-hooks
	pre-commit install --hook-type pre-push
