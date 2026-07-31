# Supported formats and parser policy

## Native/exact-first

- XLSX, XLSM, XLTX, XLTM: `openpyxl` for workbook structure, sheet names, cells, formulas, and values as stored.
- CSV: Python `csv` parser with UTF-8 BOM handling.
- TSV: Python `csv` parser with tab delimiter.
- JSON: Python `json` parser with validation.
- ZIP: Python `zipfile` member listing before any extraction.
- TXT/MD/log/source-code text: direct UTF-8 text reading.

## MarkItDown-first

Use `extract_to_markdown.py` for formats supported by the installed Microsoft MarkItDown build, typically including document, presentation, PDF, HTML/XML, image, audio, EPUB, and related conversion inputs.

## Important limitations

- Legacy `.xls` is not supported by `openpyxl`; use a parser that explicitly supports `.xls` or MarkItDown if the installed build supports it.
- Spreadsheet formulas are not recalculated by this skill. A formula engine is required to compute fresh formula results.
- OCR is only considered successful when an OCR-capable conversion path actually returns text. Never infer text from an unreadable scan.
- Password-protected, encrypted, malformed, or unsupported files must be reported as unreadable rather than guessed.
- Converting to Markdown is useful for LLM reading, but Markdown output is not a substitute for cell-level source-of-truth auditing when exact spreadsheet fidelity matters.
