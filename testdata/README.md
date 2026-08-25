# Synthetic secret-scan scenarios

This directory contains two kinds of defensive fixtures. None was issued by a
provider and none can authenticate to a service.

- `leaked.env.tmpl` and `safe.env` drive the small local gate test. That script
  still creates its fictional value under `mktemp`.
- `synthetic/` is the checked-in evaluation corpus used by GitHub Actions and
  GitHub Secret Protection. Its manifest records the expected result for every
  scanner and is designed to grow when another credential format matters.

The normal repository gates exclude only `testdata/synthetic/`, because those
files intentionally resemble credentials. The separate remote evaluation
workflow scans that directory explicitly, keeps raw TruffleHog output on the
ephemeral runner, fully redacts Gitleaks reports, and publishes safe metadata.
