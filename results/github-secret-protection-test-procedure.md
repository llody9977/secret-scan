# GitHub Secret Protection test procedure

GitHub Secret Protection cannot be exercised by the local comparison script.
Push protection runs on GitHub's server after a client attempts to push, while
the local harness scans temporary filesystem content. Use this procedure to add
a GitHub column without treating a local regular expression as GitHub behavior.

## Preconditions

- Use a disposable repository owned by an organization that is eligible for
  GitHub Secret Protection. Do not use a production repository.
- Enable secret scanning and push protection, and record the plan, repository
  visibility, feature settings, bypass policy, and test date.
- Deny or tightly restrict bypass for the test actor.
- Use only non-issued synthetic values. Do not use a real credential even if it
  is believed to be revoked.
- Delete the disposable repository after recording redacted outcomes. A blocked
  push need not be bypassed merely to test later alerting.

## Configure the internal format

GitHub's default patterns do not know an organization's private credential
format. Create a repository or organization custom pattern corresponding to the
local test rule:

```regex
\bDEMO_[A-Z0-9]{32}\b
```

Run GitHub's dry run first, review the matches, publish the pattern, and enable
push protection for it. The same conceptual pattern is configured in
`.gitleaks.toml` and `.trufflehog.yml`; syntax and matching behavior can still
differ between engines.

## Run the matrix

Create one branch and one commit per scenario using the runtime-generation
logic in `scripts/compare-secret-scanners.sh`. Attempt to push each branch and
record only safe metadata: scenario ID, blocked or accepted, pattern name,
whether bypass was offered, whether an alert appeared, and the elapsed time.
Do not copy a matched value into the test record, issue, workflow log, or pull
request.

| Scenario | GitHub documentation to check against | Result to record |
| --- | --- | --- |
| Custom internal token | Requires the published custom pattern; custom push protection also requires repository push protection | Blocked/accepted, custom pattern name |
| Password assignment | Passwords are AI-detected user-alert patterns; GitHub documents that push protection and validity checks are not supported for passwords | Accepted/blocked and later alert |
| PostgreSQL credential URL | `postgres_connection_string` is a generic user-alert pattern | Accepted/blocked and pattern name |
| HTTP Basic credential | `http_basic_authentication_header` is a generic user-alert pattern | Accepted/blocked and pattern name |
| Bearer JWT/header | `http_bearer_authentication_header` and provider token patterns are distinct; record which pattern, if any, fires | Accepted/blocked and pattern name |
| GitHub PAT-shaped token | GitHub documents provider patterns and push protection for supported token versions; a non-issued shape may be rejected by pattern or validity logic | Accepted/blocked and pattern name |
| OAuth client secret | Coverage depends on the provider-specific format or a custom pattern | Accepted/blocked and pattern name |
| AWS pair in one file | GitHub documents AWS access-key-pair support, including push protection | Accepted/blocked and pattern name |
| AWS pair split across two files | GitHub documents that paired patterns are detected only when both parts are in the same file | Accepted/blocked and any later alert |
| Service-account configuration | Record whether a provider pattern or generic private-key pattern fires | Accepted/blocked and pattern name |
| RSA private key | `rsa_private_key` is a generic user-alert pattern | Accepted/blocked and pattern name |
| OpenSSH private key | `openssh_private_key` is a generic user-alert pattern | Accepted/blocked and pattern name |
| Symmetric encryption key | Requires a recognizable provider format or an organization custom pattern | Accepted/blocked and pattern name |
| Webhook signing secret | Requires a supported provider format or an organization custom pattern | Accepted/blocked and pattern name |
| Base64-encoded internal token | Test separately; a plain custom pattern should not be assumed to cover encoded representations | Accepted/blocked and pattern name |
| Runtime reference, placeholder, and public key | Safe negative cases should not be blocked | Accepted/blocked and any unexpected alert |

Repeat the AWS paired-pattern test with the two parts in one file and in separate
files. Repeat the password test by checking both the push result and subsequent
alerts because GitHub documents different support at those two gates.

## Interpret the result

Do not convert the outcomes into a universal accuracy percentage. The matrix is
a regression sample for the selected plan, enabled features, custom patterns,
token versions, and date. Record a missed required category as residual risk,
then choose among:

1. add or refine a GitHub custom pattern;
2. add or refine a versioned local/CI rule;
3. add a second scanner at CI or scheduled discovery if it closes a measured
   gap at acceptable cost; or
4. accept the gap with a named owner and review date.

Primary GitHub references:

- [Supported secret-scanning patterns](https://docs.github.com/en/code-security/reference/secret-security/supported-secret-scanning-patterns)
- [Secret-scanning detection scope and limitations](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope)
- [Managing custom patterns](https://docs.github.com/en/code-security/how-tos/secure-your-secrets/customize-leak-detection/manage-custom-patterns)
