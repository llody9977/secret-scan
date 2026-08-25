#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_path="$repo_root/.gitleaks.toml"
output_mode="text"

if [[ "${1:-}" == "--json" ]]; then
  output_mode="json"
elif [[ -n "${1:-}" ]]; then
  printf 'usage: %s [--json]\n' "$0" >&2
  exit 2
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  printf 'gitleaks is required; install version 8.30.1 or later.\n' >&2
  exit 2
fi

test_root="$(mktemp -d "${TMPDIR:-/tmp}/secret-scan-test.XXXXXX")"
cleanup() {
  rm -rf -- "$test_root"
}
trap cleanup EXIT

mkdir -p "$test_root/vulnerable" "$test_root/safe"

# Build a recognizable but non-random fictional value at runtime. No complete
# secret-like value exists in this repository, and no verifier is contacted.
printf -v synthetic_suffix 'A1%.0s' {1..16}
printf -v synthetic_secret '%s_%s' 'DEMO' "$synthetic_suffix"
sed "s/{{SYNTHETIC_DEMO_SECRET}}/$synthetic_secret/" \
  "$repo_root/testdata/leaked.env.tmpl" > "$test_root/vulnerable/payments.env"
cp "$repo_root/testdata/safe.env" "$test_root/safe/payments.env"

vulnerable_report="$test_root/vulnerable-report.json"
safe_report="$test_root/safe-report.json"

set +e
gitleaks dir \
  --config "$config_path" \
  --exit-code 1 \
  --max-decode-depth 1 \
  --no-banner \
  --redact=100 \
  --report-format json \
  --report-path "$vulnerable_report" \
  "$test_root/vulnerable" >/dev/null 2>&1
vulnerable_status=$?
set -e

if [[ $vulnerable_status -ne 1 ]]; then
  printf 'expected vulnerable scenario to be blocked; exit code was %d\n' \
    "$vulnerable_status" >&2
  exit 1
fi

if ! grep -q 'synthetic-demo-api-key' "$vulnerable_report"; then
  printf 'vulnerable scan failed without the expected synthetic finding\n' >&2
  exit 1
fi

if grep -q "$synthetic_secret" "$vulnerable_report"; then
  printf 'scanner report exposed the fictional value instead of redacting it\n' >&2
  exit 1
fi

set +e
gitleaks dir \
  --config "$config_path" \
  --exit-code 1 \
  --max-decode-depth 1 \
  --no-banner \
  --redact=100 \
  --report-format json \
  --report-path "$safe_report" \
  "$test_root/safe" >/dev/null 2>&1
safe_status=$?
set -e

if [[ $safe_status -ne 0 ]]; then
  printf 'expected runtime-reference scenario to pass; exit code was %d\n' \
    "$safe_status" >&2
  exit 1
fi

finding_count="$(grep -c '"RuleID"' "$vulnerable_report" || true)"
gitleaks_version="$(gitleaks version | tr -d '\r')"
measured_on="$(date -u +%Y-%m-%d)"

if [[ "$output_mode" == "json" ]]; then
  printf '{\n'
  printf '  "schema_version": 1,\n'
  printf '  "measured_on": "%s",\n' "$measured_on"
  printf '  "command": "./scripts/test-secret-scan.sh --json",\n'
  printf '  "scanner": "gitleaks",\n'
  printf '  "scanner_version": "%s",\n' "$gitleaks_version"
  printf '  "provider_checks_enabled": false,\n'
  printf '  "secret_material_committed": false,\n'
  printf '  "scenarios": [\n'
  printf '    {"id": "hardcoded-synthetic", "expected": "blocked", "observed_exit_code": %d, "finding_count": %d},\n' \
    "$vulnerable_status" "$finding_count"
  printf '    {"id": "runtime-reference", "expected": "passed", "observed_exit_code": %d, "finding_count": 0}\n' \
    "$safe_status"
  printf '  ]\n'
  printf '}\n'
else
  printf 'hardcoded-synthetic: blocked (exit %d, findings %d)\n' \
    "$vulnerable_status" "$finding_count"
  printf 'runtime-reference: passed (exit %d, findings 0)\n' "$safe_status"
  printf 'scanner: gitleaks %s; provider checks: disabled; reports: redacted\n' \
    "$gitleaks_version"
fi
