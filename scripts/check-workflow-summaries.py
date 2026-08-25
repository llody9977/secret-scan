#!/usr/bin/env python3
"""Check that scanner workflows publish safe, decision-useful job summaries."""

from __future__ import annotations

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    errors: list[str] = []
    requirements = {
        ".github/workflows/gitleaks.yml": [
            "GITHUB_STEP_SUMMARY",
            "Gitleaks full-history scan",
            "Detective for content already pushed",
            "preventive for merge or promotion",
            "contextual match text is not published; report remains in temporary runner storage and is not uploaded",
            "redaction check failed",
            '== "REDACTED"',
            'scan_status=$?',
            "validation_error=false",
            'gsub("[^A-Za-z0-9._:/+-]"; "_")',
        ],
        ".github/workflows/trufflehog-discovery.yml": [
            "GITHUB_STEP_SUMMARY",
            "TruffleHog scheduled discovery",
            "Detective hygiene and legacy discovery",
            "Provider checks | Disabled",
            "Raw JSON stays in temporary runner storage and is not uploaded",
            "Findings by detector",
            'scan_status=$?',
            "validation_error=false",
            'gsub("[^A-Za-z0-9._:/+-]"; "_")',
        ],
        ".github/workflows/scanner-comparison.yml": [
            "GITHUB_STEP_SUMMARY",
            "includes repository rule",
            "repository custom detector",
            "it is not out-of-box coverage",
        ],
    }

    for relative, phrases in requirements.items():
        content = (ROOT / relative).read_text(encoding="utf-8")
        for phrase in phrases:
            if phrase not in content:
                errors.append(f"{relative}: missing workflow-summary contract: {phrase}")

    for relative in (
        ".github/workflows/gitleaks.yml",
        ".github/workflows/trufflehog-discovery.yml",
    ):
        content = (ROOT / relative).read_text(encoding="utf-8")
        if "actions/upload-artifact" in content:
            errors.append(f"{relative}: production raw scanner output must not be uploaded")

    if errors:
        print("Workflow-summary validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("Validated safe job-summary contracts for Gitleaks, TruffleHog, and the corpus comparison.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
