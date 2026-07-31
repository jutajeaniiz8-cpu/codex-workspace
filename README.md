# codex-workspace

Codex workspace with a repo-level **Universal File Reader** skill.

## Installed skill

Path:

```text
.agents/skills/universal-file-reader/
```

The skill is designed to inspect and extract local content from:

- PDF
- DOCX
- PPTX
- XLSX / XLSM / XLTX / XLTM
- XLS through MarkItDown
- CSV / TSV
- JSON
- XML / HTML
- TXT / Markdown / common source-code text files
- ZIP
- images, audio, EPUB, and other formats supported by Microsoft MarkItDown

For exact spreadsheet auditing, the skill prefers native parsing and preserves sheet names, cell coordinates, values, and formulas as stored.

## Dependencies

The repository-root `requirements.txt` contains the runtime dependencies so Codex Cloud can detect the Python project dependencies during environment setup.

Current pinned core versions:

```text
markitdown[all]==0.1.7
openpyxl==3.1.5
```

`defusedxml` is also included as an XML hardening dependency.

## Setup

### Linux / Codex Cloud

```bash
bash setup.sh
```

### Windows PowerShell

```powershell
.\setup.ps1
```

Both setup scripts install dependencies and run the self-test.

## Verify

```bash
python .agents/skills/universal-file-reader/scripts/self_test.py
```

Expected result:

```text
SELF-TEST PASS: universal-file-reader dependencies and core parsers are working.
```

## Use in Codex

Explicit invocation:

```text
$universal-file-reader
```

Example:

```text
Use $universal-file-reader to inspect all files under ./sources.
Report extracted facts, structure, parser errors, and unreadable content.
Do not invent missing values.
```

Codex may also select the skill automatically when the request matches its description.

## Source-fidelity policy

- Never invent unreadable or missing content.
- Source files remain authoritative.
- Exact spreadsheet and structured-data work uses native parsing where available.
- Extraction errors are reported instead of being silently repaired.
- Third-party MarkItDown plugins are disabled by default.

## Validation

`.github/workflows/universal-file-reader-ci.yml` installs the repository dependencies and runs the self-test in a clean Python 3.12 GitHub Actions environment whenever the skill or dependency configuration changes.
