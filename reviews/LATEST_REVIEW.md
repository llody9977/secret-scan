# Review record: control classification, hosted summaries, and rollout guidance

## Status and baseline

- Status: Complete with no open findings
- Review date: 2026-08-25
- Reviewer: Codex
- Model / effort this review: `gpt-5.6-sol` / `xhigh`
- Branch: `control-classification-summaries`
- Commit: `8a64be07e1848dea00579f8a7c2b24d67a17fe61`
- Worktree: Dirty by design: `README.md`, `secret-scanning.md`, `docs/index.html`, `results/README.md`, `results/scanner-comparison-results.json`, `scripts/compare-secret-scanners.sh`, `reviews/REVIEW_STATE.json`, and this record contain the reviewed change set.
- Review state ID: `6394b52d034b8bf89f56133dd8566c33b709d5991946d2abd013cca379f79d69`
- Scoped content fingerprint: `58fba6d8040f6032c1abf5d7f697478b3f2e02d85d881d3c44c4949789e1e3c1` (56 files)
- State-capture command: `python3 scripts/capture_review_state.py`
- Pass-routing command: `python3 scripts/review_passes.py --model gpt-5.6-sol --effort xhigh --json`
- Pass state recorded with: `--record` for all eleven passes that ran
- Baseline changed during review: Yes. Obsolete TruffleHog alpha wording was removed, GitHub Enterprise references were narrowed to GitHub Enterprise Cloud, workflow failure/redaction/input-sanitization paths were hardened, hosted jobs were rerun, and affected passes and checks were repeated.

### Prior review this one builds on

- Prior review date / model / effort: 2026-08-25 / `gpt-5` / `xhigh`
- Prior commit: `bcc467fc7e4d9a4db539acd6dd00e34a5f4dc1a7`
- Passes carried forward from it: none; all current passes ran because inputs changed and the current router does not rank `gpt-5.6-sol` capability.

## Scope inventory

| Artifact | Type | Direct dependents or generated counterpart | Inspected |
| --- | --- | --- | --- |
| `README.md` | Summary | GitHub repository landing page | Yes |
| `secret-scanning.md` | Long-form source | Detailed article and Pages content | Yes |
| `docs/` | HTML/CSS/images | GitHub Pages | Yes |
| `.github/workflows/` | Automation | Hosted run summaries and required checks | Yes |
| `.github/dependabot.yml` | Automation configuration | Dependency operations | Yes |
| `.gitleaks.toml`, `.trufflehog.yml`, `.pre-commit-config.yaml` | Scanner configuration | Local and hosted scans | Yes |
| `Makefile` | Task interface | Documented commands | Yes |
| `scripts/` | Tests and guards | CI, comparison, site and review checks | Yes |
| `testdata/` | Synthetic corpus | Scanner comparison | Yes |
| `results/` | Sanitized snapshots and procedure | README, article, Pages | Yes |
| `reviews/CONTENT_DECISIONS.yml` | Durable decisions | Review reconciliation | Yes |
| `reviews/REVIEW_STATE.json` | Review metadata | Pass router | Yes |
| Live GitHub Actions runs and artifact | Hosted outputs | Reader-facing result links | Yes |
| GitHub alert/settings/branch protection and cited primary sources | External inputs | Product boundaries and governance claims | Yes |

Out of scope: production credentials, private or organization-owned repositories, paid-plan configuration, provider-issued token validity, large-history performance, organization-wide source coverage, cost, and production triage throughput.

## Review passes

The router required every pass to run. Its reason for each was: `recorded capability (gpt-5.6-sol/xhigh) does not cover current (gpt-5.6-sol/xhigh)`. This is a router model-ranking limitation, not a content finding.

