# Secret scanning: reducing credential leaks before they become incidents

> **Defensive scope:** This article and its executable example are for educational and defensive use on a local repository or a system the reader is explicitly authorized to test. The fixtures contain no live credential, contact no provider, and pair the vulnerable case with its mitigation.

Secret scanning is a detection and prevention control for credentials and other secret values that appear in source code, Git history, configuration, build artifacts, or collaboration systems. It reduces—but cannot eliminate—the chance that possession of a repository becomes possession of a production system.

The central engineering rule is simple: **catch a secret at the earliest practical point, enforce the decision again at the shared boundary, and store the real value somewhere designed for secret lifecycle management.** A scanner is not a secret manager, and a clean scan means only that the configured detectors did not report a match.

This article was last updated on **2026-08-25** using the primary references listed below. The checked-in corpus was run on GitHub Actions with Gitleaks 8.30.1 and TruffleHog 3.97.1. The same corpus push was observed by the repository's enabled GitHub Secret Protection controls, so hosted behavior is reported separately from the CLI results.

## A practical definition of a secret

A **secret** is a value whose confidentiality is part of a security decision: possession lets a person or machine authenticate, authorize an action, decrypt data, sign an artifact, or impersonate a trusted party. Common examples include:

- passwords and database connection strings containing passwords;
- API keys, personal access tokens, OAuth tokens, session tokens, and webhook signing secrets;
- private SSH, TLS, code-signing, and package-signing keys;
- symmetric encryption keys and recovery codes;
- cloud access keys, service-account credentials, and CI/CD deployment credentials.

