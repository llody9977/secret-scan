# Review record: representative credential matrix and gate policy

## Status and baseline

- Status: Ready for follow-up check-in; initial hosted GitHub checks passed and the product test remains follow-up
- Review date: 2026-08-25
- Reviewer: Codex
- Model / effort: `gpt-5` / `xhigh`
- Branch: `main`
- Commit: `256446593051d22c01ea593919526e621333d1e6`
- Worktree: Dirty; `README.md` adds the CodeQL badge after its first successful hosted run, `reviews/REVIEW_STATE.json` records the completed passes, and the review router recognizes the current GPT-5 reviewer family
- Review state ID: `5412fbbe66650342d42f2372b513a8d853e77fb4a1fb32afb43894cc585a2bd4`
- Scoped content fingerprint: `ab5c0807dc7fd2f0b6929e6d93b2d07f2d299dab1fbf10e051048c2b7396fc02`
- State capture: `python3 scripts/capture_review_state.py` over the 13 scopes listed below
- Pass state: Recorded in `reviews/REVIEW_STATE.json` after the root commit supplied a Git `HEAD`.

This review supersedes the earlier same-day record because feedback materially
expanded the corpus, added GitHub's documented behavior and host-test procedure,
clarified TruffleHog source breadth, added custom-format guidance, and changed
the central workflow triggers. The check-in refresh also includes the CodeQL
and dependency-review workflows required by the repository standard.

## Frozen review scope

1. `README.md`
2. `secret-scanning.md`
3. `docs/`
4. `.github/workflows/`
5. `.github/dependabot.yml`
6. `.gitleaks.toml`
7. `.trufflehog.yml`
8. `.pre-commit-config.yaml`
9. `Makefile`
10. `scripts/`
11. `testdata/`
12. `results/`
13. `reviews/CONTENT_DECISIONS.yml`

Remote settings, hosted Actions results, branch rules, Secret Protection
eligibility, push-protection behavior, and deployed Pages remain outside the
local workspace.

## Review passes

| Pass | Verdict | Evidence |
| --- | --- | --- |
| Factual correctness | Clean | GitHub patterns, scope limits, custom-pattern behavior, plan caveats, Gitleaks decoding/custom rules, and TruffleHog source/custom-detector behavior were checked against current primary sources. |
| Adversarial claims | Clean | Scenario fractions are explicitly not accuracy rates; GitHub documented behavior is separated from the pending hosted result; “broad discovery” is defined as source reach and optional provider checks. |
| Terminology and taxonomy | Clean | Secret classes, alerting, push blocking, local detection, host behavior, preventive gates, merge gates, and detective scans remain distinct. |
| Cross-format consistency | Clean | README, Markdown article, web page, script, JSON, result README, workflow triggers, and required-status name agree. |
| Topic completeness | Clean | Tool criteria precede comparison; password, token, service-account, key, internal-format, encoding, custom-pattern, limitation, gate, response, and storage topics are covered. |
| Argument integrity | Clean | Requirements lead to per-shape results, capability distinctions, limitations, and a risk-based gate choice rather than “run all tools.” |
| Executable demonstration | Clean | The pinned engines ran against 15 positive and three negative temporary scenarios; exact outcomes are asserted and the regenerated JSON matched. |
| Static web structure | Clean | HTML anchors/assets and CSS braces passed the repository checker; the page contains the complete matrix and revised decision map. |
| Decision reconciliation | Clean | CD-0001, CD-0002, CD-0004, and CD-0006 were reaffirmed; CD-0005 was superseded by CD-0007. |
| Repository and workflow security | Clean | CodeQL and dependency-review use current immutable action commits on Node 24; all workflows declare least-privilege permissions and no workflow uses `pull_request_target`. |

## Decision ledger

| Question | Reviewed conclusion | Supporting artifact |
| --- | --- | --- |
| Is every tool required at every gate? | No. Gitleaks is the scoped portable baseline, GitHub push protection is the hosted-boundary control when eligible, and TruffleHog is added for a named detector/source/provider-check gap. | README, article, web recommendation, CD-0007 |
| Why is TruffleHog “broad”? | Its supported sources and optional provider checks extend beyond a checkout. The term does not assert superior detection for every file shape. | Capability comparison and primary TruffleHog documentation |
| Is GitHub part of the effectiveness matrix? | Yes, as documented pattern and limitation behavior plus a separate remote-test column. No local GitHub result is invented. | Web/article matrix and hosted-test procedure |
| How are internal formats covered? | All three tools' custom-pattern facilities are described, and the fictional internal format is tested in plaintext and encoded form for the local engines. | `.gitleaks.toml`, `.trufflehog.yml`, harness, custom-format section |
| Where is policy enforced? | Local hooks provide feedback. Central Gitleaks runs on push, pull request, merge push, daily, and manual dispatch; the PR status is the required candidate. | `.github/workflows/gitleaks.yml` and gate table |
| What is the comparison workflow for? | Regression and product evaluation only; its job remains `Comparison only — not a merge gate`. | `.github/workflows/scanner-comparison.yml` |