| id | Ver | Ran or cached | Reason | Verdict | Basis |
| --- | --- | --- | --- | --- | --- |
| `factual-correctness` | 1 | run | Router capability comparison | clean | Product claims, exact limits, repository settings, workflows, hosted runs, and snapshots reconciled. |
| `evidence-authority` | 1 | run | Router capability comparison | clean | Time-sensitive product claims use current GitHub and tool-maintainer sources; repository behavior uses direct hosted objects. |
| `adversarial-claims` | 1 | run | Router capability comparison | clean | Conditional language, target-event boundaries, test scope, and counterexamples are adjacent to conclusions. |
| `terminology-taxonomy` | 1 | run | Router capability comparison | clean | Secret, detector, provider/generic/custom pattern, push protection, detection, prevention, gate, and discovery are distinct. |
| `cross-format` | 1 | run | Router capability comparison | clean | Workflows, result JSON, README, article, HTML, metadata, captions, and links agree. |
| `visual-content` | 2 | run | Router capability comparison | clean | Control map, result cards, responsive layout, dark mode, mobile overflow, and social preview inspected. |
| `cross-page` | 1 | run | Router capability comparison | clean | README remains a summary; Pages and Markdown carry the same controls, results, limits, and recommendations. |
| `topic-completeness` | 1 | run | Router capability comparison | clean | Definition, risk, incidents, storage, response, tool criteria, gates, governance, limitations, and rollout are covered. |
| `argument-integrity` | 2 | run | Router capability comparison | clean | Criteria precede comparison; results support a conditional stack rather than use-all advice. |
| `executable-demonstration` | 2 | run | Router capability comparison | clean | Current pinned engines, all manifest scenarios, safe summaries, exclusions, redaction, and failure semantics exercised. |
| `decision-reconciliation` | 1 | run | Router capability comparison | clean | Applicable current decisions reaffirmed; superseded decisions remain historical. |

Always-run tier:

| Check | Result | What it does not prove |
| --- | --- | --- |
| Mechanical, link, generator, and rendered-output checks | Pass | Production detection rates, paid GitHub behavior, or future external uptime. |
| Guard regression | Pass; workflow-summary, site-duplication, and manifest-coverage faults were injected and rejected | That every future regression has a guard. |
| Residual exhaustion | Pass after baseline corrections and workflow hardening | Correctness outside the stated scope. |

### Method versions bumped by this review

None.

### Findings mechanized into guards

| Finding | Guard added (and where it runs) | Fault test | If not mechanized, why |
| --- | --- | --- | --- |
| Workflow summaries could lose safe redaction, status fields, sanitization, or finding-based failure behavior. | `scripts/check-workflow-summaries.py`, called by CI | Passed with altered validation behavior and adversarial ref/event/detector input | — |
| A duplicate command-result panel could return to Pages. | `scripts/check-site.py` | Passed by injecting the rejected panel marker | — |
| An unlisted corpus fixture could escape expected-outcome assertions. | Manifest-coverage check in `scripts/compare-secret-scanners.sh` | Passed with a temporary unmanifested safe fixture | — |
| GitHub plan naming and upstream maturity wording can change. | — | Current primary sources and repository-wide text search used | Not a stable local invariant; review against current upstream sources. |

## Material-claim ledger

