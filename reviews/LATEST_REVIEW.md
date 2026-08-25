# Review record: explicit GitHub-hosted secret alert

## Status and baseline

- Status: Complete with no open required findings
- Review date: 2026-08-25
- Reviewer: Codex
- Model / effort: `gpt-5` / `xhigh`
- Branch: `github-hosted-alert-test`
- Baseline commit: `bcc467fc7e4d9a4db539acd6dd00e34a5f4dc1a7`
- Worktree: Dirty by design; the reviewed change set adds the hosted test result, refreshed remote CLI result, public prose, decision record, and this review state
- Review state ID: `75dc9b0b9282ab15acb09bc4cc183169afeba85cfdce08916ca375a1d1ae9179`
- Scoped content fingerprint: `f3213ed981443063f7a39acb0d5f10f07a4a4038d97593de86164716f135ddb6`
- State capture: `python3 scripts/capture_review_state.py` over the 13 scopes below; 54 files
- Pass routing: `python3 scripts/review_passes.py --model gpt-5 --effort xhigh --json`
- Pass recording: ten changed-input passes recorded clean; unchanged visual/style inputs retained their current clean result

The earlier review remains historical only. The new provider-shaped fixture,
GitHub push behavior, alert, corpus result, public comparison, and decision record
changed, so every affected pass reran. The router reports no pass still due.

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

External inputs were checked separately: Actions runs `32823251410` and
`32823251440`, artifact `9553923464`, GitHub alert `1`, the alert-location API,
repository secret-scanning settings, custom-pattern availability, and `main`
branch protection.

## Review passes

| Pass | Router decision | Verdict | Review basis |
| --- | --- | --- | --- |
| Factual correctness | Run: inputs changed | Clean | GitHub's remote rejection, alert API, alert UI, Actions metadata, checked-in results, and current product references agree. |
| Source authority | Run: citations changed | Clean | New feature and plan claims cite current GitHub documentation; direct repository behavior comes from GitHub's push, alert, and Actions surfaces. |
| Adversarial claims | Run: prose changed | Clean | One provider-pattern finding is not generalized; prior misses, free-tier boundary, disabled checks, and untested paid capabilities are adjacent. |
| Terminology and taxonomy | Run: prose changed | Clean | Provider patterns, generic patterns, custom patterns, validity, push protection, CI detection, and discovery remain distinct. |
| Cross-format consistency | Run: prose/code/metadata changed | Clean | Manifest, remote JSON, host JSON, README, Markdown, HTML, run links, alert link, counts, versions, and settings agree. |
| Visual content | Cached: visual/style/code inputs unchanged | Clean | Existing full-width responsive CSS and social visual were unchanged; the current method-version result remains applicable. |
| Cross-page consistency | Run: prose/metadata changed | Clean | README remains a summary; Pages and the Markdown article contain the same per-tool results, limits, and control assignment. |
| Topic completeness | Run: prose changed | Clean | The existing definition, business risk, incidents, response, storage, evaluation, custom formats, gates, governance, and operations remain present. |
| Argument integrity | Run: prose changed | Clean | Criteria still precede comparison; actual host and CLI results lead to a conditional stack, not a product-count recommendation. |
| Executable demonstration | Run: code/prose changed | Clean | Both pinned engines reran all 19 manifest scenarios locally and on Actions; manifest coverage and redaction guards passed. |
| Decision reconciliation | Run: register changed | Clean | CD-0009 supersedes CD-0008 and records the new hosted result, free-tier boundary, direct alert, and invalidation conditions. |

Always-run tier:

| Check | Result | Boundary |
| --- | --- | --- |
| Mechanical validation | Pass | Syntax, static structure, configuration parsing, JSON shape, repository scans, and links; not production accuracy. |
| Guard regression | Pass | Positive/negative Gitleaks test, full redaction, manifest outcome assertions, exact corpus exclusions, and site guards still fire. |
| Residual exhaustion | Pass | The manifest-coverage fault was re-injected and rejected; the temporary file was removed and the full comparison reran. |

## Material-claim ledger

| Claim | Classification | Source or run | Result |
| --- | --- | --- | --- |
| GitHub blocked the checked-in Mailchimp-shaped fixture at the push boundary. | Host result | Remote rejection for commit `bcc467f` | GitHub named Mailchimp API Key and `testdata/synthetic/positive/mailchimp-api-key.env:2`. |
| The test bypass created a repository secret-scanning alert. | Host result | Alert `1` and alert API | `mailchimp_api_key`, `push_protection_bypassed: true`, state `resolved`, resolution `used_in_tests`, location at commit `bcc467f`. |
| The public personal-repository configuration could not enable non-provider or custom patterns. | Feature/configuration boundary | Repository settings and custom-pattern endpoint | Non-provider patterns disabled after an enable attempt; custom endpoint returned HTTP 404; eligible-plan behavior is cited but not treated as observed. |
| Gitleaks reported 13/16 and TruffleHog 8/16. | Test result | Run `32823251440`, artifact `9553923464`, digest-matched JSON | Exact match; both passed three negatives; Mailchimp was Gitleaks-only among the CLI configurations. |
| GitHub push protection is the earliest shared preventive boundary for its covered patterns. | Control design | Actual block sequence plus Git/CI sequence | Supported; CI remains necessary for residual and internal formats. |
| TruffleHog is broad in source reach and optional provider checks, not necessarily file-shape detection. | Product comparison | TruffleHog documentation and corpus counterexamples | Correctly bounded. |
| `Gitleaks full-history gate` is required on `main`, but administrators are not enforced. | Repository governance | Live branch-protection response | Correct and disclosed. |

