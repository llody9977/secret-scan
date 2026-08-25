# Remote scanner results

The durable snapshots in this directory contain detector metadata and remote
provenance, never a matched value.

## Gitleaks and TruffleHog

[`scanner-comparison-results.json`](scanner-comparison-results.json) was produced
by [GitHub Actions run `32818011678`](https://github.com/llody9977/secret-scan/actions/runs/32818011678)
from commit `00feb11a9db6af732a82ce769dd0334af9a7629e`. The original
[artifact `9552099737`](https://github.com/llody9977/secret-scan/actions/runs/32818011678/artifacts/9552099737)
expires after the repository's artifact-retention period; the checked-in JSON
retains the result, runner, commit, manifest digest, versions, exit codes, and
detector names.

The checked-in manifest contains 15 fictional positive scenarios and three safe
negatives. Gitleaks reported 12 positive scenarios and TruffleHog reported eight;
both passed all three negatives. Those counts are regression outcomes for the
selected scenarios and configurations, not production accuracy estimates.

The production [Gitleaks history gate run](https://github.com/llody9977/secret-scan/actions/runs/32818011673)
also passed. Its repository configuration excludes only `testdata/synthetic/`,
while the evaluation job explicitly copies and scans that corpus.

## GitHub Secret Protection

[`github-secret-protection-results.json`](github-secret-protection-results.json)
records the separate host observation. Secret scanning and push protection were
enabled. GitHub accepted the corpus push without offering a bypass; the
sanitized alert API export returned no corpus alert at the recorded query time.
The repository custom-pattern endpoint returned “feature not available.”

That result does not establish that GitHub misses real provider-issued values.
The corpus is intentionally non-issued, provider token versions and validity
logic can matter, not every alert pattern supports push protection, and custom
patterns depend on repository type and plan.

## Safety and repeatability

- [`../testdata/synthetic/manifest.json`](../testdata/synthetic/manifest.json) is
  the source of truth for scenario targets and expected CLI outcomes.
- Provider checks were disabled.
- Gitleaks reports used full redaction and passed a redaction assertion.
- Raw TruffleHog JSON was deleted with the ephemeral work directory.
- The host export omits GitHub's `secret` field and retains only safe settings,
  counts, feature availability, and alert/location metadata.

[`local-scan-results.json`](local-scan-results.json) remains the smaller local
positive/negative test used to exercise the required Gitleaks gate. It is not
the source for the cross-tool comparison.
