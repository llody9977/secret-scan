#!/usr/bin/env python3
"""Validate the dependency-free GitHub Pages artifact using the standard library."""

from __future__ import annotations

import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
INDEX = DOCS / "index.html"


class SiteParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: list[str] = []
        self.hrefs: list[str] = []
        self.sources: list[str] = []
        self.h1_count = 0
        self.title_count = 0
        self.description_count = 0
        self.meta_properties: dict[str, str] = {}

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.append(values["id"] or "")
        if tag == "a" and values.get("href"):
            self.hrefs.append(values["href"] or "")
        if tag in {"img", "script"} and values.get("src"):
            self.sources.append(values["src"] or "")
        if tag == "link" and values.get("href"):
            self.sources.append(values["href"] or "")
        if tag == "h1":
            self.h1_count += 1
        if tag == "title":
            self.title_count += 1
        if tag == "meta" and values.get("name") == "description" and values.get("content"):
            self.description_count += 1
        if tag == "meta" and values.get("property") and values.get("content"):
            self.meta_properties[values["property"] or ""] = values["content"] or ""


def local_path(reference: str) -> Path | None:
    parsed = urlsplit(reference)
    if parsed.scheme or parsed.netloc or reference.startswith("#") or reference.startswith("data:"):
        return None
    return (DOCS / unquote(parsed.path)).resolve()


def main() -> int:
    errors: list[str] = []
    parser = SiteParser()
    html = INDEX.read_text(encoding="utf-8")
    parser.feed(html)

    duplicate_ids = sorted({value for value in parser.ids if parser.ids.count(value) > 1})
    if duplicate_ids:
        errors.append(f"duplicate HTML ids: {', '.join(duplicate_ids)}")
    if parser.h1_count != 1:
        errors.append(f"expected exactly one h1, found {parser.h1_count}")
    if parser.title_count != 1:
        errors.append(f"expected exactly one title, found {parser.title_count}")
    if parser.description_count != 1:
        errors.append(f"expected exactly one meta description, found {parser.description_count}")
    expected_og_image = "https://llody9977.github.io/secret-scan/og.jpg"
    if parser.meta_properties.get("og:image") != expected_og_image:
        errors.append("Open Graph image URL does not match the GitHub Pages asset")
    if not (DOCS / "og.jpg").is_file():
        errors.append("missing docs/og.jpg social preview")

    id_set = set(parser.ids)
    for href in parser.hrefs:
        if href.startswith("#") and unquote(href[1:]) not in id_set:
            errors.append(f"unresolved in-page link: {href}")

    for reference in parser.hrefs + parser.sources:
        path = local_path(reference)
        if path is None:
            continue
        try:
            path.relative_to(DOCS.resolve())
        except ValueError:
            errors.append(f"local page reference escapes docs/: {reference}")
            continue
        if not path.exists():
            errors.append(f"missing local page reference: {reference}")

    css = (DOCS / "styles.css").read_text(encoding="utf-8")
    if css.count("{") != css.count("}"):
        errors.append("styles.css has unbalanced braces")

    required_content = (
        'class="control-map"',
        "GitHub receive boundary",
        "Preventive at GitHub's receive boundary",
        "Detective for first remote exposure",
        "repository configured",
        "Start with the lowest-effort governed boundary",
    )
    for phrase in required_content:
        if phrase not in html:
            errors.append(f"missing control-model content: {phrase}")
    if 'class="results-panel"' in html or "make compare" in html:
        errors.append("abbreviated make-compare panel duplicates the full scenario matrix")

    if errors:
        print("Static-site validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        f"Validated docs/index.html: {len(id_set)} ids, "
        f"{len(parser.hrefs)} links, {len(parser.sources)} local/source references."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
