# Repeating the GitHub Secret Protection observation

GitHub Secret Protection is host-native. Its result must come from a GitHub push
and the repository alert API, not from a local regular expression or from either
CLI scanner.

The current observation is stored in
[`github-secret-protection-results.json`](github-secret-protection-results.json).
Commit `00feb11a9db6af732a82ce769dd0334af9a7629e` was accepted without a
push-protection block. At `2026-08-25T07:05:53Z`, the alert API returned no
repository alert and the custom-pattern endpoint returned HTTP 404 with
“Feature not available in this repository.”

## Preconditions

- Use only the non-issued fixtures under `testdata/synthetic/` or another
  repository that is explicitly authorized for defensive testing.
- Never substitute a real credential, including one believed to be revoked.
- Record repository visibility, ownership type, plan, secret-scanning setting,
  push-protection setting, validity-check setting, and custom-pattern
  availability. These are part of the result.
- Keep raw alert responses private because GitHub's API includes a `secret`
  field. Persist only sanitized metadata.

## Add or change a scenario

1. Add a fictional positive fixture and relevant safe negatives.
2. Add the target, desired control decision, and expected CLI metadata to
   `testdata/synthetic/manifest.json`.
3. Run `make compare`; inspect detector changes by scenario.
4. Push the commit. Record whether GitHub rejected or accepted it, the pattern
   name shown by GitHub, whether a bypass URL was offered, and whether a bypass
   was used.
5. If GitHub blocks a value that is clearly non-issued and used only by this
   test, use GitHub's documented **used in tests** reason. Do not use an
   exemption that disables scanning for the actor.
6. After host scanning has had time to run, query the alert API and retain only
   alert number, type, display name, state, resolution, bypass metadata,
   validity, HTML URL, and sanitized location metadata.
7. Update `results/github-secret-protection-results.json` with the query time and
   interpretation limits. Never copy the matched value into the result, an
   issue, pull request, workflow log, or article.

## Custom internal formats

The repository-only format is conceptually:

```regex
\bDEMO_[A-Z0-9]{32}\b
```

Gitleaks and TruffleHog version equivalent engine-specific rules in this
repository. GitHub custom patterns were unavailable in the current public
personal repository. On an eligible repository, dry-run the pattern, review
false positives, publish it, and enable custom-pattern push protection only
after confirming host push protection and bypass governance.

## How to interpret another run

Do not convert the results into a universal percentage. A non-issued shape can
be rejected by provider-version or validity logic, while a real current token
could behave differently. Generic alerts, AI-detected passwords, provider
alerts, partner notifications, validity checks, and push protection also have
different support matrices.

For every required format that the host does not block, choose one of:

1. add or refine an eligible GitHub custom pattern;
2. add or refine a versioned portable rule and keep its CI status required;
3. add a second required scanner only if incremental coverage justifies its
   latency, noise, data boundary, and operating cost;
4. keep a second engine as centrally scheduled discovery; or
5. accept the gap with an owner, rationale, compensating controls, and review
   date.

Primary GitHub references:

- [Supported secret-scanning patterns](https://docs.github.com/en/code-security/reference/secret-security/supported-secret-scanning-patterns)
- [Secret-scanning detection scope and limitations](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope)
- [Managing custom patterns](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/customize-leak-detection/manage-custom-patterns)
- [Working with push protection from the command line](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/work-with-leak-prevention/push-protection-on-the-command-line)
- [Secret-scanning REST API](https://docs.github.com/en/rest/secret-scanning/secret-scanning)
