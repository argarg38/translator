#!/bin/bash
# Install PDFMathTranslate (pdf2zh) in Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if command -v pdf2zh >/dev/null 2>&1; then
  exit 0
fi

# pdf2zh does not support Python 3.13; pin deps whose newer releases break it.
uv tool install --python 3.12 pdf2zh \
  --with "tencentcloud-sdk-python-tmt<3.1" \
  --with "tencentcloud-sdk-python-common<3.1" \
  --with "bitstring<5"
