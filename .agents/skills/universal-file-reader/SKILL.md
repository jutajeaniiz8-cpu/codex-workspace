---
name: universal-file-reader
description: Read, inspect, extract, and audit local files across PDF, Word, PowerPoint, Excel, CSV/TSV, JSON, XML, HTML, plain text/Markdown, ZIP archives, images, audio, and related formats. Use when Codex needs reliable file content or structure. Prefer native parsing for spreadsheets and structured data; use MarkItDown for document conversion. Never invent unreadable or missing values.
---

# Universal File Reader

Use this skill to inspect files while preserving source fidelity.

## Core rules

1. Treat the source file as authoritative. Never fill in missing, unreadable, truncated, or failed-to-parse content.
2. Separate extracted facts from interpretation. When interpretation is requested, label it clearly.
3. Prefer local-only reading. Do not fetch remote URLs unless the user explicitly asks for it.
4. For spreadsheets and structured data, prefer native parsing over Markdown conversion when exact values, sheet names, formulas, row/column positions, or schema matter.
5. For document-style formats, use Microsoft MarkItDown as the default conversion layer, then verify critical facts against native structure when possible.
6. Preserve source trace in the output: filename, file type, parser used, and any warnings/errors.
7. If a required parser is unavailable, report the missing dependency. Install dependencies only when the environment permits package installation.

## Routing

- `.xlsx`, `.xlsm`, `.xltx`, `.xltm`: use `scripts/inspect_file.py` with `openpyxl` for workbook/sheet/cell/formula inspection.
- `.xls`: use MarkItDown or another explicit `.xls` parser available in the environment; do not pretend `openpyxl` supports legacy `.xls`.
- `.csv`, `.tsv`: use `scripts/inspect_file.py` for delimiter-aware tabular inspection.
- `.json`: use `scripts/inspect_file.py` for JSON validation and structural preview.
- `.txt`, `.md`, `.log`, common source-code text files: use `scripts/inspect_file.py` or direct text reading.
- `.zip`: use `scripts/inspect_file.py` to list members first. Do not extract blindly.
- `.pdf`, `.docx`, `.pptx`, `.html`, `.xml`, images, audio, EPUB, and other MarkItDown-supported inputs: use `scripts/extract_to_markdown.py`.
- For scanned/embedded-image documents, do not claim OCR text was extracted unless OCR actually ran successfully.

## Typical workflow

1. Identify the file extension and the user's fidelity requirement.
2. Inspect structure before producing conclusions.
3. For Office/PDF/media conversion, run:

```bash
python .agents/skills/universal-file-reader/scripts/extract_to_markdown.py INPUT_FILE -o OUTPUT.md
```

4. For exact spreadsheet/CSV/JSON/ZIP/text inspection, run:

```bash
python .agents/skills/universal-file-reader/scripts/inspect_file.py INPUT_FILE
```

5. If dependencies are missing and installation is allowed:

```bash
python -m pip install -r requirements.txt
```

6. Report results using these categories when relevant:
   - `EXTRACTED FACT`
   - `STRUCTURE`
   - `UNREADABLE / ERROR`
   - `INFERENCE` (only when the user asked for interpretation)

## Validation

Before relying on the skill in a new runtime, run:

```bash
python .agents/skills/universal-file-reader/scripts/self_test.py
```

A healthy runtime prints `SELF-TEST PASS`.

## Spreadsheet fidelity rules

When exact spreadsheet content matters:

- report workbook and sheet names exactly;
- preserve cell coordinates when quoting or auditing values;
- distinguish formulas from cached/calculated values;
- do not recalculate formulas unless an explicit calculation engine is used;
- do not silently coerce dates, blanks, booleans, or numeric-looking strings;
- do not use Markdown conversion as the sole source of truth for formulas or cell-level auditing.

## Safety

MarkItDown can access resources available to the running process. Use only local paths supplied by the user or paths already inside the working repository unless the user explicitly requests remote access. Avoid enabling third-party MarkItDown plugins by default.
