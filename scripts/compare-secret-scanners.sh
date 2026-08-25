#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
gitleaks_config="$repo_root/.gitleaks.toml"
trufflehog_config="$repo_root/.trufflehog.yml"
output_mode="text"

if [[ "${1:-}" == "--json" ]]; then
  output_mode="json"
elif [[ -n "${1:-}" ]]; then
  printf 'usage: %s [--json]\n' "$0" >&2
  exit 2
fi

for required_command in gitleaks trufflehog jq openssl ssh-keygen; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf '%s is required for the controlled comparison.\n' "$required_command" >&2
    exit 2
  fi
done

comparison_root="$(mktemp -d "${TMPDIR:-/tmp}/secret-scanner-comparison.XXXXXX")"
cleanup() {
  rm -rf -- "$comparison_root"
}
trap cleanup EXIT

corpus_root="$comparison_root/corpus"
reports_root="$comparison_root/reports"
mkdir -p "$corpus_root/aws-split" "$reports_root"

# Assemble representative credential shapes only in temporary storage. Values
# are deterministic or generated locally, are not issued by a provider, and
# are never sent to provider APIs during this comparison.
printf -v custom_suffix 'A1%.0s' {1..16}
custom_value="DEMO_${custom_suffix}"
password_material="$(
  printf '%s' 'secret-scan-password-2026' | openssl dgst -sha256 | awk '{print $NF}'
)"
password_value="P9-${password_material:0:28}"
postgres_url="postgresql://app_user:${password_value}@db.internal.invalid:5432/payments"
basic_value="$(printf '%s' "demo-user:${password_value}" | base64 | tr -d '\n')"
jwt_header="$(
  printf '%s' '{"alg":"HS256","typ":"JWT"}' \
    | openssl base64 -A | tr '+/' '-_' | tr -d '='
)"
jwt_payload="$(
  printf '%s' '{"sub":"demo-user","exp":4102444800}' \
    | openssl base64 -A | tr '+/' '-_' | tr -d '='
)"
jwt_signature="$(
  printf '%s' 'secret-scan-jwt-signature-2026' \
    | openssl dgst -sha256 -binary \
    | openssl base64 -A | tr '+/' '-_' | tr -d '='
)"
jwt_value="${jwt_header}.${jwt_payload}.${jwt_signature}"
github_pat_suffix="$(printf 'A1b2%.0s' {1..9})"
github_pat="ghp_${github_pat_suffix}"
oauth_secret="$(
  printf '%s' 'secret-scan-oauth-secret-2026' \
    | openssl dgst -sha256 -binary | base64 | tr -d '=\n' | cut -c1-40
)"
id_material="$(
  printf '%s' 'secret-scan-aws-id-2026' | openssl dgst -sha256 | awk '{print $NF}'
)"
aws_id="AKIA$(printf '%s' "$id_material" | tr '[:lower:]' '[:upper:]' | cut -c1-16)"
aws_secret="$(
  printf '%s' 'secret-scan-aws-secret-2026' \
    | openssl dgst -sha256 -binary | base64 | tr -d '=\n' | cut -c1-40
)"
encryption_key="$(
  printf '%s' 'secret-scan-encryption-key-2026' \
    | openssl dgst -sha256 | awk '{print $NF}'
)"
webhook_secret="$(
  printf '%s' 'secret-scan-webhook-2026' \
    | openssl dgst -sha256 -binary | base64 | tr -d '=\n' | cut -c1-40
)"
encoded_custom="$(printf '%s' "$custom_value" | base64 | tr -d '\n')"

printf 'INTERNAL_API_KEY=%s\n' "$custom_value" > "$corpus_root/custom-internal.env"
printf 'username = "demo-user"\npassword = "%s"\n' \
  "$password_value" > "$corpus_root/password-assignment.txt"
printf 'DATABASE_URL=%s\n' "$postgres_url" > "$corpus_root/postgres-url.env"
printf 'Authorization: Basic %s\n' "$basic_value" > "$corpus_root/basic-header.txt"
printf 'Authorization: Bearer %s\n' "$jwt_value" > "$corpus_root/bearer-jwt.txt"
printf 'GITHUB_TOKEN=%s\n' "$github_pat" > "$corpus_root/github-pat.env"
printf 'OAUTH_CLIENT_ID=demo-public-client-id\nOAUTH_CLIENT_SECRET=%s\n' \
  "$oauth_secret" > "$corpus_root/oauth-client.env"
printf 'AWS_ACCESS_KEY_ID=%s\nAWS_SECRET_ACCESS_KEY=%s\n' \
  "$aws_id" "$aws_secret" > "$corpus_root/aws-pair.env"
