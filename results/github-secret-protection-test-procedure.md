# Repeating the GitHub-hosted secret-scanning test

GitHub's host result must come from a GitHub push and the repository alert API,
not from a local regular expression or either CLI scanner.

The current result is stored in
[`github-secret-protection-results.json`](github-secret-protection-results.json).
With secret scanning and repository push protection enabled, GitHub rejected
commit `bcc467fc7e4d9a4db539acd6dd00e34a5f4dc1a7` and classified
`testdata/synthetic/positive/mailchimp-api-key.env:2` as a **Mailchimp API Key**.
The documented **used in tests** bypass allowed the same commit on retry and
created [secret-scanning alert #1](https://github.com/llody9977/secret-scan/security/secret-scanning/1).
The alert records `mailchimp_api_key`, the commit location, the bypass, and the
`used_in_tests` resolution without this repository copying the matched value
into its result files.

## Scope of the current test

This is a public, personal repository using GitHub's hosted scanning available
for public repositories. It does not have an organization GitHub Secret
Protection entitlement. Provider-pattern scanning and push protection were
enabled; non-provider generic patterns, validity checks, and repository custom
patterns were unavailable or disabled.

The host test therefore answers one narrow question directly: did this GitHub
configuration block this checked-in, non-issued provider-shaped fixture? It
did. It does not estimate overall GitHub detection rates or show how an eligible
Team or Enterprise organization configuration would handle the generic and
internal formats in the rest of the corpus.

## Preconditions

- Use only a non-issued fixture in a repository explicitly authorized for
  defensive testing. Never substitute a real credential, including one
  believed to be revoked.
- Prefer a provider-documented test value when one exists. Otherwise create a
  deterministic value that was never requested from or issued by the provider.
- Record repository visibility, ownership type, applicable plan, scanning
  settings, push-protection settings, validity-check settings, and
  custom-pattern availability. These are part of the result.
- Keep raw alert responses private because GitHub's API includes a `secret`
  field. Persist only sanitized metadata.

## Add or change a scenario

1. Add a non-issued positive fixture and a relevant safe negative.
2. Add the target, desired control decision, and expected CLI metadata to
   `testdata/synthetic/manifest.json`.
3. Run `make compare`; inspect detector changes by scenario.
4. Commit and push. Record whether GitHub rejected or accepted the push, the
   pattern name and location shown by GitHub, and whether a bypass URL appeared.
5. If GitHub blocks a value used only by this test, use GitHub's documented
   **used in tests** bypass reason. Do not disable scanning for the actor.
6. Retry the same push and query the alert API. Retain only alert number, type,
   display name, state, resolution, bypass metadata, validity, HTML URL, and
   sanitized location metadata.
7. Update `results/github-secret-protection-results.json`, link the direct alert,
   and rerun the remote Gitleaks/TruffleHog comparison on the same commit.

## Custom internal formats

The repository-only format is conceptually:

```regex
\bDEMO_[A-Z0-9]{32}\b
```

Gitleaks and TruffleHog version equivalent engine-specific rules in this
repository. GitHub custom patterns were unavailable in this public personal
repository. On an eligible repository, dry-run the pattern, review positives
and negatives, publish it, and enable custom-pattern push protection only after
testing host enforcement and bypass governance on that target plan.

## How to interpret another run

Do not convert a small corpus into a universal percentage. Pattern versions,
paired-value logic, encodings, feature settings, plan eligibility, service
limits, and optional provider checks all change what a scanner can report.

For every required format that the host does not block, choose one of:

1. add or refine an eligible GitHub custom pattern;
2. add or refine a versioned portable rule and keep its CI status required;
3. add a second required scanner only when incremental coverage justifies its
   latency, noise, data boundary, and operating cost;
4. keep a second engine as centrally scheduled discovery; or
5. accept the gap with an owner, rationale, compensating controls, and review
   date.

Primary GitHub references:

- [Supported secret-scanning patterns](https://docs.github.com/en/code-security/reference/secret-security/supported-secret-scanning-patterns)
- [Enabling generic secret scanning](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/detect-secret-leaks/enabling-secret-scanning-for-generic-patterns)
- [Managing custom patterns](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/customize-leak-detection/manage-custom-patterns)
- [Working with push protection from the command line](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/work-with-leak-prevention/push-protection-on-the-command-line)
- [Secret-scanning REST API](https://docs.github.com/en/rest/secret-scanning/secret-scanning)