| ID | Artifact and location | Material claim | Classification | Primary source or direct result | Repetitions checked | Result |
| --- | --- | --- | --- | --- | --- | --- |
| C-001 | Article, “What is a secret?” | Secrets are authentication/authorization material and related confidential values, not merely strings that look random. | Definition | GitHub secret-scanning concepts and repository taxonomy | README, Markdown, HTML | Clean |
| C-002 | Business-risk and incident sections | Exposed credentials can enable unauthorized access; Git history and downstream copies affect response. | Risk/lifecycle | GitHub remediation guidance and cited incident primary reports | Markdown, HTML | Clean |
| C-003 | Control map and gate table | Preventive/detective classification depends on the target event. | Control design | Git/Actions sequence and implemented workflows | README, Markdown, HTML, workflows | Clean |
| C-004 | GitHub product section | Push protection gates covered pushes at GitHub's receive boundary; its pattern engine and gate location are host-managed. | Product behavior | GitHub push-protection documentation and direct hosted block | Markdown, HTML | Clean |
| C-005 | GitHub configuration boundary | Eligible GitHub Team and GitHub Enterprise Cloud organization repositories can add generic/custom capabilities; this configuration was not tested. | Plan/applicability | GitHub feature, generic-pattern, and custom-pattern documentation | README, Markdown, HTML, results | Clean |
| C-006 | GitHub limits | Only supported alert patterns are eligible; passwords are not push-protected; documented size, timeout, alert-count, and display limits apply. | Product limit | GitHub detection-scope and command-line documentation | Markdown, HTML | Clean |
| C-007 | Configuration-ownership table | Gitleaks custom rules and the demonstrated TruffleHog custom detector are repository configuration, not out-of-box detections. | Implementation | Scanner configs, workflows, tool documentation | README, Markdown, HTML, result JSON | Clean |
| C-008 | Hosted comparison | Gitleaks 8.30.1 found 13/16 positives; TruffleHog 3.97.1 found 8/16; both passed 3/3 negatives in this corpus/configuration. | Test result | Actions run `32831205587`, artifact `9556823734`, checked-in JSON | README, Markdown, HTML, results | Clean |
| C-009 | GitHub host result | The Mailchimp-shaped fixture was blocked, bypassed for the controlled test, and recorded as resolved alert `1`. | Host result | GitHub push response and authenticated alert object | README, Markdown, HTML, host snapshot | Clean |
| C-010 | TruffleHog role | “Broad discovery” refers to source reach and optional provider checks, not universal detector superiority. | Tool selection | TruffleHog documentation and corpus outcomes | README, Markdown, HTML | Clean |
| C-011 | Workflow summaries | Hosted Gitleaks and TruffleHog jobs publish sanitized status/scope/version/control-role summaries while retaining raw reports only in runner temporary storage. | Operational behavior | Workflow source and jobs `97750057067`, `97750093790` | Workflows, README, Markdown, HTML, results | Clean |
| C-012 | Branch governance | `Gitleaks full-history gate` is required on `main`; administrator enforcement is disabled. | Repository governance | Live branch-protection response | Markdown, HTML | Clean |
| C-013 | Storage guidance | Runtime secrets belong in purpose-built secret stores with least privilege, short lifetime, rotation, audit, and revocation—not in Git. | Security practice | Cited vendor and standards guidance | Markdown, HTML | Clean |
| C-014 | Real-world cases | The cited incidents illustrate credential exposure consequences but do not establish a single universal root cause or loss rate. | Incident examples | Primary incident/company/regulator sources | Markdown, HTML | Clean |

## Topic completeness matrix

| Topic | Definition | Boundaries | Actors/components | Mechanism/sequence | Assumptions/dependencies | Threats/failures | Limits/residual risk | Selection/use | Operations/results | Recovery/lifecycle | Interoperability/migration | Unsafe alternatives | Visual representation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Foundations and business risk | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | not applicable: no migration | covered | optional extension: prose is sufficient |
| Control placement and governance | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered: four-stage control map |
| Tool evaluation and comparison | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered: ownership and result tables |
| Remote demonstration | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | not applicable: pinned run links | covered | covered: result cards |
| Storage, response, and lifecycle | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | covered | optional extension: sequence is short enough in prose |

## Argument integrity

**Thesis AS STATED:** Secret scanning should be made governable by matching each control to a target event, placing host prevention before remote acceptance where available, using required portable CI for merge policy, and assigning scheduled discovery and incident response to residual risk.

**Thesis AS SUPPORTED:** Current primary documentation, direct GitHub host behavior, and the pinned remote repository runs support a conditional layered system: host push protection prevents covered patterns at the GitHub receive boundary; local hooks provide bypassable feedback; required CI detects remote exposure and can prevent merge; scheduled scans detect residue; and additional tools are justified by measured gaps.

**Gap between the two lines:** none.

