#!/usr/bin/env bash
set -euo pipefail

python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python .agents/skills/universal-file-reader/scripts/self_test.py

echo "Universal File Reader setup complete."
