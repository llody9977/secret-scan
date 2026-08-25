# Controlled test results

[`scanner-comparison-results.json`](scanner-comparison-results.json) records a
run made on 2026-08-25 with Gitleaks 8.30.1 and TruffleHog 3.97.1. The corpus
contains 15 credential-shaped positive scenarios and three safe negatives:

| Credential shape | Gitleaks | TruffleHog |
| --- | --- | --- |
| Custom internal token | Detected | Detected |
| Username/password assignment | Detected | Missed |
| PostgreSQL credential URL | Missed | Detected |
| HTTP Basic credential | Missed | Missed |
| Bearer JWT | Detected | Missed |
| GitHub PAT-shaped token | Missed | Detected |
| OAuth client secret | Detected | Missed |
| AWS pair in one file | Detected | Detected |
| AWS pair split across files | Detected one generic value | Missed |
| Service-account private key | Detected | Detected |
| RSA private key | Detected | Detected |
| OpenSSH private key | Detected | Detected |
| Symmetric encryption key | Detected | Missed |
| Webhook signing secret | Detected | Missed |
| Base64-encoded internal token | Detected | Detected |
| Runtime reference | Passed | Passed |
| Placeholder | Passed | Passed |
| SSH public key | Passed | Passed |

Gitleaks detected 12 of the 15 positives; TruffleHog detected eight. These
fractions are not production accuracy rates or total-coverage scores. The
scenarios were chosen to represent different technical shapes, not sampled
from production, and the Base64 scenario produces two Gitleaks signals for one
credential representation.

Reproduce the run with `./scripts/compare-secret-scanners.sh --json`.
Credential-shaped inputs are created under `mktemp`, are not provider-issued,
and are deleted on exit. Outbound provider checks are disabled. Gitleaks reports
are redacted; TruffleHog raw JSON remains temporary because it can contain
matched values.

[`local-scan-results.json`](local-scan-results.json) records the smaller
Gitleaks-only positive/negative run used by the required merge gate.

GitHub Secret Protection is host-native, so a local CLI run cannot measure its
push behavior. [`github-secret-protection-test-procedure.md`](github-secret-protection-test-procedure.md)
maps the same credential classes to GitHub's documented patterns and explains
how to record hosted results in an eligible disposable repository.

The captured results describe only the pinned versions, configurations, and
scenarios listed here. They do not measure false-positive rates in production,
credential validity, source-connector breadth, performance on a large history,
or the absence of secrets.