This is a practical engineering definition, not a formal taxonomy. [OWASP's Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) uses a similarly broad set of examples and emphasizes storage, provisioning, auditing, rotation, and revocation as one lifecycle.

Several related values are sensitive without being secrets. A cryptographic public key, a certificate's public portion, a hostname, or an OAuth client identifier normally does not authorize access by itself. Personal data and proprietary source code may require confidentiality controls, but a secret scanner is not a data-loss-prevention system and should not be represented as one.

## Why one leaked value becomes a business risk

A secret collapses an identity check into a reusable string or key. If that value is overprivileged, long-lived, or shared across environments, a small coding error can become a large authorization failure.

The direct technical effects can include unauthorized cloud or database access, data exfiltration, resource abuse, malicious software publication, deployment tampering, or service interruption. The business effects follow from that access: incident-response labor, emergency rotation and downtime, customer notification, contractual or regulatory exposure, fraud and cloud spend, supply-chain impact, and loss of trust.

The risk does not depend on a repository being public. Private repositories are copied to developer machines, CI runners, backups, mirrors, integrations, and third-party applications. Their access controls can also be bypassed by a compromised user or token.

### Real incidents show the complete path

| Incident | What happened | Decision it supports |
| --- | --- | --- |
| Uber, 2014 and 2016 | The US Federal Trade Commission alleged that a publicly posted AWS key with broad privileges enabled the 2014 access to driver data. In the 2016 breach, [Uber admitted that attackers used stolen credentials to enter a private source repository, obtained a private access key, and then copied data associated with about 57 million records](https://www.justice.gov/usao-ndca/pr/uber-enters-non-prosecution-agreement). | Public exposure is dangerous, but “private repository” is not a secret-storage control. Scope and repository access security determine blast radius. |
| GitHub/npm, 2022 | [GitHub reported that stolen OAuth tokens were used to download private repositories](https://github.blog/news-insights/company-news/security-alert-stolen-oauth-user-tokens/). Its investigation linked unauthorized npm infrastructure access to an AWS API key obtained from downloaded private npm repositories. | Attackers mine repositories for credentials that allow a second-stage pivot. Repository access and infrastructure access should not share one failure boundary. |
| CircleCI, 2023 | [CircleCI reported exfiltration of customer environment variables, keys, and tokens](https://circleci.com/blog/jan-4-2023-incident-report/) and told customers to rotate OAuth tokens, project API tokens, SSH keys, and other credentials. | CI secret stores are concentrated trust points. Reduce stored long-lived credentials and design rotation before an incident. |

These cases do not show that scanning alone would have prevented each incident. They describe the mechanism and impact: credentials stored with source or automation can be discovered after another control fails, then reused against a different system. Scanning is one control in that chain.

## If a secret reaches Git, treat it as an incident

Deleting the line in a later commit does not delete the earlier Git object. The value may remain in local clones, remote branches, pull-request references, forks, caches, build output, logs, or backups. History rewriting can reduce future exposure, but it cannot make a copied value unknown again.

Use this response order:

1. **Revoke or rotate first.** Invalidate the exposed credential at its issuing system. [GitHub's history-cleanup guidance](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository) explicitly puts revocation or rotation before repository rewriting.
2. **Preserve incident records and establish the exposure window.** Identify the first commit, every branch and surface containing the value, who or what could read it, and the time at which revocation completed.
3. **Check for use.** Review provider, identity, cloud, database, CI, and application audit logs for activity within that window. Scope the investigation to the permissions the credential actually had.
4. **Replace the storage pattern.** Move the value to an approved secret manager or workload identity flow, update consumers, and confirm the old credential no longer works.
5. **Remove the value from current content and decide whether to rewrite history.** Coordinate a rewrite with every clone owner. Rewriting changes commit hashes, invalidates signatures, can disrupt open work, and risks recontamination from an old clone.
6. **Search adjacent surfaces.** Check issues, pull requests, wikis, chat, CI logs, artifacts, container layers, package registries, and documentation for the same value or related credentials.
7. **Add a regression guard.** Create a safe detector test for the credential format and enforce it at the earliest gate plus a shared gate.

Do not commit a real leaked value as a scanner regression fixture. Use a provider's documented test token when one exists, or use a repository-only fictional format such as the controlled fixture in this repository.

## Judge a gate by control effectiveness, not only by where it runs

An early control is not automatically a governable control. A pre-commit hook can prevent a matching value from entering local Git history, but every developer must install it and can usually bypass it. A centrally required CI check is easier to govern, but a feature-branch secret has already reached the remote before CI reports it. The design must consider five dimensions together:

| Effectiveness dimension | Question to answer |
| --- | --- |
| Detection capability | Does the configured rule set detect the organization's actual credential formats without unacceptable noise? |
| Timing | Does the control run before the unacceptable event: local commit, first remote exposure, merge, deployment, or later discovery? |
| Enforcement | Can the organization require the control, prevent ordinary bypass, and fail safely when the scanner errors? |
| Operation | Is the control fast and reliable enough that people do not disable it, and are its versions and dependencies maintained? |
| Governance and response | Are ownership, exceptions, bypass reasons, audit events, metrics, revocation, and remediation defined and reviewable? |

A tool finding is therefore only one input to control effectiveness. The same detector can be useful feedback in a local hook, a governed merge control in required CI, or a detective control on a schedule.

```mermaid
flowchart TD
    A["Developer worktree"] --> B{"Local hook: fast feedback"}
    B -->|"Finding"| X["Prevent local commit or push"]
    B -->|"Clean or bypassed"| C{"Host push protection: central boundary"}
    C -->|"Covered finding"| Y["Reject remote push or govern bypass"]
    C -->|"Accepted"| D["Remote branch: repository exposure now exists"]
    D --> E{"Required CI: central merge control"}
    E -->|"Finding or scanner error"| Z["Block promotion; respond if real"]
    E -->|"Clean"| F["Protected merge or deployment"]
    F --> G["Scheduled history, organization, and artifact discovery"]
    G -->|"Late finding"| H["Revoke, investigate, remove, and add a guard"]
```

*Practical control flow. “Clean” means no configured detector fired; it does not assert that no secret exists. All targets are local or explicitly authorized.*

| Control point | Prevents first remote exposure? | Centrally enforceable and governable? | Practical role |
| --- | --- | --- | --- |
| Editor or manual scan | Potentially, when the developer runs it | No | Optional convenience and education |
| Pre-commit hook | Yes for detected content when installed and not bypassed | Usually no; installation and bypass are clone-local | Fast feedback before a commit object exists |
| Pre-push hook | Yes for detected content when installed and not bypassed | Usually no | Last developer-controlled check before transfer |
| Host push protection or a server pre-receive hook | Yes for supported, configured patterns that complete within service limits | Yes; the host can apply policy, record bypass, and restrict who may approve it | Primary governed preventive boundary |
| Required pull-request CI | No; the branch content is already remote | Yes for merge or promotion when branch rules prevent bypass | Reproducible central policy and portable custom coverage |
| Scan after a direct or merge push | No | Yes as monitoring, but it is detective | Detect bypass, configuration drift, and default-branch residue |
| Scheduled history, organization, and non-Git scan | No | Yes if centrally scheduled, routed, and measured | Legacy and wider-source discovery |
| Artifact, image, package, and log scan | Depends on whether it gates publication | Yes when integrated with the publishing system | Covers material copied beyond source files |

The governable baseline is therefore not “install a hook.” Use local hooks for feedback, a host-side control for the supported patterns that must not reach the remote, a required CI scan for portable and custom merge policy, and scheduled discovery for history and sources that preventive gates do not cover. Restrict direct pushes and administrative bypass if CI is meant to govern all production changes.

## What to evaluate in a secret-scanning tool

A feature count is less useful than a test against the organization's actual secrets, development flow, and authority model. These are **evaluation criteria, not ten mandatory features for one product**. Some apply to every blocking control; others become requirements only when the threat model or operating model needs them.

| # | Evaluation criterion | When it becomes a requirement |
| --- | --- | --- |
| 1 | **Coverage fit:** provider versions, generic credentials, paired values, private keys, encodings, and organization-specific formats | Always, but only for the credential inventory and representations the control is assigned to cover |
| 2 | **Placement and timing:** staged content, push boundary, pull request, deployment, history, or non-Git source | Always; choose the point before the business event the control must prevent |
| 3 | **Enforcement and governance:** required status, pre-receive policy, bypass authority, audit trail, and ownership | Always for a control represented as mandatory; optional developer feedback does not need to satisfy central governance |
| 4 | **Failure semantics:** finding exit codes, scanner errors, timeouts, fail-open behavior, and branch-rule integration | Always for a blocking gate |
| 5 | **Custom and internal formats:** versioned patterns, engine-specific regex syntax, decoding, positives, negatives, and dry runs | Required when the inventory contains formats no default detector knows |
| 6 | **History and source reach:** full refs, archives, images, CI logs, collaboration content, object stores, and organization enumeration | Required only for the sources assigned to that control; no checkout scanner must pretend to be an object-store scanner |
| 7 | **Signal and validity:** false positives, false negatives, optional provider checks, egress, rate limits, and indeterminate results | Required when active/inactive status changes triage priority or when noise threatens adoption |
| 8 | **Output and exception safety:** redaction, report access, fingerprints, narrow allowlists, owner, reason, and expiry | Always; the scanner and its exception process must not widen exposure |
| 9 | **Performance and reliability:** representative history size, binaries, submodules, archives, concurrency, and service limits | Required before making the control mandatory at scale |
| 10 | **Operational and commercial fit:** alert routing, deduplication, response integration, metrics, tool supply chain, maintenance, license, plan, cost, and data boundary | Required at the program or procurement layer, even when it is not a detector feature |

No single tool is expected to satisfy every possible scope in rows 5–10. The practical requirement is that the **control system** covers the organization's mandatory rows without an unowned gap. For this repository, the central blocking baseline needs tested file/Git coverage, a versioned custom rule, deterministic failure behavior, redacted output, and enforcement through branch protection. Wider-source discovery and provider validation are separate jobs, not reasons to reject an otherwise suitable merge gate.

## Comparing Gitleaks, TruffleHog, and GitHub Secret Protection

### Apply the evaluation criteria before selecting a gate

The comparison below separates three questions that are often collapsed:

1. **What did the pinned Gitleaks and TruffleHog configurations report on a GitHub-hosted runner?** The workflow asserts every scenario and publishes its JSON artifact.
2. **What did the enabled GitHub host control do with the same push?** The Git push result and secret-scanning alert API are recorded separately.
3. **What capability does the vendor document?** Documentation explains why a non-issued synthetic shape may behave differently from a current provider-issued credential and which feature or plan boundary applies.

The corpus contains 15 credential-shaped positive scenarios and three safe negatives. It represents major technical shapes—passwords, credential URLs, authorization headers, provider tokens, paired cloud keys, OAuth secrets, service accounts, private and symmetric keys, webhook secrets, internal formats, encoded material, runtime references, placeholders, and public keys. It is a regression sample, not a claim to contain every provider or token version.

Gitleaks and TruffleHog receive equivalent custom rules for the fictional internal format. Gitleaks is configured for one decoding pass. TruffleHog provider checks are disabled. Every non-issued value is committed under [`testdata/synthetic`](testdata/synthetic/) so future pattern changes use the same inputs locally and remotely.

| Credential shape | Decision | Gitleaks 8.30.1 remote result | TruffleHog 3.97.1 remote result | GitHub host observation | GitHub documented capability |
| --- | --- | --- | --- | --- | --- |
| Custom internal token | Block | Detected: `synthetic-demo-api-key` | Detected: `CustomRegex` | Push accepted; repository custom-pattern API returned “feature not available” | Defaults cannot know the format; eligible repositories can dry-run, publish, and push-protect a custom pattern |
| Username/password assignment | Block | Detected: `generic-api-key` | No finding | Push accepted; no user alert returned | Passwords are AI-detected alert patterns; push protection and validity checks are not supported |
| PostgreSQL credential URL | Block | No finding | Detected: `Postgres` | Push accepted; no user alert returned | `postgres_connection_string` is a generic user-alert pattern |
| HTTP Basic credential | Block | No finding | No finding | Push accepted; no user alert returned | `http_basic_authentication_header` is a generic user-alert pattern |
| Bearer JWT/header | Block | Detected: `jwt` | No finding | Push accepted; no user alert returned | `http_bearer_authentication_header` is generic; provider token patterns are separate |
| GitHub PAT-shaped token | Block | No finding | Detected: `Github` | Push accepted; no user alert returned | Provider pattern and push protection apply only to supported identifiable token versions |
| OAuth client secret | Block | Detected: `generic-api-key` | No finding | Push accepted; no user alert returned | Coverage depends on provider format or a custom pattern |
| AWS pair in one file | Block | Detected: `generic-api-key` | Detected: `AWS` | Push accepted; no user alert returned | AWS access-key-pair pattern supports push protection; a non-issued shape need not pass provider checks |
| AWS pair split across files | Block | Detected one generic value | No finding | Push accepted; no user alert returned | Paired patterns are detected only when both parts occur in the same file |
| Service-account configuration with private key | Block | Detected: `private-key` | Detected: `PrivateKey` | Push accepted; no user alert returned | Provider-specific and generic private-key patterns differ |
| RSA private key | Block | Detected: `private-key` | Detected: `PrivateKey` | Push accepted; no user alert returned | `rsa_private_key` is a generic user-alert pattern |
| OpenSSH private key | Block | Detected: `private-key` | Detected: `PrivateKey` | Push accepted; no user alert returned | `openssh_private_key` is a generic user-alert pattern |
| Symmetric encryption key | Block | Detected: `generic-api-key` | No finding | Push accepted; no user alert returned | Requires a recognized provider shape or custom pattern |
| Webhook signing secret | Block | Detected: `generic-api-key` | No finding | Push accepted; no user alert returned | Requires a supported provider shape or custom pattern |
| Base64-encoded internal token | Block | Detected after one decoding pass; two signals | Detected: `CustomRegex` | Push accepted; no user alert returned | Base64 support is pattern-specific; a plain custom pattern should not be assumed to decode content |
| Runtime reference | Pass | Passed | Passed | Push accepted; no user alert returned | No credential value is present |
| Placeholder | Pass | Passed | Passed | Push accepted; no user alert returned | No credential value is present |
| SSH public key | Pass | Passed | Passed | Push accepted; no user alert returned | A public key does not authenticate as the private key |

In the [GitHub Actions run `32818011678`](https://github.com/llody9977/secret-scan/actions/runs/32818011678), Gitleaks detected 12 of the 15 positive scenarios and TruffleHog detected eight; both passed the three negatives. The [machine-readable artifact](https://github.com/llody9977/secret-scan/actions/runs/32818011678/artifacts/9552099737) and the checked-in [result snapshot](results/scanner-comparison-results.json) identify the runner, commit, manifest digest, detector names, exit codes, and per-scenario outcomes. Those fractions are not production accuracy rates: the cases are deliberately diverse, not statistically sampled, and one encoded value produces two Gitleaks signals. The useful facts are the individual gaps. Both missed the Basic-auth shape. Gitleaks missed the PostgreSQL URL and PAT-shaped token; TruffleHog missed several generic assignments and JWT/OAuth/symmetric/webhook shapes.

GitHub's enabled push protection accepted commit [`00feb11`](https://github.com/llody9977/secret-scan/commit/00feb11a9db6af732a82ce769dd0334af9a7629e) without a block, and the alert API returned no user alerts for the corpus at the recorded query time. This does **not** contradict GitHub's documented provider and generic pattern support: the corpus values are deliberately non-issued, current provider-token confidence and validity logic can matter, generic and password patterns do not all have push protection, and custom patterns were unavailable to this public personal repository. The result means only that this exact enabled host configuration did not stop or alert on this exact synthetic push.

GitHub documents additional constraints: push protection covers only a subset of alert patterns, passwords are not push-protected, only supported token versions are blocked, paired credentials are not combined across files, and push size or timeout limits can affect coverage. A business that relies on the host gate should therefore test provider-documented test credentials where safe, test its own custom formats on an eligible plan, and retain a portable central scanner for material gaps.

### Capability comparison against the evaluation criteria

| Evaluation criterion | Gitleaks 8.30.1 | TruffleHog 3.97.1 | GitHub Secret Protection in this repository |
| --- | --- | --- | --- |
| 1. Coverage fit | Remote corpus: 12/15 positives and 3/3 negatives; strongest here on generic assignments, JWT, private keys, and the custom rule | Remote corpus: 8/15 positives and 3/3 negatives; incremental findings on PostgreSQL, GitHub PAT shape, AWS pair, private keys, and the custom rule | Corpus push: no block and no user alert returned; documented provider, generic, AI, and custom categories are broader than this non-issued test result |
| 2. Placement and timing | Working tree, staged changes, pre-push, Git history, CI, and schedule | Filesystem, Git/CI, scheduled source discovery, and incident triage | Native GitHub push boundary plus asynchronous repository monitoring |
| 3. Enforcement and governance | Governed when its CI status is required and branch/ruleset bypass is controlled; local hooks alone are not centrally governed | Governed if made a required CI job or centrally scheduled; this repository keeps it non-blocking | Host policy can block supported patterns and record bypasses; no bypass was needed in this run |
| 4. Failure semantics | Finding exit code is configurable; this workflow checks the report and expected rule rather than trusting one status alone | `--fail` returns 183 for findings; `--fail-on-scan-errors` distinguishes scan failure | Server decides block/accept; documented timeout and size behavior must be included in the risk decision |
| 5. Custom/internal formats | Versioned TOML rule with regex, keywords, entropy/allowlists, decoding, and committed regression cases | YAML custom detector with keywords and named regexes; currently documented as alpha | Custom pattern API returned “feature not available” here; eligible repositories support dry run, publishing, and optional push protection |
| 6. History and source reach | Filesystem, Git history, stdin, and configured archives | GitHub organizations and some collaboration content, GitLab, filesystems, images, S3, GCS, Postman, Jenkins, and other sources | GitHub-hosted history and supported collaboration surfaces; bounded to GitHub and plan/feature availability |
| 7. Signal and validity | Offline; no built-in provider login check | Optional provider checks can classify active, inactive, unknown, or unverified results; disabled in this test | Validity checks exist only for supported patterns and are disabled in this repository's reported settings |
| 8. Output and exceptions | Full redaction is asserted; the production allowlist is limited to `testdata/synthetic/` | Raw JSON can contain matches, so only safe metadata leaves the ephemeral runner; production discovery excludes the same exact corpus path | Alerts and bypass reasons support governance, but access and retention still need policy |
| 9. Performance and reliability | Not benchmarked on a large history; local and required-CI latency must be measured before broader rollout | Not benchmarked across organization/non-Git sources; provider checks add network and rate-limit dependencies | Hosted scale is managed by GitHub, but documented push size, finding-count, timeout, and pattern limits remain |
| 10. Operational and commercial fit | MIT-licensed portable binary; operators own rules, upgrades, routing, and response | AGPL-3.0 CLI; enterprise service is separate; broader sources and provider checks add data-boundary decisions | Strongest native GitHub alert/bypass experience; public core features are free, while custom/private/internal capabilities depend on repository type and plan |

The table intentionally has no “winner” column. A criterion can be mandatory for one assigned control and irrelevant to another. Here, required CI supplies portable custom merge policy, GitHub supplies the earlier shared boundary for patterns it covers, and TruffleHog remains a second detector and wider-source discovery option. The stack should expand only when a measured residual gap matters to the business.

“Broad discovery” describes TruffleHog's **source reach and optional provider checks**, not a blanket claim that its file detector library is more effective. It can enumerate and scan places a checkout-based Gitleaks job does not see, including repositories across a GitHub organization, some collaboration content, object stores, container images, and CI systems. Its experimental GitHub object discovery can also search some deleted or otherwise hidden objects, with documented maturity and runtime caveats. The remote matrix shows why this distinction matters: TruffleHog found the PostgreSQL and GitHub-token shapes that Gitleaks missed, but missed other shapes that Gitleaks found.

### Custom formats need their own miniature test suite

All three products can model organization-specific formats, but “supports custom regex” is not enough:

- **Gitleaks:** version a TOML rule with keywords and a regular expression; use entropy or allowlists only when the format needs them. The repository's `DEMO_…` rule is exercised on plaintext and Base64-encoded input.
- **TruffleHog:** define keywords and one or more named regular expressions. Optional character requirements and a webhook/provider check can add structure, but custom detectors are documented as alpha and raw result fields require careful handling.
- **GitHub:** on an eligible repository, dry-run a custom pattern before publishing it, then enable custom-pattern push protection only after reviewing likely disruption. This public personal repository's custom-pattern endpoint returned “feature not available,” so the internal format remains a Gitleaks/TruffleHog test rather than an invented GitHub result.

Maintain at least one safe positive for every supported version of an internal format and negatives for placeholders, public identifiers, documentation examples, and common near-matches. Re-run the cases when a pattern, scanner version, encoding setting, or GitHub feature configuration changes.

### Limitations of the repository experiment

- Fifteen positives and three negatives provide a useful regression matrix but cannot estimate false-positive or false-negative rates.
- The inputs are non-issued shapes, provider checks are disabled, and no result says whether a credential is active.
- Detection of one synthetic shape does not establish coverage of older, newer, shortened, transformed, or malformed versions of that credential.
- GitHub accepted one commit containing all scenarios, so the observation does not measure per-scenario latency and could not exercise bypass governance; no block was offered.
- The alert API returned no corpus alert at the recorded query time. Asynchronous timing, non-issued provider shapes, disabled validity checks, and unavailable custom patterns limit what can be concluded.
- TruffleHog JSON can contain raw matched material, so the harness keeps it in temporary storage and persists only safe metadata. Gitleaks is run with full redaction.
- The run does not benchmark large histories, archives, images, non-Git sources, collaboration surfaces, provider latency, false positives in production code, or operating cost.
- Tool versions, detector sets, token formats, hosted plans, and platform settings change; re-run the committed corpus and refresh the remote exports during procurement and upgrades.

## Recommendation: govern the shared boundaries and keep local controls as feedback

| Practice | Implementation in this repository | Governance assessment | Recommendation |
| --- | --- | --- | --- |
| Before commit | Gitleaks staged-content pre-commit hook | Developer-controlled: per-clone installation, configuration, and bypass | Offer it for fast feedback; do not count installation as organization-wide enforcement |
| Before developer push | Gitleaks full-history pre-push hook | Developer-controlled and potentially slower | Keep as a convenience for contributors who accept the latency; central policy must not depend on it |
| At GitHub's push boundary | GitHub push protection | Centrally configured and able to govern bypass, but only for supported/configured patterns within documented limits | Enable it; test the actual plan and token formats; treat uncovered formats as residual risk |
| On every branch/PR | Gitleaks full-history workflow | Centrally visible; governs merge only when the exact status is required and bypass/direct-push rights are restricted | Make **Gitleaks full-history gate** required for protected changes; fail on scanner errors as well as findings |
| After merge and daily | The same Gitleaks workflow | Centrally scheduled detective control | Use for drift and history residue; route findings to an owner and measure remediation time |
| Wider sources | Weekly/manual TruffleHog with provider checks disabled | Centrally scheduled but non-blocking in this repository | Add approved sources or provider checks only for a named risk gap and approved data boundary |
| Tool/rule changes | Remote 18-scenario evaluation workflow | Repeatable regression control with committed inputs, per-scenario assertions, run summary, and artifact | Keep non-blocking; a changed detector result requires review, not automatic production acceptance |

If only one portable scanner can be operated, Gitleaks is the merge-policy baseline here because it supports versioned custom rules, full-redaction output, Git history, local feedback, and centrally required CI. The remote corpus supports that assignment for this repository; it does not make Gitleaks universally more accurate.

GitHub push protection is still recommended because it occupies the earlier shared boundary that CI cannot. This run also shows why it should not be the only layer: the enabled host accepted every non-issued scenario. Organizations with supported current provider tokens may observe different behavior, and eligible organization/enterprise repositories can add custom patterns that this repository could not configure.

Add TruffleHog when one of its distinct outcomes or sources closes a material gap—for example, PostgreSQL URLs in this corpus, organization-wide repository enumeration, object stores, images, or approved provider checks. Promote it to a required CI gate only after measuring incremental coverage, false positives, latency, failure behavior, raw-output handling, egress, and license impact. Otherwise, keep it as scheduled discovery.

The practical conclusion is a governed stack, not “run all three everywhere”: host prevention for covered patterns, portable required CI for merge policy and internal formats, and additional discovery for an identified residual risk.

## Store fewer secrets, and store the remainder for their full lifecycle

The safest stored secret is one that does not exist. Prefer workload identity, short-lived federation, or dynamic credentials to a static key. For example, [GitHub Actions OpenID Connect](https://docs.github.com/en/actions/concepts/security/openid-connect) lets a workflow exchange its identity for a short-lived cloud token rather than duplicating a long-lived cloud credential in GitHub.

When a static secret is necessary, keep it in a centralized secret-management system such as a cloud secret manager, HashiCorp Vault, or an equivalent platform that provides:

- encryption at rest and in transit;
- fine-grained, least-privilege access by workload identity;
- audit logs for read, write, and administrative access;
- automated creation, rotation, expiry, and revocation;
- separation by application, environment, and trust boundary;
- a tested recovery and break-glass process.

Practical placement rules:

| Context | Preferred pattern | Important caveat |
| --- | --- | --- |
| Application runtime | Fetch or mount the value from a secret manager using workload identity; keep it in memory only as long as required | Environment variables can appear in child processes, diagnostics, or crash output; a permissioned file or provider integration may be safer depending on the platform |
| CI/CD | Prefer OIDC or another provider-supported workload identity flow. If a CI secret is unavoidable, scope it to the job/environment, protect deployment environments, mask logs, and rotate it | Maintainers or modified workflows may be able to cause a secret to be used or exfiltrated; CI is a production trust boundary |
| Local development | Use a password manager, operating-system credential store, or developer identity to retrieve a non-production secret. Keep local `.env` files ignored and short-lived | `.gitignore` is only a backstop. It does not protect a file already committed, force-added, logged, backed up, or copied |
| Kubernetes | Prefer an external secret store or configure Kubernetes Secrets with encryption at rest, least-privilege RBAC, and access only for the consuming container | [Kubernetes documents that Secret objects are stored unencrypted in etcd by default](https://kubernetes.io/docs/concepts/configuration/secret/); Base64 encoding is not encryption |
| Encrypted configuration in Git | Use only under a designed threat model with encryption keys held outside Git, separate recipients per environment, rotation, and audit | Encryption can be valid, but it shifts the problem to key management and can hide plaintext from a repository scanner |

Do not put live values in source, examples, unit-test fixtures, `.env.example`, documentation, screenshots, issue bodies, pull-request descriptions, chat, or log output. Store only the reference, identifier, or lookup path that the runtime needs.

## The repository's reproducible test results

The corpus is source-controlled so another pattern can be added without recreating hidden local inputs:

- [`testdata/synthetic/manifest.json`](testdata/synthetic/manifest.json) defines the 18 scenarios, fixture targets, desired control decisions, and expected detector metadata. The harness rejects duplicate targets and any checked-in fixture not covered by the manifest.
- [`testdata/synthetic/`](testdata/synthetic/) contains only non-issued values and newly generated, untrusted test keys.
- The production Gitleaks and TruffleHog scans exclude that exact directory. The remote evaluation workflow copies and scans it explicitly, so the exception cannot turn the regression test into a pass-by-allowlist.

The direct hosted results are:

| Control | Direct result | Recorded scope |
| --- | --- | --- |
| Gitleaks and TruffleHog corpus evaluation | [Actions run `32818011678`](https://github.com/llody9977/secret-scan/actions/runs/32818011678), [artifact `9552099737`](https://github.com/llody9977/secret-scan/actions/runs/32818011678/artifacts/9552099737), and [checked-in JSON](results/scanner-comparison-results.json) | Both pinned engines ran on GitHub's Linux/X64 runner against manifest digest `b4e3fc…`; every outcome matched the manifest |
| Production Gitleaks history gate | [Actions run `32818011673`](https://github.com/llody9977/secret-scan/actions/runs/32818011673) | The full-history gate remained clean with the intentional corpus path excluded; main branch protection names the status, although admin enforcement is disabled |
| GitHub Secret Protection | [Commit `00feb11`](https://github.com/llody9977/secret-scan/commit/00feb11a9db6af732a82ce769dd0334af9a7629e) and [sanitized host result](results/github-secret-protection-results.json) | The enabled push boundary accepted the corpus without offering a bypass; the subsequent alert export and feature-availability result are recorded without matched values |

Run the same committed corpus locally after installing the pinned binaries:

```sh
./scripts/compare-secret-scanners.sh
```

The remote workflow prints the complete per-scenario table into the GitHub job summary and uploads the JSON for 90 days. The checked-in copy provides a durable snapshot after artifact expiry. Raw TruffleHog JSON remains in the ephemeral script directory because it can contain matched values; Gitleaks match fields must pass a full-redaction assertion before the safe metadata is written.

The workflows deliberately have different semantics:

- [Secret scan](.github/workflows/gitleaks.yml) is a required main-branch status and also runs after pushes and daily; the current branch rule does not enforce administrators.
- [Remote scanner evaluation](.github/workflows/scanner-comparison.yml) is a regression job, explicitly **not a merge gate**.
- [TruffleHog discovery](.github/workflows/trufflehog-discovery.yml) is weekly/manual detective coverage and excludes the intentional corpus.
- GitHub push protection is host configuration; its result is not inferred from either CLI.

All download jobs pin versions, check archive checksums, use read-only repository permissions, and do not persist checkout credentials. These runs establish only the recorded behavior for the commit, manifest, versions, runner, and settings. They do not establish credential validity, production false-positive rates, large-repository performance, universal coverage, or absence of secrets.

## Operating checklist

- Inventory secret types, issuers, owners, scopes, storage locations, consumers, rotation methods, and revocation paths.
- Remove long-lived credentials through workload identity or dynamic secrets where possible.
- Offer pre-commit and pre-push scanning as developer feedback, but do not represent clone-local installation as a centrally governed control.
- Enable a host-side push gate for supported patterns; document pattern, plan, timeout, size, and bypass boundaries.
- Run the portable central scan on every push and pull request, on the merge push, and on a schedule; do not rely only on pull-request diffs.
- Make the CI status a required branch or ruleset check, restrict direct-push and administrative bypass, and test both initial-push and scanner-error paths.
- Keep scanner jobs least-privileged, pinned, checksum-checked, redacted, and isolated from unrelated secrets.
- Maintain safe positive and negative fixtures for provider and custom rules.
- Give exceptions an owner, narrow scope, rationale, and review date.
- Treat every confirmed exposure as an incident: revoke, investigate use, replace storage, remove residue, and add a guard.
- Measure time to revoke and rotate, not only the number of findings.

> **What to remember:** Secret scanning is a layered control, not a guarantee of absence and not a secret store. Use local scans for feedback, govern prevention at the host boundary where possible, enforce portable policy in required CI, and design every real credential for least privilege, short lifetime, audit, rotation, and revocation.

## Primary references

- **[Gitleaks repository and documentation](https://github.com/gitleaks/gitleaks)** — current commands, configuration, scan modes, reporting, exit codes, pre-commit support, license, and security-patch-only maintenance posture.
- **[TruffleHog repository and documentation](https://github.com/trufflesecurity/trufflehog)** — supported sources, provider-check result classes, CI behavior, custom-detector status, and AGPL-3.0 licensing.
- **[TruffleHog custom-detector documentation](https://github.com/trufflesecurity/trufflehog/blob/main/pkg/custom_detectors/CUSTOM_DETECTORS.md)** — keyword and named-regex syntax, character requirements, optional webhook checks, raw results, and alpha status.
- **[GitHub: Enabling secret scanning](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/detect-secret-leaks/enable-secret-scanning)** — current public, private/internal organization, user-owned, Team, Enterprise Cloud, and Enterprise Server availability boundaries.
- **[GitHub: Supported secret-scanning patterns](https://docs.github.com/en/code-security/reference/secret-security/supported-secret-scanning-patterns)** — provider, generic, AI-detected, and push-protection support, including the password limitation.
- **[GitHub: Secret scanning detection scope](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope)** — pattern-pair behavior and push-protection pattern, size, timeout, and count limitations.
- **[GitHub: Managing custom patterns](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/customize-leak-detection/manage-custom-patterns)** — dry runs, publishing, and push protection for organization-specific formats.
- **[GitHub: Secret security with GitHub](https://docs.github.com/en/code-security/concepts/secret-security/secret-security-with-github)** — continuous-monitoring surfaces, push prevention, public monitoring, alert workflow, and governance capabilities.
- **[GitHub: OpenID Connect](https://docs.github.com/en/actions/concepts/security/openid-connect)** — replacing long-lived CI cloud credentials with short-lived provider tokens.
- **[GitHub: Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)** — revocation-first response and history-rewrite side effects.
- **[OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)** — secret examples and storage, access, audit, rotation, revocation, and CI/CD lifecycle guidance.
- **[US Department of Justice: Uber 2016 breach agreement](https://www.justice.gov/usao-ndca/pr/uber-enters-non-prosecution-agreement)** and **[FTC revised complaint](https://www.ftc.gov/system/files/documents/cases/1523054_uber_technologies_revised_complaint_0.pdf)** — private-repository and public-key exposure mechanisms and resulting data access.
- **[GitHub: 2022 stolen OAuth token campaign](https://github.blog/news-insights/company-news/security-alert-stolen-oauth-user-tokens/)** — private-repository download, secret mining, and the npm AWS-key pivot.
- **[CircleCI January 2023 incident report](https://circleci.com/blog/jan-4-2023-incident-report/)** — exfiltrated CI secrets, rotation scope, and downstream investigation impact.
- **[Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)** — default etcd storage caveat, encryption-at-rest, RBAC, container scoping, and external-store guidance.
