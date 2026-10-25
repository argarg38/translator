#!/bin/bash
# Pick the Korean font pdf2zh embeds and record it in its config file.
# pdf2zh reads NOTO_FONT_PATH from ~/.config/PDFMathTranslate/config.json
# before the environment, so exporting the variable alone is not enough.
#
# Order: $KO_FONT > fonts/malgun.ttf (user-supplied 맑은 고딕) > bundled Pretendard.
set -euo pipefail

repo="$(cd "$(dirname "$0")/../../.." && pwd)"
font="${KO_FONT:-}"
if [ -z "$font" ]; then
  for f in "$repo/fonts/malgun.ttf" "$repo/fonts/MALGUN.TTF" "$repo/fonts/Pretendard-Regular.otf"; do
    if [ -f "$f" ]; then font="$f"; break; fi
  done
fi
[ -f "$font" ] || { echo "font not found: $font" >&2; exit 1; }

/root/.local/share/uv/tools/pdf2zh/bin/python -I - "$font" <<'EOF'
import json, sys
from pathlib import Path
p = Path.home() / ".config" / "PDFMathTranslate" / "config.json"
p.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}
data["NOTO_FONT_PATH"] = sys.argv[1]
p.write_text(json.dumps(data, indent=4, ensure_ascii=False), encoding="utf-8")
print("font:", sys.argv[1])
EOF
