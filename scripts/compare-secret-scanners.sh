#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
gitleaks_config="$repo_root/.gitleaks.toml"
trufflehog_config="$repo_root/.trufflehog.yml"
corpus_root="$repo_root/testdata/synthetic"
manifest="$corpus_root/manifest.json"
output_mode="text"

if [[ "${1:-}" == "--json" ]]; then
  output_mode="json"
elif [[ -n "${1:-}" ]]; then
  printf 'usage: %s [--json]\n' "$0" >&2
  exit 2
fi

for required_command in gitleaks trufflehog jq git; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf '%s is required for the controlled comparison.\n' "$required_command" >&2
    exit 2
  fi
done

jq -e '
  .schema_version == 1 and
  (.provider_checks_enabled == false) and
  (.scenarios | length > 0) and
  all(.scenarios[];
    (.id | type == "string" and length > 0) and
    (.credential_class | type == "string" and length > 0) and
    (.target | type == "string" and length > 0) and
    (.expected_control_decision == "block" or .expected_control_decision == "pass") and
    (.expected.gitleaks.exit_code | type == "number") and
    (.expected.gitleaks.findings | type == "number") and
    (.expected.trufflehog.exit_code | type == "number") and
    (.expected.trufflehog.findings | type == "number")
  )
' "$manifest" >/dev/null

comparison_root="$(mktemp -d "${TMPDIR:-/tmp}/secret-scanner-comparison.XXXXXX")"
cleanup() {
  rm -rf -- "$comparison_root"
}
trap cleanup EXIT

reports_root="$comparison_root/reports"
scan_corpus_root="$comparison_root/corpus"
scenario_jsonl="$comparison_root/scenarios.jsonl"
final_json="$comparison_root/hosted-scanner-results.json"
mkdir -p "$reports_root" "$scan_corpus_root"
cp -R "$corpus_root/." "$scan_corpus_root/"

