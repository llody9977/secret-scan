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

The repository commits 15 fictional credential-shaped positives and three safe negatives under [`testdata/synthetic/`](testdata/synthetic/). No value was provider-issued; the private keys are newly generated untrusted test keys.

| Control | Observed result for this corpus | Assigned role here |
| --- | --- | --- |
| Gitleaks 8.30.1 | 12/15 positive scenarios reported; 3/3 negatives passed | Required main-branch status plus local feedback; admin enforcement remains disabled |
| TruffleHog 3.97.1 | 8/15 positive scenarios reported; 3/3 negatives passed | Non-blocking regression and scheduled discovery |
| GitHub Secret Protection | Corpus push accepted without a block; sanitized alert export returned no corpus alert; repository custom patterns were unavailable | Host prevention for supported patterns, with a portable CI layer for residual gaps |

These are per-scenario regression outcomes, not production accuracy rates. See the [GitHub Actions run](https://github.com/llody9977/secret-scan/actions/runs/32818011678), [machine-readable artifact](https://github.com/llody9977/secret-scan/actions/runs/32818011678/artifacts/9552099737), [durable result snapshot](results/scanner-comparison-results.json), and [GitHub host result](results/github-secret-protection-results.json).

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