## Executable result

Measured locally on 2026-08-25:

- 15 credential-shaped positive scenarios and three safe negatives;
- Gitleaks 8.30.1 detected 12 positives and passed all three negatives;
- TruffleHog 3.97.1 detected eight positives and passed all three negatives;
- both missed the HTTP Basic scenario;
- Gitleaks missed the PostgreSQL URL and GitHub PAT-shaped scenarios;
- TruffleHog missed the password assignment, JWT, OAuth client secret, split
  AWS pair, symmetric key, and webhook scenarios; and
- the complete per-scenario detectors, counts, and exit codes are stored in
  `results/scanner-comparison-results.json`.

Safety properties checked:

- all credential-shaped inputs were assembled only under `mktemp` and deleted
  on exit;
- no input was provider-issued and outbound provider checks remained disabled;
- Gitleaks reports were redacted and checked for every materialized fixture;
- TruffleHog raw JSON remained temporary; and
- the persisted result contains metadata only.

## Mechanical checks

| Check | Result | Boundary |
| --- | --- | --- |
| `bash -n scripts/*.sh` | Pass | Shell parsing only |
| `shellcheck scripts/*.sh` | Pass | Static shell analysis |
| `actionlint` | Pass | Workflow structure, not hosted execution |
| `pre-commit validate-config .pre-commit-config.yaml` | Pass | Configuration schema, not installation in another clone |
| `python3 scripts/check-site.py` | Pass: 14 IDs, 43 links, local assets present | Static page structure, not external-link or browser testing |
| `python3 scripts/verify_content_decisions.py` | Pass: seven decisions | Registry integrity, not independent correctness |
| Ruby YAML parse | Pass for every workflow and pre-commit config | Syntax only |
| JSON parse | Pass for both result files and decision registry | Syntax only |
| `make check` | Pass; expected positive blocked, negative passed, working tree clean | Gitleaks baseline only |
| Regenerated comparison diff | Exact match | Pinned versions and current platform only |
| Temporary root-commit Gitleaks scan | Clean | Local simulation, not GitHub Actions |
| Temporary root-commit TruffleHog scan | Zero findings | Local simulation with provider checks disabled |
| Repository Gitleaks scan | Zero findings | Configured local detector coverage only |
| Repository TruffleHog scan | Zero findings | Filesystem scan with provider checks disabled |
| GitHub Action reference check | All workflow actions use immutable commit SHAs | Pinning does not establish action correctness |
| Action runtime inspection | Checkout v7, CodeQL v4, and dependency-review v5 report Node 24 | Current upstream manifests on 2026-08-25 |
| `pre-commit run --all-files` | Pass: staged Gitleaks, private-key, file-size, merge-conflict, EOF, and whitespace hooks | Local staged state |
| Social-preview inspection | Pass: 1200×630 JPEG is legible and 108,034 bytes | Visual and size review of the committed asset |
| Hosted CI | Pass: `Shell checks` and `Static site checks` | GitHub Actions run `32815702105` on the root commit |
| Hosted secret scan | Pass: `Gitleaks full-history gate` | GitHub Actions run `32815702102` on the root commit |
| Hosted CodeQL | Pass: `Analyze (python)` | GitHub Actions run `32815702047` on the root commit |
| Hosted scanner comparison | Pass: `Comparison only — not a merge gate` | GitHub Actions run `32815701980` on the root commit |
| Pages publication | Pass: deployment completed and the public URL returned HTTP 200 | GitHub Actions run `32815702018`; HTTP reachability is not a complete browser review |

The first staged hook run exposed two check-in defects and remediated both: the
Gitleaks hook now disables filename passing so its staged Git command receives
no spurious path arguments, and the social preview is a 108 KB JPEG rather than
a 1.15 MB PNG. The unchanged 500 KB guard now catches future oversized assets.

## Limitations and remote follow-up

- GitHub Secret Protection must be run in an eligible disposable repository
  using `results/github-secret-protection-test-procedure.md`.
- The local scenario fractions are regression counts, not estimates of
  production accuracy or false-positive rates.
- Large-history timing, collaboration/object sources, archives, images,
  provider-check latency, and production triage cost were not measured.
- Browser rendering was not re-run for the badge-only revision; the badge does
  not alter the Pages artifact, whose initial deployment completed and returned
  HTTP 200.
- Required-status policy is applied after the follow-up commit so its contexts
  reference job names that have appeared in hosted runs.

## Closure

The repository now supports a conditional selection: start from the secret
inventory and gate requirements, use individual scenario results rather than a
universal score, add host-native or second-engine coverage only for material
residual gaps, and keep central enforcement even when local hooks are absent.