while IFS= read -r scenario; do
  scenario_id="$(jq -r '.id' <<<"$scenario")"
  credential_class="$(jq -r '.credential_class' <<<"$scenario")"
  target="$(jq -r '.target' <<<"$scenario")"
  expected_decision="$(jq -r '.expected_control_decision' <<<"$scenario")"
  input_path="$scan_corpus_root/$target"
  gitleaks_report="$reports_root/${scenario_id}-gitleaks.json"
  trufflehog_report="$reports_root/${scenario_id}-trufflehog.jsonl"
  trufflehog_log="$reports_root/${scenario_id}-trufflehog.log"

  if [[ ! -e "$input_path" ]]; then
    printf 'manifest target does not exist: %s\n' "$target" >&2
    exit 1
  fi

  set +e
  gitleaks dir \
    --config "$gitleaks_config" \
    --exit-code 1 \
    --max-decode-depth 1 \
    --no-banner \
    --redact=100 \
    --report-format json \
    --report-path "$gitleaks_report" \
    "$input_path" >/dev/null 2>&1
  gitleaks_status=$?

  trufflehog filesystem "$input_path" \
    --config "$trufflehog_config" \
    --no-verification \
    --no-update \
    --json \
    --fail \
    --fail-on-scan-errors \
    >"$trufflehog_report" 2>"$trufflehog_log"
  trufflehog_status=$?
  set -e

  if [[ ! -f "$gitleaks_report" ]]; then
    printf 'Gitleaks did not create a report for %s\n' "$scenario_id" >&2
    exit 1
  fi

  gitleaks_findings="$(jq 'length' "$gitleaks_report")"
  gitleaks_detectors="$(jq -r '[.[].RuleID] | unique | join(",")' "$gitleaks_report")"
  trufflehog_findings="$(jq -s 'length' "$trufflehog_report")"
  trufflehog_detectors="$(jq -sr '[.[].DetectorName] | unique | join(",")' "$trufflehog_report")"

  expected_gitleaks_status="$(jq -r '.expected.gitleaks.exit_code' <<<"$scenario")"
  expected_gitleaks_findings="$(jq -r '.expected.gitleaks.findings' <<<"$scenario")"
  expected_gitleaks_detector="$(jq -r '.expected.gitleaks.detector // ""' <<<"$scenario")"
  expected_trufflehog_status="$(jq -r '.expected.trufflehog.exit_code' <<<"$scenario")"
  expected_trufflehog_findings="$(jq -r '.expected.trufflehog.findings' <<<"$scenario")"
  expected_trufflehog_detector="$(jq -r '.expected.trufflehog.detector // ""' <<<"$scenario")"

  if [[ "$gitleaks_status" -ne "$expected_gitleaks_status" \
    || "$gitleaks_findings" -ne "$expected_gitleaks_findings" \
    || "$gitleaks_detectors" != "$expected_gitleaks_detector" ]]; then
    printf 'unexpected Gitleaks result for %s: status=%s findings=%s detector=%s\n' \
      "$scenario_id" "$gitleaks_status" "$gitleaks_findings" "$gitleaks_detectors" >&2
    exit 1
  fi

  if [[ "$trufflehog_status" -ne "$expected_trufflehog_status" \
    || "$trufflehog_findings" -ne "$expected_trufflehog_findings" \
    || "$trufflehog_detectors" != "$expected_trufflehog_detector" ]]; then
    printf 'unexpected TruffleHog result for %s: status=%s findings=%s detector=%s\n' \
      "$scenario_id" "$trufflehog_status" "$trufflehog_findings" "$trufflehog_detectors" >&2
    exit 1
  fi

  # Gitleaks output is persisted as safe metadata only. Its match-bearing fields
  # must be empty or contain the scanner's full-redaction marker.
  if ! jq -e 'all(.[]; [(.Secret // ""), (.Match // "")] | all(. == "" or contains("REDACTED")))' \
    "$gitleaks_report" >/dev/null; then
    printf 'Gitleaks report contains unredacted match data for %s\n' "$scenario_id" >&2
    exit 1
  fi

  jq -n \
    --arg id "$scenario_id" \
    --arg credential_class "$credential_class" \
    --arg target "$target" \
    --arg expected "$expected_decision" \
    --argjson g_status "$gitleaks_status" \
    --argjson g_count "$gitleaks_findings" \
    --arg g_detector "$gitleaks_detectors" \
    --argjson t_status "$trufflehog_status" \
    --argjson t_count "$trufflehog_findings" \
    --arg t_detector "$trufflehog_detectors" \
    '{
      id: $id,
      credential_class: $credential_class,
      fixture_target: $target,
      expected_control_decision: $expected,
      gitleaks: {
        detected: ($g_count > 0), exit_code: $g_status, findings: $g_count,
        detector: ($g_detector | if length == 0 then null else . end),
        matched_manifest_expectation: true
      },
      trufflehog: {
        detected: ($t_count > 0), exit_code: $t_status, findings: $t_count,
        detector: ($t_detector | if length == 0 then null else . end),
        matched_manifest_expectation: true
      }
    }' >>"$scenario_jsonl"
done < <(jq -c '.scenarios[]' "$manifest")

gitleaks_version="$(gitleaks version | tr -d '\r')"
trufflehog_version="$(trufflehog --version | awk '{print $2}' | tr -d '\r')"
measured_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
manifest_sha256="$(
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$manifest" | awk '{print $1}'
  else
    shasum -a 256 "$manifest" | awk '{print $1}'
  fi
)"

execution_environment="local"
repository="$(git -C "$repo_root" config --get remote.origin.url || true)"
commit="$(git -C "$repo_root" rev-parse HEAD)"
run_id=""
run_url=""
if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
  execution_environment="github-actions"
  repository="${GITHUB_REPOSITORY:-}"
  commit="${GITHUB_SHA:-$commit}"
  run_id="${GITHUB_RUN_ID:-}"
  run_url="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
fi

