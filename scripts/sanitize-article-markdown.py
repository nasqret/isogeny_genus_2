#!/usr/bin/env python3
"""Normalize Pandoc's LaTeX-to-MyST output for the article chapter."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


DISPLAY_ENV_RE = re.compile(
    r"\$\$\s*\\begin\{(?P<env>equation|align\*?|eqnarray)\}"
    r"(?P<body>.*?)"
    r"\\end\{(?P=env)\}\$\$",
    re.DOTALL,
)
TIKZ_RE = re.compile(
    r"\$\$\\begin\{tikzcd\}.*?\\end\{tikzcd\}\$\$",
    re.DOTALL,
)
LABEL_RE = re.compile(r"\\label\{([^}]+)\}")
CASES_RE = re.compile(
    r"\\begin\{cases\}(?P<body>.*?)\\end\{cases\}",
    re.DOTALL,
)
EQREF_RE = re.compile(
    r"\[\\\[(?P<label>.+?)\\\]\]"
    r"\(#[^)]+\)"
    r"\{reference-type=\"eqref\"\s+reference=\"(?P<reference>[^\"]+)\"\}",
    re.DOTALL,
)
GENERIC_REF_RE = re.compile(
    r"(?P<link>\[[^\n]+?\]\(#[^)]+\))"
    r"\{reference-type=\"[^\"]+\"\s+reference=\"[^\"]+\"\}",
    re.DOTALL,
)
FENCED_DIRECTIVE_RE = re.compile(
    r"^:::\s+\{#(?P<id>.+?)\s+\.(?P<directive>[A-Za-z0-9_-]+)\}\s*$",
    re.MULTILINE,
)
HEADING_WITH_ID_RE = re.compile(
    r"^(?P<heading>#{1,6}\s+.*?)\s+\{#(?P<id>[^}]+)\}\s*$",
    re.MULTILINE,
)
ANCHOR_LINK_RE = re.compile(r"\]\(#(?P<id>[^)]+)\)")
DISPLAY_MATH_RE = re.compile(r"\$\$(?P<body>.*?)\$\$", re.DOTALL)
DIRECTIVE_BLOCK_RE = re.compile(
    r"^:::\s+(?P<directive>[A-Za-z0-9_-]+)\s*$"
    r"(?P<body>.*?)"
    r"^:::\s*$",
    re.MULTILINE | re.DOTALL,
)


TIKZ_REPLACEMENT = r"""

**Geometric cover tower**

| Source | Target | Degree |
| --- | --- | ---: |
| $Y$ | $X$ | 3 |
| $Y$ | $D$ | 2 |
| $X$ | $E$ | 4 |
| $X$ | $\mathbb P^1_x$ | 2 |
| $D$ | $\mathbb P^1_x$ | 3 |
| $D$ | $\mathbb P^1_z$ | 12 |
| $E$ | $\mathbb P^1_z$ | 2 |
| $\mathbb P^1_x$ | $\mathbb P^1_z$ | 4 |

**Corresponding subgroup inclusions**

| Subgroup | Containing subgroup(s) |
| --- | --- |
| $\{1\}$ | $\langle(234)\rangle,\ \langle(34)\rangle$ |
| $\langle(234)\rangle$ | $A_4,\ \operatorname{Stab}(1)$ |
| $\langle(34)\rangle$ | $\operatorname{Stab}(1),\ S_4$ |
| $A_4$ | $S_4$ |
| $\operatorname{Stab}(1)$ | $S_4$ |

"""


def slugify(label: str) -> str:
    """Create a stable HTML/MyST identifier from a LaTeX label."""
    slug = re.sub(r"[^A-Za-z0-9_-]+", "-", label.strip())
    slug = re.sub(r"-+", "-", slug).strip("-").lower()
    return slug or "reference"


def strip_math_comments(body: str) -> str:
    """Remove unescaped TeX comments without consuming the math delimiter."""
    return re.sub(r"(?m)(?<!\\)%[^\n]*", "", body)


def flatten_cases(body: str) -> str:
    """Avoid nested cases/split environments in MyST's AMS math renderer."""

    def replace_cases(match: re.Match[str]) -> str:
        rows = [
            re.sub(r"\s+", " ", row).strip()
            for row in re.split(r"\\\\", match.group("body"))
            if row.strip()
        ]
        return r" \quad\text{and}\quad ".join(rows)

    return CASES_RE.sub(replace_cases, body)