| Test | Result | Basis |
| --- | --- | --- |
| Thesis support | Clean | Claims are conditional and tied to target event, configuration, and direct results. |
| Detached headline | Clean | Title, H1, lede, meta description, and README opening state a decision framework, not universal prevention. |
| Comparison-set validity | Clean | Product capability, configured detector behavior, implementation ownership, and gate role are separated rather than collapsed into one ranking. |
| Demonstration sufficiency | Clean | All tools use the same manifest and corpus; out-of-box versus repository-configured detections are labeled. |
| Dangling claims | Clean | Limits, governance dependencies, custom patterns, incident response, and residual risk are developed. |
| Structure serves the decision | Clean | Criteria lead to observed comparison, control placement, and low-friction rollout order. |

## Cross-format and cross-page ledger

| Concept or claim | Representations compared | Result |
| --- | --- | --- |
| Preventive/detective roles and target events | README, Markdown, HTML map/table, workflow summary text | Clean |
| GitHub receive-boundary gate and configuration ownership | Markdown, HTML, direct host result, GitHub references | Clean |
| Corpus composition, scanner versions, and counts | Manifest, workflow artifact, checked-in JSON, README, Markdown, HTML | Clean |
| Built-in versus repository-configured detections | Config files, comparison summary, tables, result JSON | Clean |
| Hosted summary links and safe output behavior | Workflow logs, README, Markdown, HTML, results README | Clean |
| Rollout recommendation | README, Markdown, HTML | Clean |

## Visual content ledger

| Visual | Claims asserted | Independently correct? | Detached self-sufficiency | Caption and alt text | Generator/correspondence | Standalone defensibility | Result |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Four-stage control map | Gate order, owner, control type, target event, governance strength | Yes | Yes; each card names role and limitation | Checked | HTML/CSS source corresponds | Local-hook bypass and CI/host boundaries shown | Clean |
| Four-card hosted-results grid | Two job summaries, corpus comparison, GitHub host result | Yes | Yes; links and scope are on cards | Checked | HTML links match hosted objects | Counts bounded to corpus/configuration | Clean |
| Social preview image | Credential blocked before production as a control objective | Yes as an imperative illustration | Yes; does not claim universal coverage | Checked | Source asset inspected | One depicted outcome, no comparative score | Clean |

### Representation opportunities

None required. The control map replaces the earlier box workflow; tables remain the clearest form for exact configuration ownership and per-scenario results.

## Applicable durable content decisions

| Decision ID | Affected concept | Disposition | Current rationale |
| --- | --- | --- | --- |
| CD-0002 | Synthetic data only | reaffirmed | No active credential is required to test detector behavior or host pattern classification. |
| CD-0004 | README summary / Pages detail | reaffirmed | Reader entry point stays brief; long-form comparison and references remain on Pages. |
| CD-0006 | Conditional stack, not use-all recommendation | reaffirmed | Tool addition is based on named gaps, target event, and governance need. |
| CD-0009 | Direct GitHub-hosted result | reaffirmed | Alert `1` and host snapshot remain the tested public-personal-repository result. |
| CD-0010 | Control classification, safe summaries, ownership, rollout | reaffirmed | Implemented in workflows and all reader-facing formats. |
| CD-0001, CD-0003, CD-0005, CD-0007, CD-0008 | Earlier approaches | superseded / not applicable | Retained as historical register entries; current decisions govern this revision. |

## Mechanical and rendered checks

| Check | Scope | Result | What this does not prove |
| --- | --- | --- | --- |
| `actionlint`, shell syntax, `shellcheck`, Python compile | Workflows and scripts | Pass | Hosted service behavior outside exercised jobs. |
| `scripts/check-workflow-summaries.py` | Safe summaries, redaction, sanitization, failure contract | Pass | All possible scanner-output formats. |
| `scripts/check-site.py` | HTML structure, links, assets, responsive CSS, duplicate panel guard | Pass: 14 IDs and 70 links | External uptime. |
| `scripts/verify_content_decisions.py` | Ten durable decisions | Pass | The judgments themselves. |
| `scripts/test-secret-scan.sh` | Positive/negative local Gitleaks demonstration | Pass | Production rates. |
| Full corpus comparison | 16 positives and 3 negatives with pinned engines | Pass: 13/16 and 8/16; both negatives 3/3 | Production accuracy or provider validity. |
| Production-history Gitleaks and TruffleHog runs | Repository outside synthetic corpus | Pass: zero findings | Unreachable sources or disabled provider checks. |
| Hosted Gitleaks and TruffleHog jobs | Current commit and safe job summaries | Pass | Paid GitHub configuration. |
| Desktop/mobile, light/dark rendering | Control map, result grid, tables, overflow | Pass; no document-level mobile overflow | Every browser/assistive-technology combination. |
| Repository-wide wording search | Reader-facing files | Pass | Future source wording changes. |
| `git diff --check` | Reviewed change set | Pass | Semantic correctness. |

