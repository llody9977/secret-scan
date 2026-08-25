# Review record: hosted corpus, scanner selection, and governed gates

## Status and baseline

- Status: Complete with no open required findings
- Review date: 2026-08-25
- Reviewer: Codex
- Model / effort: `gpt-5` / `xhigh`
- Branch: `remote-corpus-evaluation`
- Baseline commit: `00feb11a9db6af732a82ce769dd0334af9a7629e`
- Worktree: Dirty by design; the reviewed change set contains the rewritten public content, remote result snapshots, responsive layout, manifest guard, decision register, and this review state
- Review state ID: `aa2a869371cc0d0e6ceadbc45c63981a62cb3f2e3eccc211051852bf54da59ff`
- Scoped content fingerprint: `d92e0b84681a6c536f64d073ce7eb7c7d637bced502cd288489063b463721306`
- State capture: `python3 scripts/capture_review_state.py` over the 13 scopes below; 53 files
- Pass routing: `python3 scripts/review_passes.py --model gpt-5 --effort xhigh --json`
- Pass recording: all 11 routed passes recorded clean in `reviews/REVIEW_STATE.json`

The prior review at commit `256446593051d22c01ea593919526e621333d1e6`
was not carried forward for any content pass. The corpus, result source, argument,
gate model, page layout, comparison, and durable decisions all changed, so every
pass reran.

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

The live product services are outside the filesystem scope. Their recorded
inputs were checked separately: Actions runs `32818011673` and `32818011678`,
artifact `9552099737`, repository Secret Protection settings, a sanitized alert
count, custom-pattern endpoint availability, and `main` branch protection.

## Review passes

| Pass | Router decision | Verdict | Review basis |
| --- | --- | --- | --- |
| Factual correctness | Run: inputs changed | Clean | Compared claims with current primary product references, pinned command behavior, remote metadata, and repository settings. |
| Source authority | Run: citation inputs changed | Clean | Security and product claims use vendor, government, OWASP, or Kubernetes primary sources; dated product boundaries remain explicit. |
| Adversarial claims | Run: prose changed | Clean | Counts are not accuracy rates; GitHub's non-issued result is not generalized; enforcement and bypass limitations are stated. |
| Terminology and taxonomy | Run: prose changed | Clean | Secrets, sensitive non-secrets, detection, blocking, alerting, provider checks, merge gates, and discovery remain distinct. |
| Cross-format consistency | Run: prose/code/metadata/style changed | Clean | README, Markdown, HTML, CSS, manifest, script, JSON, workflow labels, and live settings agree. |
| Visual content | Run: CSS and page changed | Clean | Full-width desktop/tablet/mobile layouts were rendered in dark mode; desktop and mobile were also rendered with the light token set. Tables scroll inside their container without page overflow. |
| Cross-page consistency | Run: prose/metadata changed | Clean | The concise README points to the detailed Pages guide; both give the same roles, counts, host result, limitations, and direct links. |
| Topic completeness | Run: prose changed | Clean | Definition, business risk, incidents, response, storage, evaluation, custom formats, comparison, limitations, gates, governance, and operations are covered. |
| Argument integrity | Run: prose changed | Clean | Criteria precede comparison; direct results and limitations lead to a conditional control assignment instead of a product-count recommendation. |
| Executable demonstration | Run: code/prose changed | Clean | Both pinned engines reran all 18 manifest scenarios; redaction and result assertions passed; the unmanifested-fixture fault was injected and rejected. |
| Decision reconciliation | Run: register changed | Clean | CD-0008 supersedes the temporary-only corpus decision and the pending-host-test decision; CD-0002, CD-0004, and CD-0006 remain applicable. |

Always-run tier:

| Check | Result | Boundary |
| --- | --- | --- |
| Mechanical validation | Pass | Syntax, static structure, configuration parsing, JSON shape, and repository scan behavior; not production accuracy. |
| Guard regression | Pass | Baseline positive/negative Gitleaks test, full redaction, manifest outcome assertions, corpus exclusions, and site guards all still fire. |
| Residual exhaustion | Pass | The manifest coverage finding was fixed, its affected script and public descriptions were reread, and the full comparison reran. |

## Finding mechanized into a guard

| Finding | Guard | Original fault check |
| --- | --- | --- |
| A new file under the production-allowlisted corpus could be omitted from the manifest and therefore escape per-scenario assertions. | `scripts/compare-secret-scanners.sh` now requires unique IDs and targets, confines targets to positive/negative paths, expands directory targets, and compares every tracked or untracked non-ignored corpus file with the covered target set. | A temporary safe `negative/unmanifested.txt` caused exit 1 with the expected manifest-coverage message; after removal the 18-scenario comparison passed. |

## Material-claim ledger

