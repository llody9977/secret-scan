# Secret scanning reduces credential-leak risk

![CI](https://github.com/llody9977/secret-scan/actions/workflows/ci.yml/badge.svg)
![Secret scan](https://github.com/llody9977/secret-scan/actions/workflows/gitleaks.yml/badge.svg)
![Pages](https://github.com/llody9977/secret-scan/actions/workflows/pages.yml/badge.svg)
![License](https://img.shields.io/github/license/llody9977/secret-scan)

A secret in source code can turn access to a repository into access to cloud accounts, databases, CI/CD, package registries, or production systems. The repository does not need to be public: compromised identities, developer clones, automation, backups, and integrations can all expose values stored with code.

The engineering rule is straightforward: **catch matching values before commit, enforce the decision again at the shared repository boundary, and store real credentials in a system designed for audit, rotation, expiry, and revocation.** A clean scan means only that the configured detectors did not report a match.

The recommended baseline here is **Gitleaks at pre-commit, pre-push, and central CI**. The CI scan runs on every push and pull request, again when a merge pushes the target branch, and daily; make its pull-request status required. If the repository is eligible, add **GitHub push protection at the hosted push boundary**. Add **TruffleHog as scheduled discovery or authorised incident triage** when its different detector results, wider-source reach, or provider checks justify the network, data-handling, latency, and licence trade-offs. This is not a recommendation to run every engine at every gate.

**[▶ Read the full illustrated guide →](https://llody9977.github.io/secret-scan/)**

The web guide covers:

- what qualifies as a secret and how exposure becomes business risk;
- the Uber, GitHub/npm, and CircleCI incidents;
- what to do when a secret reaches Git;
- where pre-commit, pre-push, push-protection, CI, scheduled, and artifact gates belong;
- what to evaluate before choosing a scanner;
- an 18-scenario Gitleaks/TruffleHog comparison plus GitHub's documented behavior and a hosted-test procedure;
- which tool belongs at which gate, and when a second engine is justified; and
- workload identity, secret managers, Kubernetes, CI/CD, and local-development storage patterns.

## Reproduce the test results

The baseline gate test uses Gitleaks 8.30.1 and a fictional value created only under `mktemp`:

```sh
make check
```

Expected result:

```text
hardcoded-synthetic: blocked (exit 1, findings 1)
runtime-reference: passed (exit 0, findings 0)
scanner: gitleaks 8.30.1; provider checks: disabled; reports: redacted
```

Under this configuration, the test blocks its controlled positive case and permits its runtime-reference negative case. It does not measure universal secret coverage or contact any credential provider.

For the like-for-like comparison, install Gitleaks 8.30.1 and TruffleHog 3.97.1, then run:

```sh
make compare
```

The corpus covers passwords, credential URLs, authorization headers, provider tokens, OAuth, paired cloud keys, service accounts, private and symmetric keys, webhook secrets, an internal format, encoding, and safe negatives. Gitleaks detected 12 of 15 positive scenarios; TruffleHog detected eight. These are configuration-specific regression results, not production accuracy rates or a universal ranking. The [web guide](https://llody9977.github.io/secret-scan/#comparison) explains each gap, GitHub's documented coverage, and the selection criteria.

## Enable the gates

```sh
make install-hooks
```

This installs a staged-content pre-commit scan and a full-history pre-push scan. Those hooks are per-clone and bypassable, so the GitHub workflow repeats the full-history scan on every push and pull request, on merge pushes, and daily. After hosting, make **Gitleaks full-history gate** a required pull-request status check. Keep **Comparison only — not a merge gate** optional; the scheduled TruffleHog workflow is a detective control, not a merge gate.

## Structure

- [`docs/`](docs/) — the GitHub Pages article and responsive styles.
- [`scripts/test-secret-scan.sh`](scripts/test-secret-scan.sh) — Gitleaks gate test.
- [`scripts/compare-secret-scanners.sh`](scripts/compare-secret-scanners.sh) — controlled Gitleaks/TruffleHog comparison.
- [`testdata/`](testdata/) — safe placeholder and runtime-reference fixtures.
- [`results/`](results/) — captured machine-readable results and the GitHub-hosted test procedure.
- [`.gitleaks.toml`](.gitleaks.toml) and [`.trufflehog.yml`](.trufflehog.yml) — built-ins plus equivalent fictional test rules.
- [`.github/workflows/`](.github/workflows/) — required-gate candidate, comparison run, scheduled discovery, CI, and Pages deployment.
- [`reviews/`](reviews/) — review record and durable content decisions.

## Security, scope, and licence

This repository is for educational and defensive use on systems you own or are explicitly authorised to test. It contains no live credential and makes no outbound provider checks. Report vulnerabilities privately through [`SECURITY.md`](SECURITY.md) and read [`DISCLAIMER.md`](DISCLAIMER.md) before adapting the demonstration.

Licensed under [Apache-2.0](LICENSE).
