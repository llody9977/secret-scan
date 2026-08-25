# Checked-in fictional credential corpus

Every value under this directory is synthetic and was created solely to test
secret-scanning controls. No value was issued by GitHub, AWS, a database, or any
other provider. The private keys are newly generated test keys with no trust,
account, certificate, workload, or authorized-key relationship.

`manifest.json` is the source of truth. Each entry names the fixture target,
the desired control decision, and the expected result for the pinned Gitleaks
and TruffleHog versions. To add a format:

1. add a non-issued positive and at least one relevant negative;
2. add the scenario and expected detector metadata to `manifest.json`;
3. run `make compare` locally;
4. push the change and review the remote workflow summary and artifact; and
5. review GitHub Secret Protection alerts and push behavior separately.

The production repository scans allowlist this directory only. Do not add a
broader path exception, a real or revoked credential, or raw scanner output.
