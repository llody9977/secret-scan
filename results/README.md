# Remote scanner results

The durable snapshots in this directory contain detector metadata and remote
provenance, never a matched value.

## Gitleaks and TruffleHog

[`scanner-comparison-results.json`](scanner-comparison-results.json) was produced
by [GitHub Actions run `32823251440`](https://github.com/llody9977/secret-scan/actions/runs/32823251440)
from commit `bcc467fc7e4d9a4db539acd6dd00e34a5f4dc1a7`. The original
[artifact `9553923464`](https://github.com/llody9977/secret-scan/actions/runs/32823251440/artifacts/9553923464)
expires after the repository's artifact-retention period; the checked-in JSON
retains the result, runner, commit, manifest digest, versions, exit codes, and
detector names.

The checked-in manifest contains 16 fictional positive scenarios and three safe
negatives. Gitleaks reported 13 positive scenarios and TruffleHog reported eight;
both passed all three negatives. Those counts are regression outcomes for the
selected scenarios and configurations, not production accuracy estimates.

The production [Gitleaks history gate run](https://github.com/llody9977/secret-scan/actions/runs/32823251410)
also passed. Its repository configuration excludes only `testdata/synthetic/`,
while the evaluation job explicitly copies and scans that corpus.

## GitHub Secret Protection

[`github-secret-protection-results.json`](github-secret-protection-results.json)
records the separate host observation. GitHub rejected commit `bcc467f` at the
push boundary and classified the new checked-in fixture as a Mailchimp API Key.
Using GitHub's **used in tests** bypass allowed the same commit on retry and
created [alert #1](https://github.com/llody9977/secret-scan/security/secret-scanning/1),
which records `mailchimp_api_key`, the commit location, bypass metadata, and the
`used_in_tests` resolution. The result file deliberately omits the matched value.

This was a public personal repository using GitHub's free public-repository
scanning. The earlier 15 non-issued positives produced no host alert, and this
configuration could not enable non-provider generic or custom patterns.
Eligible organization plans can add generic, AI-detected, validity, and custom
capabilities; those settings were not exercised and should be tested on the
target repository and plan.

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