printf 'AWS_ACCESS_KEY_ID=%s\n' "$aws_id" > "$corpus_root/aws-split/id.env"
printf 'AWS_SECRET_ACCESS_KEY=%s\n' "$aws_secret" > "$corpus_root/aws-split/secret.env"

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
  -out "$corpus_root/generated-rsa.pem" 2>/dev/null
{
  printf '%s\n' \
    'type: service_account' \
    'project_id: demo-project' \
    'private_key_id: 0123456789abcdef0123456789abcdef01234567' \
    'client_email: demo-service-account@demo-project.iam.gserviceaccount.com' \
    'private_key: |'
  sed 's/^/  /' "$corpus_root/generated-rsa.pem"
} > "$corpus_root/service-account.yaml"

ssh-keygen -q -t ed25519 -N '' -C 'synthetic@example.invalid' \
  -f "$corpus_root/generated-ssh-key"
printf 'ENCRYPTION_KEY=%s\n' "$encryption_key" > "$corpus_root/symmetric-key.env"
printf 'WEBHOOK_SIGNING_SECRET=%s\n' "$webhook_secret" > "$corpus_root/webhook-secret.env"
printf 'ENCODED_INTERNAL_TOKEN=%s\n' "$encoded_custom" > "$corpus_root/base64-custom.env"
# These are intentionally literal references or placeholders, not expansions.
# shellcheck disable=SC2016
printf 'API_TOKEN=${API_TOKEN:?required at runtime}\nPASSWORD_FROM_STORE=secret://payments/database/password\n' \
  > "$corpus_root/runtime-reference.env"
printf 'EXAMPLE_TOKEN=replace-me-at-runtime\n' > "$corpus_root/placeholder.env"

scenario_order=(
  custom_internal
  password_assignment
  postgres_url
  basic_header
  bearer_jwt
  github_pat
  oauth_client_secret
  aws_pair
  aws_split
  service_account
  rsa_private_key
  openssh_private_key
  symmetric_key
  webhook_secret
  base64_custom
  runtime_reference
  placeholder
  public_key
)
scenario_labels=(
  "Custom internal token"
  "Username/password assignment"
  "PostgreSQL credential URL"
  "HTTP Basic credential"
  "Bearer JWT"
  "GitHub PAT-shaped token"
  "OAuth client secret"
  "AWS key pair, same file"
  "AWS key pair, split files"
  "Service-account private key"
  "RSA private key"
  "OpenSSH private key"
  "Symmetric encryption key"
  "Webhook signing secret"
  "Base64-encoded custom token"
  "Runtime secret reference"
  "Placeholder value"
  "SSH public key"
)
scenario_files=(
  "$corpus_root/custom-internal.env"
  "$corpus_root/password-assignment.txt"
  "$corpus_root/postgres-url.env"
  "$corpus_root/basic-header.txt"
  "$corpus_root/bearer-jwt.txt"
  "$corpus_root/github-pat.env"
  "$corpus_root/oauth-client.env"
  "$corpus_root/aws-pair.env"
  "$corpus_root/aws-split"
  "$corpus_root/service-account.yaml"
  "$corpus_root/generated-rsa.pem"
  "$corpus_root/generated-ssh-key"
  "$corpus_root/symmetric-key.env"
  "$corpus_root/webhook-secret.env"
  "$corpus_root/base64-custom.env"
  "$corpus_root/runtime-reference.env"
  "$corpus_root/placeholder.env"
  "$corpus_root/generated-ssh-key.pub"
)
expected_decisions=(
  block block block block block block block block block block block block block block block
  pass pass pass
)

# These expected scanner results describe only the pinned versions and config.
# A changed result fails this comparison so that the recorded table is reviewed.
expected_gitleaks_statuses=(1 1 0 0 1 0 1 1 1 1 1 1 1 1 1 0 0 0)
expected_gitleaks_findings=(1 1 0 0 1 0 1 1 1 1 1 1 1 1 2 0 0 0)
expected_gitleaks_rules=(
  synthetic-demo-api-key
  generic-api-key
  ""
  ""
  jwt
  ""
  generic-api-key
  generic-api-key
  generic-api-key
  private-key
  private-key
  private-key
  generic-api-key
  generic-api-key
  "generic-api-key,synthetic-demo-api-key"
  ""
  ""
  ""
)
expected_trufflehog_statuses=(183 0 183 0 0 183 0 183 0 183 183 183 0 0 183 0 0 0)
expected_trufflehog_findings=(1 0 1 0 0 1 0 1 0 1 1 1 0 0 1 0 0 0)
expected_trufflehog_detectors=(
  CustomRegex
  ""
  Postgres
  ""
  ""
  Github
  ""
  AWS
  ""
  PrivateKey
  PrivateKey
  PrivateKey
  ""
  ""
  CustomRegex
  ""
  ""
  ""
)

