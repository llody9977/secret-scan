# Secret scanning: control effectiveness and governance

![CI](https://github.com/llody9977/secret-scan/actions/workflows/ci.yml/badge.svg)
![CodeQL](https://github.com/llody9977/secret-scan/actions/workflows/codeql.yml/badge.svg)
![Secret scan](https://github.com/llody9977/secret-scan/actions/workflows/gitleaks.yml/badge.svg)
![Pages](https://github.com/llody9977/secret-scan/actions/workflows/pages.yml/badge.svg)
![License](https://img.shields.io/github/license/llody9977/secret-scan)

A scanner is only one part of a secret-scanning control. Effective protection also depends on where it runs, whether the organization can enforce it, how bypass and failures are governed, and whether findings lead to revocation and remediation.

**[Read the full GitHub Pages guide →](https://llody9977.github.io/secret-scan/)**

## Practical recommendation

- Use pre-commit and pre-push hooks for fast developer feedback; they are per-clone and bypassable, so they are not organization-wide enforcement.
- Enable host push protection for the supported patterns that must not reach the remote. Test the actual plan, pattern versions, service limits, and bypass policy.
- Require a portable CI scanner for merge policy and internal formats. In this repository that role belongs to **Gitleaks full-history gate**.
- Add TruffleHog as scheduled or wider-source discovery when its distinct detectors, source connectors, or approved provider checks close a named risk gap.

This is not a recommendation to run every engine at every gate.

## Hosted corpus result

The repository commits 16 fictional credential-shaped positives and three safe negatives under [`testdata/synthetic/`](testdata/synthetic/). No value was provider-issued; the private keys are newly generated untrusted test keys.

| Control | Observed result for this corpus | Assigned role here |
| --- | --- | --- |
| Gitleaks 8.30.1 | 13/16 positive scenarios reported; 3/3 negatives passed | Required main-branch status plus local feedback; admin enforcement remains disabled |
| TruffleHog 3.97.1 | 8/16 positive scenarios reported; 3/3 negatives passed | Non-blocking regression and scheduled discovery |
| GitHub hosted secret scanning | Blocked the added Mailchimp-shaped fixture at push; a `used_in_tests` bypass created [alert #1](https://github.com/llody9977/secret-scan/security/secret-scanning/1). The earlier 15 positive fixtures produced no host alert | First governed remote boundary for covered provider patterns; use eligible generic/custom patterns or portable CI for assigned residual formats |

These are per-scenario regression outcomes, not production accuracy rates. See the [GitHub Actions run](https://github.com/llody9977/secret-scan/actions/runs/32823251440), [machine-readable artifact](https://github.com/llody9977/secret-scan/actions/runs/32823251440/artifacts/9553923464), [durable result snapshot](results/scanner-comparison-results.json), [sanitized GitHub host result](results/github-secret-protection-results.json), and [direct GitHub alert](https://github.com/llody9977/secret-scan/security/secret-scanning/1).

The GitHub host test is the free public-repository configuration of a personal repository. Provider scanning and push protection are enabled. Non-provider generic patterns, validity checks, and custom patterns are unavailable or disabled here; eligible organization plans can add capabilities, but those configurations must be tested separately.

The production scans exclude only the intentional corpus path. The separate remote evaluation workflow copies and scans that directory explicitly, rejects unmanifested fixtures, asserts every scenario outcome, publishes a job summary, and uploads safe metadata. Raw TruffleHog matches remain ephemeral; Gitleaks reports must pass a full-redaction check.

## Re-run or extend the evaluation

After installing the pinned Gitleaks and TruffleHog versions:

```sh
make compare
```

To add an internal or provider format, add a non-issued fixture and update [`testdata/synthetic/manifest.json`](testdata/synthetic/manifest.json). The remote workflow will rerun on the same committed inputs. Review changes by scenario rather than treating the total count as a product score.

Key files:

- [`secret-scanning.md`](secret-scanning.md) — source article with references.
- [`docs/`](docs/) — full-width responsive GitHub Pages version.
- [`.github/workflows/scanner-comparison.yml`](.github/workflows/scanner-comparison.yml) — remote Gitleaks/TruffleHog evaluation.
- [`.github/workflows/gitleaks.yml`](.github/workflows/gitleaks.yml) — centrally required full-history gate.
- [`results/`](results/) — remote result snapshots, conditions, and limitations.

Apache-2.0. Defensive testing only; use systems you own or are authorized to assess.
