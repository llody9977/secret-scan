# Synthetic secret-scan scenarios

These fixtures are for local, defensive testing. They contain no live credential and make no network request.

- `leaked.env.tmpl` represents a hardcoded credential. The test script replaces its placeholder with a deterministic fictional value inside a temporary directory.
- `safe.env` represents the same setting as a runtime reference rather than a stored value.

The temporary value uses the repository-only `DEMO_…` format from `.gitleaks.toml`. It is never committed, cannot authenticate to a service, is fully redacted from scanner output, and is deleted when the test exits.