gitleaks_statuses=()
gitleaks_findings=()
gitleaks_rules=()
trufflehog_statuses=()
trufflehog_findings=()
trufflehog_detectors=()

run_scenario() {
  local scenario_index="$1"
  local scenario_name="${scenario_order[$scenario_index]}"
  local input_file="${scenario_files[$scenario_index]}"
  local gitleaks_report="$reports_root/${scenario_name}-gitleaks.json"
  local trufflehog_report="$reports_root/${scenario_name}-trufflehog.jsonl"
  local trufflehog_log="$reports_root/${scenario_name}-trufflehog.log"

  set +e
  gitleaks dir \
    --config "$gitleaks_config" \
    --exit-code 1 \
    --max-decode-depth 1 \
    --no-banner \
    --redact=100 \
    --report-format json \
    --report-path "$gitleaks_report" \
    "$input_file" >/dev/null 2>&1
  gitleaks_statuses[scenario_index]=$?

  trufflehog filesystem "$input_file" \
    --config "$trufflehog_config" \
    --no-verification \
    --no-update \
    --json \
    --fail \
    --fail-on-scan-errors \
    >"$trufflehog_report" 2>"$trufflehog_log"
  trufflehog_statuses[scenario_index]=$?
  set -e

  gitleaks_findings[scenario_index]="$(jq 'length' "$gitleaks_report")"
  gitleaks_rules[scenario_index]="$(
    jq -r '[.[].RuleID] | unique | join(",")' "$gitleaks_report"
  )"
  trufflehog_findings[scenario_index]="$(jq -s 'length' "$trufflehog_report")"
  trufflehog_detectors[scenario_index]="$(
    jq -sr '[.[].DetectorName] | unique | join(",")' "$trufflehog_report"
  )"

  if [[ "${gitleaks_statuses[$scenario_index]}" -ne "${expected_gitleaks_statuses[$scenario_index]}" \
    || "${gitleaks_findings[$scenario_index]}" -ne "${expected_gitleaks_findings[$scenario_index]}" \
    || "${gitleaks_rules[$scenario_index]}" != "${expected_gitleaks_rules[$scenario_index]}" ]]; then
    printf 'unexpected Gitleaks result for %s\n' "$scenario_name" >&2
    exit 1
  fi

  if [[ "${trufflehog_statuses[$scenario_index]}" -ne "${expected_trufflehog_statuses[$scenario_index]}" \
    || "${trufflehog_findings[$scenario_index]}" -ne "${expected_trufflehog_findings[$scenario_index]}" \
    || "${trufflehog_detectors[$scenario_index]}" != "${expected_trufflehog_detectors[$scenario_index]}" ]]; then
    printf 'unexpected TruffleHog result for %s\n' "$scenario_name" >&2
    exit 1
  fi

  # Gitleaks is configured to redact persisted reports. TruffleHog JSON can
  # contain Raw fields, so its reports remain inside the temporary directory.
  for materialized_value in \
    "$custom_value" "$password_value" "$postgres_url" "$basic_value" \
    "$jwt_value" "$github_pat" "$oauth_secret" "$aws_id" "$aws_secret" \
    "$encryption_key" "$webhook_secret" "$encoded_custom"; do
    if grep -Fq "$materialized_value" "$gitleaks_report"; then
      printf 'Gitleaks report exposed temporary fixture material for %s\n' \
        "$scenario_name" >&2
      exit 1
    fi
  done
}

for scenario_index in "${!scenario_order[@]}"; do
  run_scenario "$scenario_index"
done

gitleaks_version="$(gitleaks version | tr -d '\r')"
trufflehog_version="$(trufflehog --version | awk '{print $2}' | tr -d '\r')"
measured_on="$(date -u +%Y-%m-%d)"

positive_scenarios=0
gitleaks_positive_detections=0
trufflehog_positive_detections=0
for scenario_index in "${!scenario_order[@]}"; do
  if [[ "${expected_decisions[$scenario_index]}" == "block" ]]; then
    positive_scenarios=$((positive_scenarios + 1))
    if [[ "${gitleaks_findings[$scenario_index]}" -gt 0 ]]; then
      gitleaks_positive_detections=$((gitleaks_positive_detections + 1))
    fi
    if [[ "${trufflehog_findings[$scenario_index]}" -gt 0 ]]; then
      trufflehog_positive_detections=$((trufflehog_positive_detections + 1))
    fi
  fi
