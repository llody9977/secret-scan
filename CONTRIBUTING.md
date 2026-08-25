# Contributing

Thanks for improving `secret-scan`.

## Reporting issues

- **Bugs and features:** open an issue using the repository templates.
- **Security vulnerabilities:** do **not** open a public issue; follow [`SECURITY.md`](SECURITY.md) to report privately.

## Proposing changes

1. Install Gitleaks 8.30.1 or later and `pre-commit`, then run `make install-hooks` once per clone.
2. Branch from `main` using a focused name such as `feature/short-description` or `fix/short-description`.
3. Keep synthetic credentials fictional, local, redacted, and incapable of authenticating to any service.
4. Run `make check`, `bash -n scripts/*.sh`, and `shellcheck scripts/*.sh` before opening a pull request.
5. Update the article, captured results, and tests together when scanner behavior changes.

## Commit and pull-request conventions

- Write a clear, imperative commit subject and explain the reason in the body when it is not obvious.
- Do not add AI attribution to commits, pull requests, comments, tags, releases, or generated files.
- Keep the change small enough to review in one sitting.
- Treat the **Shell checks** and **Gitleaks full-history gate** checks as required merge gates when the repository is hosted.
