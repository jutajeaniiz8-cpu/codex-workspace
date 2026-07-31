#!/usr/bin/env python3
"""Convert a local file to Markdown using Microsoft MarkItDown."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert a local file to Markdown with MarkItDown.")
    parser.add_argument("input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    source = args.input.resolve()
    if not source.exists() or not source.is_file():
        print(f"UNREADABLE / ERROR: file not found: {source}", file=sys.stderr)
        return 2

    try:
        from markitdown import MarkItDown
    except ImportError as exc:
        print(
            "UNREADABLE / ERROR: MarkItDown is not installed. Run: "
            "python -m pip install -r .agents/skills/universal-file-reader/requirements.txt",
            file=sys.stderr,
        )
        return 3

    try:
        converter = MarkItDown(enable_plugins=False)
        result = converter.convert(str(source))
        text = getattr(result, "text_content", None)
        if text is None:
            raise RuntimeError("MarkItDown returned no text_content")
    except Exception as exc:
        print(f"UNREADABLE / ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 4

    if args.output:
        output = args.output.resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(text, encoding="utf-8")
        print(f"EXTRACTED FACT: wrote Markdown to {output}")
    else:
        sys.stdout.write(text)
        if text and not text.endswith("\n"):
            sys.stdout.write("\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