def sanitize_article(text: str) -> str:
    labels_in_order = [label.strip() for label in LABEL_RE.findall(text)]
    if len(labels_in_order) != len(set(labels_in_order)):
        raise ValueError("duplicate equation labels in Pandoc output")
    equation_numbers = {
        label: number for number, label in enumerate(labels_in_order, start=1)
    }
    used_labels: set[str] = set()

    text, tikz_count = TIKZ_RE.subn(lambda _: TIKZ_REPLACEMENT, text)
    if tikz_count != 1:
        raise ValueError(f"expected one tikzcd diagram, found {tikz_count}")

    def remember_label(label: str) -> tuple[str, int]:
        clean_label = label.strip()
        if clean_label not in equation_numbers:
            raise ValueError(f"unknown equation label: {clean_label}")
        if clean_label in used_labels:
            raise ValueError(f"duplicate equation label use: {clean_label}")
        used_labels.add(clean_label)
        return slugify(clean_label), equation_numbers[clean_label]

    def sanitize_environment(match: re.Match[str]) -> str:
        env = match.group("env")
        body = strip_math_comments(match.group("body")).strip()
        body = flatten_cases(body)

        if env == "eqnarray":
            rows = [row.strip() for row in re.split(r"\\\\", body) if row.strip()]
            displays: list[str] = []
            for row in rows:
                labels = LABEL_RE.findall(row)
                if len(labels) != 1:
                    raise ValueError(
                        "each eqnarray row must contain exactly one label"
                    )
                anchor, number = remember_label(labels[0])
                formula = LABEL_RE.sub("", row).strip()
                displays.append(
                    f'<span id="{anchor}"></span>'
                    f"$$\n{formula} \\qquad\\text{{({number})}}\n$$"
                )
            return "\n\n".join(displays)

        labels = LABEL_RE.findall(body)
        if len(labels) > 1:
            raise ValueError(f"{env} block contains multiple equation labels")

        anchor_html = ""
        number_suffix = ""
        if labels:
            anchor, number = remember_label(labels[0])
            anchor_html = f'<span id="{anchor}"></span>'
            number_suffix = f" \\qquad\\text{{({number})}}"
            body = LABEL_RE.sub("", body).strip()

        if env.startswith("align"):
            body = rf"\begin{{aligned}}{body}\end{{aligned}}"

        return f"{anchor_html}$$\n{body}{number_suffix}\n$$"

    text = DISPLAY_ENV_RE.sub(sanitize_environment, text)

    def strip_comments_from_display(match: re.Match[str]) -> str:
        body = strip_math_comments(match.group("body")).strip()
        body = flatten_cases(body)
        anchors: list[str] = []

        def replace_remaining_label(label_match: re.Match[str]) -> str:
            anchor, number = remember_label(label_match.group(1))
            anchors.append(f'<span id="{anchor}"></span>')
            return rf" \qquad\text{{({number})}}"

        body = LABEL_RE.sub(replace_remaining_label, body)
        anchor_html = "\n".join(anchors)
        prefix = f"\n\n{anchor_html}\n\n" if anchor_html else "\n\n"
        return f"{prefix}$$\n{body}\n$$\n\n"

    text = DISPLAY_MATH_RE.sub(strip_comments_from_display, text)

    def replace_eqref(match: re.Match[str]) -> str:
        label = match.group("reference").strip()
        number = equation_numbers.get(label)
        link_text = f"({number})" if number is not None else "equation"
        return f'<a href="#{slugify(label)}">{link_text}</a>'

    text = EQREF_RE.sub(replace_eqref, text)
    text = GENERIC_REF_RE.sub(lambda match: match.group("link"), text)

    text = FENCED_DIRECTIVE_RE.sub(
        lambda match: (
            f'({slugify(match.group("id"))})=\n::: {match.group("directive")}'
        ),
        text,
    )

    def remove_cross_block_emphasis(match: re.Match[str]) -> str:
        body = match.group("body")
        if "$$" not in body:
            return match.group(0)

        body = re.sub(
            r"(\*\*[^*\n]+\*\*(?:\s+\([^)]*\))?\.\s*)\*",
            r"\1",
            body,
            count=1,
        )
        stripped = body.rstrip()
        if stripped.endswith("*"):
            body = stripped[:-1] + "\n"
        return f"::: {match.group('directive')}{body}:::"

    text = DIRECTIVE_BLOCK_RE.sub(remove_cross_block_emphasis, text)

    text = HEADING_WITH_ID_RE.sub(
        lambda match: (
            f'({slugify(match.group("id"))})=\n{match.group("heading")}'
        ),
        text,
    )
    text = ANCHOR_LINK_RE.sub(
        lambda match: f'](#{slugify(match.group("id"))})',
        text,
    )

    forbidden_patterns = {
        "nested display environment": (
            r"\$\$\\begin\{(?:equation|align\*?|eqnarray)\}"
        ),
        "unsupported tikzcd": r"\\begin\{tikzcd\}",
        "Pandoc reference metadata": r"\{reference-type=",
        "LaTeX equation label": r"\\label\{",
        "Pandoc heading identifier": r"\{#[^}]+\}",
    }
    for description, pattern in forbidden_patterns.items():
        if re.search(pattern, text):
            raise ValueError(f"sanitizer left {description} in the article")

    unused_labels = set(equation_numbers) - used_labels
    if unused_labels:
        raise ValueError(
            "sanitizer did not consume equation labels: "
            + ", ".join(sorted(unused_labels))
        )

    malformed_display_lines = [
        line for line in text.splitlines() if "$$" in line and line.strip() != "$$"
    ]
    if malformed_display_lines:
        raise ValueError("display math delimiters must appear on their own lines")

    text = re.sub(r"\n{4,}", "\n\n\n", text)
    return text


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    source = args.input.read_text(encoding="utf-8")
    sanitized = sanitize_article(source)
    args.output.write_text(sanitized, encoding="utf-8")


if __name__ == "__main__":
    main()