done

if [[ "$output_mode" == "json" ]]; then
  scenario_jsonl="$comparison_root/scenarios.jsonl"
  for scenario_index in "${!scenario_order[@]}"; do
    jq -n \
      --arg id "${scenario_order[$scenario_index]//_/-}" \
      --arg credential_class "${scenario_labels[$scenario_index]}" \
      --arg expected "${expected_decisions[$scenario_index]}" \
      --argjson g_status "${gitleaks_statuses[$scenario_index]}" \
      --argjson g_count "${gitleaks_findings[$scenario_index]}" \
      --arg g_match "${gitleaks_rules[$scenario_index]}" \
      --argjson t_status "${trufflehog_statuses[$scenario_index]}" \
      --argjson t_count "${trufflehog_findings[$scenario_index]}" \
      --arg t_match "${trufflehog_detectors[$scenario_index]}" \
      '{
        id: $id,
        credential_class: $credential_class,
        expected_control_decision: $expected,
        gitleaks: {
          detected: ($g_count > 0), exit_code: $g_status, findings: $g_count,
          detector: ($g_match | if length == 0 then null else . end)
        },
        trufflehog: {
          detected: ($t_count > 0), exit_code: $t_status, findings: $t_count,
          detector: ($t_match | if length == 0 then null else . end)
        }
      }' >> "$scenario_jsonl"
  done

  jq -s \
    --arg measured_on "$measured_on" \
    --arg gitleaks_version "$gitleaks_version" \
    --arg trufflehog_version "$trufflehog_version" \
    --argjson positives "$positive_scenarios" \
    --argjson g_detections "$gitleaks_positive_detections" \
    --argjson t_detections "$trufflehog_positive_detections" \
    '{
      schema_version: 2,
      measured_on: $measured_on,
      command: "./scripts/compare-secret-scanners.sh --json",
      corpus: {
        secret_material_committed: false,
        provider_checks_enabled: false,
        positive_scenarios: $positives,
        safe_negative_scenarios: (length - $positives),
        scenarios: .
      },
      summary: {
        note: "Scenario detections are not a production accuracy rate or total-coverage score.",
        gitleaks_positive_scenarios_detected: $g_detections,
        trufflehog_positive_scenarios_detected: $t_detections
      },
      tools: {
        gitleaks: {
          version: $gitleaks_version,
          configuration: "defaults plus repository custom rule and one decoding pass",
          report_handling: "redacted"
        },
        trufflehog: {
          version: $trufflehog_version,
          configuration: "built-in detectors plus equivalent custom rule",
          report_handling: "temporary raw JSON deleted on exit"
        },
        github_secret_protection: {
          executed: false,
          reason: "Host-native behavior requires an eligible disposable remote repository, enabled features and patterns, and server-observed pushes.",
          procedure: "results/github-secret-protection-test-procedure.md"
        }
      }
    }' "$scenario_jsonl"
else
  printf '%-29s | %-34s | %-34s\n' 'scenario' 'Gitleaks' 'TruffleHog'
  printf '%s\n' '------------------------------+------------------------------------+-----------------------------------'
  for scenario_index in "${!scenario_order[@]}"; do
    g_result="missed"
    t_result="missed"
    if [[ "${gitleaks_findings[$scenario_index]}" -gt 0 ]]; then
      g_result="detected ${gitleaks_findings[$scenario_index]} (${gitleaks_rules[$scenario_index]})"
    fi
    if [[ "${trufflehog_findings[$scenario_index]}" -gt 0 ]]; then
      t_result="detected ${trufflehog_findings[$scenario_index]} (${trufflehog_detectors[$scenario_index]})"
    fi
    if [[ "${expected_decisions[$scenario_index]}" == "pass" ]]; then
      g_result="passed"
      t_result="passed"
    fi
    printf '%-29s | %-34s | %-34s\n' \
      "${scenario_order[$scenario_index]//_/-}" "$g_result" "$t_result"
  done
  printf 'positive scenarios detected: gitleaks %s/%s; trufflehog %s/%s\n' \
    "$gitleaks_positive_detections" "$positive_scenarios" \
    "$trufflehog_positive_detections" "$positive_scenarios"
  printf 'versions: gitleaks %s; trufflehog %s\n' \
    "$gitleaks_version" "$trufflehog_version"
  printf 'provider checks: disabled; fixture material: temporary; persisted output: metadata only\n'
fi