| Claim | Classification | Source or run | Result |
| --- | --- | --- | --- |
| A secret is a confidential authenticator, authorizer, decryptor, signer, or impersonation value. | Definition | OWASP secret lifecycle guidance and practical examples | Supported at the stated engineering scope. |
| Repository credentials can enable a second-stage business incident even when source is private. | Historical mechanism | DOJ Uber agreement, FTC complaint, GitHub OAuth campaign report, CircleCI incident report | Mechanisms and impacts are attributed; scanning-alone prevention is not claimed. |
| Revocation or rotation precedes Git history cleanup. | Incident response | GitHub sensitive-data removal guidance | Correct and repeated consistently. |
| Local hooks can be early but are not centrally governed by default. | Control design | Hook implementation plus clone-local bypass model | Correct; public guidance assigns hooks to feedback. |
| Required CI governs merge, not first remote exposure. | Control design | Git and GitHub workflow sequence | Correct; remote exposure is shown before CI. |
| Gitleaks reported 12/15 and TruffleHog 8/15 on the committed corpus. | Test result | Run `32818011678`, artifact `9552099737`, digest-matched JSON | Exact match; both passed three negatives. |
| GitHub accepted the corpus push and returned no alert at the recorded query time. | Host observation | Commit `00feb11`, push output, sanitized API query at `2026-08-25T07:05:53Z` | Correct for this non-issued corpus and enabled configuration; limitations are adjacent. |
| Repository custom patterns were unavailable. | Feature availability | Repository custom-pattern endpoint HTTP 404 | Correct for this public personal repository; eligible-plan behavior is separately documented. |
| TruffleHog is broad in source reach and optional provider checks, not necessarily in file-shape detection. | Product comparison | TruffleHog primary documentation and corpus counterexamples | Correctly bounded. |
| No product must satisfy all ten evaluation rows alone. | Selection model | Control-system decomposition | Supported; mandatory versus conditional rows are explicit. |
| `Gitleaks full-history gate` is required on `main`, but administrators are not enforced. | Repository governance | Live branch-protection response | Correct and disclosed in README, article, and Pages result card. |

## Argument integrity

**Thesis as stated:** Secret scanning should be designed as a governable control
system in which detection capability, timing, enforcement, reliable operation,
bypass governance, and incident response determine practical effectiveness.

**Thesis as supported:** The primary sources, hosted scanner run, GitHub host
observation, and repository controls support a conditional layered design using
local feedback, host prevention for supported patterns, required portable merge
policy, and scoped discovery for residual gaps.

Gap: none. The title, H1, lede, meta description, and README opening remain
defensible when read independently; none claims complete detection or universal
product superiority.

Dismissed candidates:

- GitHub's accepted corpus was not treated as general provider-token weakness because every value is non-issued and the alert query is point-in-time.
- Aggregate scanner counts were not treated as production accuracy or a winner because the scenarios were chosen for variety, not statistical prevalence.
- Earlier placement was not equated with stronger governance; local bypass and installation remain explicit.
- TruffleHog's wider sources were not used to infer better detection on every file shape.
- The required Gitleaks status was not called bypass-proof because administrator enforcement is disabled.
- The checked-in untrusted private keys were retained because they have no account, certificate, workload, trust, or authorized-key relationship; exact corpus exclusions and the manifest guard limit the exception.

## Cross-format and visual ledger

| Concept | Representations checked | Result |
| --- | --- | --- |
| Corpus size and outcomes | Manifest, script, remote JSON, README, Markdown, HTML | 15 positives, three negatives, 12 Gitleaks detections, eight TruffleHog detections, three negatives passed by both. |
| GitHub host result | Push, API/settings output, host JSON, README, Markdown, HTML | Accepted without bypass; zero alerts at query time; custom patterns unavailable; no provider-wide inference. |
| Tool-to-gate assignment | Workflows, branch protection, README, Markdown, HTML | Local feedback, host prevention, required Gitleaks merge status, non-blocking remote comparison, scheduled TruffleHog discovery. |
| Responsive page | CSS, dark desktop/tablet/mobile renders, light desktop/mobile renders | Main and hero consume the viewport; three-result cards adapt; page has no horizontal overflow; wide tables scroll locally. |
| Gate-flow visual | HTML labels, article Mermaid, gate table, recommendation | Sequence, authority, exposure point, block paths, and late response agree. |
| Social preview | Existing 1200×630 JPEG and current metadata | Asset unchanged; title/description metadata remains consistent with the reframed article. |

## Mechanical and hosted checks

| Check | Result | Boundary |
| --- | --- | --- |
| `bash -n scripts/*.sh`; `shellcheck scripts/*.sh` | Pass | Parsing and static shell analysis. |
| `actionlint`; Ruby YAML parse | Pass | Workflow/configuration structure, not hosted permissions behavior. |
| Python compile; JSON parse | Pass | Syntax and JSON validity. |
| `python3 scripts/check-site.py` | Pass: 14 IDs, 53 links, local references present | Static anchors/assets/CSS, not external-site uptime. |
| `python3 scripts/verify_content_decisions.py` | Pass: eight decisions | Register structure and references, not technical truth. |
| `make check`; Gitleaks directory and full-history scans | Pass | Configured Gitleaks coverage with the intentional corpus exclusion. |
| `make compare` with Gitleaks 8.30.1 and TruffleHog 3.97.1 | Pass: all 18 manifest assertions | Current corpus and configurations, not production accuracy. |
| TruffleHog full-history production command | Pass: zero findings | Provider checks disabled and exact corpus path excluded. |
| Remote artifact comparison | Byte-identical SHA-256 `4c8e3cd…` | Durable JSON exactly matches artifact `9552099737`. |
| Host state query | Zero alerts; Secret Protection and push protection enabled; custom patterns unavailable | Point-in-time and non-issued-corpus limitations remain. |
| Browser layout | Dark 1600/1024/390 and light 1600/390 | Visual and computed-width review of the local Pages source. |

## Limitations and uncertainty

- The corpus is a regression matrix, not a production sample; false-positive and false-negative rates were not estimated.
- No provider-issued or active credential was used, and outbound provider checks remained disabled.
- GitHub alerting is asynchronous; the stored alert count is tied to its recorded query time.
- Large histories, archives, images, organization sources, provider latency, cost, and production triage were not benchmarked.
- The hosted results predate the final prose and manifest-coverage guard, but use the same committed corpus, manifest digest, rules, and pinned scanner versions. The final PR reruns all workflows.
- Main-branch administrator enforcement is disabled; the article discloses this rather than representing the required status as absolute.

## Closure

All routed passes ran and were recorded clean after remediation. All deterministic
checks and prior guards passed. The only review finding was mechanized and its
original fault was exercised. No required finding remains open.
