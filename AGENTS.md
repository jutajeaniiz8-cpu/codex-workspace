# Codex Workspace Instructions

## Universal file reading

This repository includes the repo-level skill:

`.agents/skills/universal-file-reader/`

Use it whenever a task requires reading, inspecting, extracting, validating, or auditing local files such as PDF, DOCX, PPTX, XLSX/XLS, CSV/TSV, JSON, XML, HTML, TXT/Markdown, ZIP, images, audio, or EPUB.

### Runtime readiness

Dependencies are declared in the repository-root `requirements.txt` so Codex Cloud automatic Python setup can install them before the agent phase.

Before using the skill, verify the runtime with:

```bash
python .agents/skills/universal-file-reader/scripts/self_test.py
```

If dependencies are missing and package installation is allowed, run:

```bash
python -m pip install -r requirements.txt
```

Then rerun the self-test.

The GitHub Actions workflow `.github/workflows/universal-file-reader-ci.yml` repeats this install-and-self-test flow in a clean Python 3.12 environment whenever the skill or its dependencies change.

### Source fidelity

- Never invent missing or unreadable content.
- Treat the source file as authoritative.
- Prefer native parsing for spreadsheets and structured data when exact values, formulas, sheet names, coordinates, delimiters, or schema matter.
- Distinguish extracted facts from inference.
- Report parser failures explicitly.
- Do not silently enable third-party MarkItDown plugins.