## Argument integrity

**Thesis as stated:** Secret scanning should be designed as a governable control
system in which detection capability, timing, enforcement, reliable operation,
bypass governance, and incident response determine practical effectiveness.

**Thesis as supported:** Primary sources, the remote Actions corpus run, the
direct GitHub push-protection block and alert, and repository controls support a
conditional layered design using local feedback, host prevention for covered
patterns, required portable merge policy, and scoped discovery for residual
gaps.

Gap: none.

Dismissed candidates:

- Alert `1` was not converted into a GitHub accuracy rate or universal provider-coverage claim.
- The earlier 15 unreported fixtures were not used to claim that eligible organization generic or custom features would miss them.
- The CLI scenario fractions were not used as production accuracy rates or a universal ranking.
- The free public-repository result was separated from untested eligible-plan generic, AI, validity, and custom capabilities.
- Local hooks were not treated as central enforcement, TruffleHog source breadth was not treated as detector superiority, and the required CI status was not called bypass-proof.

## Cross-format and visual ledger

| Concept | Representations checked | Result |
| --- | --- | --- |
| Corpus size and outcomes | Manifest, local script, Actions JSON, README, Markdown, HTML | 16 positives, three negatives, 13 Gitleaks detections, eight TruffleHog detections, three negatives passed by both. |
| GitHub host result | Push, API/settings, alert UI, host JSON, README, Markdown, HTML | Initial block, Mailchimp type, location, test bypass, resolved alert `1`, validity unknown, and no copied match in result metadata. |
| Plan boundary | Live settings, GitHub docs, host JSON, public prose | Tested public personal repository separated from untested eligible organization generic/custom capabilities. |
| Tool-to-gate assignment | Workflows, branch protection, README, Markdown, HTML | Local feedback, host prevention, required Gitleaks merge status, non-blocking comparison, scheduled TruffleHog discovery. |
| Responsive page | Existing CSS and current HTML structure | Hero, navigation, main, and footer remain width `100%`; wide tables scroll within their containers. |

## Mechanical and hosted checks

| Check | Result | Boundary |
| --- | --- | --- |
| `bash -n scripts/*.sh`; `shellcheck scripts/*.sh` | Pass | Parsing and static shell analysis. |
| `actionlint`; YAML and JSON parse | Pass | Workflow/configuration structure. |
| `python3 scripts/check-site.py` | Pass: 14 IDs, 59 links, local references present | Static anchors/assets/CSS, not external uptime. |
| `python3 scripts/verify_content_decisions.py` | Pass: nine decisions | Register structure and references. |
| `make check` | Pass | Configured Gitleaks directory test and safe positive/negative demonstration. |
| `make compare` with Gitleaks 8.30.1 and TruffleHog 3.97.1 | Pass: all 19 assertions | Current corpus and configurations, not production accuracy. |
| Gitleaks and TruffleHog production-history commands | Pass: zero findings outside the intentional corpus | Provider checks disabled; exact corpus paths excluded. |
| Manifest guard fault injection | Pass | A safe unmanifested file caused exit 1 before scanning; removal restored the full pass. |
| Remote artifact comparison | Byte-identical SHA-256 `135db387…` | Checked-in JSON matches artifact `9553923464`. |
| Host alert query | Alert `1`, Mailchimp type, resolved `used_in_tests`, bypass true, validity unknown | Exact recorded repository and settings only. |
| Branch-protection query | Required Gitleaks status present; administrator enforcement false | Current `main` protection only. |

## Limitations and uncertainty

- The corpus is a regression matrix, not a production sample; false-positive and false-negative rates were not estimated.
- No provider-issued or active credential was used, and outbound TruffleHog provider checks stayed disabled.
- GitHub alert `1` demonstrates one provider-shaped pattern and a governed test bypass, not every provider or token version.
- The UI labels the value publicly leaked and shows other public occurrences of the same deterministic shape; the test concerns pattern classification and push behavior, not uniqueness or validity.
- Generic, AI-detected, validity, and custom behavior on an eligible organization plan was not exercised.
- Large histories, archives, images, organization sources, provider latency, cost, and production triage were not benchmarked.
- Main-branch administrator enforcement is disabled and is disclosed rather than represented as absolute.

## Closure

All changed-input passes and always-run checks completed after the hosted alert
was created. The prior manifest guard was exercised, the direct remote results
match their sanitized snapshots, and no required finding remains open.