jq -s \
  --arg measured_at "$measured_at" \
  --arg environment "$execution_environment" \
  --arg repository "$repository" \
  --arg commit "$commit" \
  --arg run_id "$run_id" \
  --arg run_url "$run_url" \
  --arg runner_os "${RUNNER_OS:-$(uname -s)}" \
  --arg runner_arch "${RUNNER_ARCH:-$(uname -m)}" \
  --arg manifest_sha256 "$manifest_sha256" \
  --arg gitleaks_version "$gitleaks_version" \
  --arg trufflehog_version "$trufflehog_version" \
  '{
    schema_version: 3,
    measured_at_utc: $measured_at,
    execution: {
      environment: $environment,
      repository: $repository,
      commit: $commit,
      run_id: ($run_id | if length == 0 then null else . end),
      run_url: ($run_url | if length == 0 then null else . end),
      runner_os: $runner_os,
      runner_arch: $runner_arch
    },
    command: "./scripts/compare-secret-scanners.sh --json",
    corpus: {
      secret_material_committed: true,
      values_are_non_issued: true,
      path: "testdata/synthetic",
      manifest_sha256: $manifest_sha256,
      provider_checks_enabled: false,
      positive_scenarios: ([.[] | select(.expected_control_decision == "block")] | length),
      safe_negative_scenarios: ([.[] | select(.expected_control_decision == "pass")] | length),
      scenarios: .
    },
    summary: {
      note: "Scenario detections are regression results for this manifest and pinned configuration, not production accuracy rates.",
      gitleaks_positive_scenarios_detected: ([.[] | select(.expected_control_decision == "block" and .gitleaks.detected)] | length),
      trufflehog_positive_scenarios_detected: ([.[] | select(.expected_control_decision == "block" and .trufflehog.detected)] | length),
      gitleaks_safe_negatives_passed: ([.[] | select(.expected_control_decision == "pass" and (.gitleaks.detected | not))] | length),
      trufflehog_safe_negatives_passed: ([.[] | select(.expected_control_decision == "pass" and (.trufflehog.detected | not))] | length)
    },
    tools: {
      gitleaks: {
        version: $gitleaks_version,
        configuration: "defaults plus repository custom rule and one decoding pass",
        report_handling: "fully redacted; safe metadata persisted"
      },
      trufflehog: {
        version: $trufflehog_version,
        configuration: "built-in detectors plus equivalent custom rule; provider checks disabled",
        report_handling: "raw JSON deleted with ephemeral work directory; safe metadata persisted"
      }
    }
  }' "$scenario_jsonl" >"$final_json"

if [[ "$output_mode" == "json" ]]; then
  jq . "$final_json"
else
  printf '%-29s | %-34s | %-34s\n' 'scenario' 'Gitleaks' 'TruffleHog'
  printf '%s\n' '------------------------------+------------------------------------+-----------------------------------'
  jq -r '.corpus.scenarios[] | [
    .id,
    (if .expected_control_decision == "pass" then "passed" elif .gitleaks.detected then "detected \(.gitleaks.findings) (\(.gitleaks.detector))" else "missed" end),
    (if .expected_control_decision == "pass" then "passed" elif .trufflehog.detected then "detected \(.trufflehog.findings) (\(.trufflehog.detector))" else "missed" end)
  ] | @tsv' "$final_json" |
    while IFS=$'\t' read -r scenario_id gitleaks_result trufflehog_result; do
      printf '%-29s | %-34s | %-34s\n' "$scenario_id" "$gitleaks_result" "$trufflehog_result"
    done
  jq -r '
    "positive scenarios detected: gitleaks \(.summary.gitleaks_positive_scenarios_detected)/\(.corpus.positive_scenarios); trufflehog \(.summary.trufflehog_positive_scenarios_detected)/\(.corpus.positive_scenarios)",
    "safe negatives passed: gitleaks \(.summary.gitleaks_safe_negatives_passed)/\(.corpus.safe_negative_scenarios); trufflehog \(.summary.trufflehog_safe_negatives_passed)/\(.corpus.safe_negative_scenarios)",
    "versions: gitleaks \(.tools.gitleaks.version); trufflehog \(.tools.trufflehog.version)",
    "provider checks: disabled; fixtures: checked in; persisted output: safe metadata only"
  ' "$final_json"
fi