## Open required findings

None.

## Dismissal ledger — candidates considered and dropped

| What was noticed | Artifact and location | Why it is not a finding |
| --- | --- | --- |
| “Catch credentials before code becomes an incident” can sound absolute. | Social preview | It is an imperative objective paired with one blocked credential, not a claim that every control catches every secret; surrounding comparison remains conditional. |
| The old comparison run remains in the host-result snapshot. | `results/github-secret-protection-results.json` | It is historical provenance for the exact alert-test commit; current comparison and production jobs are linked separately. |
| Unauthenticated alert and artifact requests return 404. | GitHub security and Actions links | Authenticated API queries confirmed the current objects; sanitized checked-in snapshots provide a durable public fallback. |
| Scanner fractions could be read as accuracy or ranking. | Result tables | Labels explicitly bound counts to this corpus, versions, and configuration; conclusions use pattern-level gaps. |
| Eligible plan capabilities might be inferred as exercised. | GitHub comparison | Text explicitly says GitHub Team/GitHub Enterprise Cloud organization features were not tested here. |

## Optional coverage

- Add a future organization-owned eligible-plan run if access is available, keeping it as a separate configuration rather than replacing the free public-repository result.
- Extend the manifest with new synthetic secret families and negative controls as business formats change.
- Add scale, latency, archive, binary, and triage-throughput tests before making operational cost claims.

## Limitations and uncertainty

- The corpus is a regression matrix, not a production sample; no false-positive/false-negative rate is claimed.
- No active credential was used, and TruffleHog provider checks were disabled.
- The GitHub host test covers one Mailchimp-shaped provider pattern in a free public personal repository.
- Generic, AI-based, validity, and custom behavior on an eligible GitHub Team or GitHub Enterprise Cloud organization repository was not exercised.
- Large histories, archives, images, organization sources, provider latency, cost, and production triage were not benchmarked.
- Main-branch administrator enforcement is disabled.
- Security-alert and artifact pages require an authenticated GitHub surface for some viewers; checked-in sanitized result snapshots remain available.
- The pass router does not currently rank `gpt-5.6-sol`, so rerouting reports RUN even after same-model clean results were recorded. The recorded pass state itself is current.

## Closure attestation

- [x] Every pass was run and clean.
- [x] The router's RUN/CACHED split was followed.
- [x] Every in-scope artifact covered by a running pass was inventoried and read.
- [x] Material claims were entered and dispositioned.
- [x] Topics received completeness classifications.
- [x] Mandatory passes were completed separately.
- [x] Current primary sources were used for time-sensitive product claims.
- [x] Prose, metadata, visuals, examples, summaries, navigation, workflows, and results were reconciled.
- [x] Visuals were reviewed independently and in desktop/mobile light/dark renderings.
- [x] Mechanical and rendered checks passed.
- [x] Durable content decisions were reconciled after claim review.
- [x] Argument integrity was completed with stated/supported theses and detached-title checks.
- [x] Dismissed candidates are recorded.
- [x] Residual exhaustion followed baseline changes.
- [x] Previous guards ran and fault injections showed the relevant guards still fire.
- [x] Mechanizable findings gained guards; source-volatility checks remain manual by design.
- [x] Pass state was recorded only for passes that ran.
- [x] Baseline changes and repeated passes are documented.
- [x] Required findings, optional coverage, and limitations are separated.

Closure conclusion: The content, workflows, hosted summaries, result snapshots, control map, and rollout guidance are internally consistent and no required finding remains open within the stated scope.
